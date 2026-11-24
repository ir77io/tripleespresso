//
//  BatteryMonitor.swift
//  TripleEspresso
//

import Foundation
import IOKit.ps

/// Snapshot of the internal battery.
struct BatteryStatus: Equatable {
    /// Charge as a whole percentage, 0...100.
    let percent: Int
    /// `true` when the Mac is running on battery power (not plugged in).
    let isOnBattery: Bool
}

/// Decides when low battery should switch sleep prevention off.
enum LowBatteryPolicy {
    /// Thresholds offered in Preferences, in percent.
    static let options = [5, 10, 15, 20]
    static let defaultThreshold = 10

    /// The threshold chosen in Preferences, falling back to the default for missing or unknown values.
    static func storedThreshold(_ defaults: UserDefaults = .standard) -> Int {
        let stored = defaults.integer(forKey: PreferenceKeys.lowBatteryThreshold)
        return self.options.contains(stored) ? stored : self.defaultThreshold
    }

    /// `true` when running on battery power at or below `threshold` percent.
    static func shouldDeactivate(_ status: BatteryStatus?, threshold: Int) -> Bool {
        guard let status, status.isOnBattery else { return false }
        return status.percent <= threshold
    }
}

/// Reports battery changes. Event driven (IOKit power source notifications), no polling.
final class BatteryMonitor {
    /// Called on the main run loop whenever the power source or charge level changes.
    var onChange: ((BatteryStatus?) -> Void)?

    private var runLoopSource: CFRunLoopSource?

    deinit {
        self.stop()
    }

    /// The internal battery's current state, or `nil` if this Mac has no battery.
    static func currentStatus() -> BatteryStatus? {
        guard
            let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else { return nil }

        for source in sources {
            guard
                let description = IOPSGetPowerSourceDescription(info, source)?
                    .takeUnretainedValue() as? [String: Any],
                description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
                let current = description[kIOPSCurrentCapacityKey] as? Int,
                let max = description[kIOPSMaxCapacityKey] as? Int,
                max > 0 else { continue }

            let state = description[kIOPSPowerSourceStateKey] as? String
            return BatteryStatus(percent: current * 100 / max, isOnBattery: state == kIOPSBatteryPowerValue)
        }
        return nil
    }

    func start() {
        guard self.runLoopSource == nil else { return }

        let context = Unmanaged.passUnretained(self).toOpaque()
        guard
            let source = IOPSNotificationCreateRunLoopSource({ context in
                guard let context else { return }
                let monitor = Unmanaged<BatteryMonitor>.fromOpaque(context).takeUnretainedValue()
                monitor.onChange?(BatteryMonitor.currentStatus())
            }, context)?.takeRetainedValue() else { return }

        // Common modes so changes are delivered while a menu is open.
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        self.runLoopSource = source
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            self.runLoopSource = nil
        }
    }
}
