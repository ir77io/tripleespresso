//
//  SleepPreventionManager.swift
//  TripleEspresso
//
//  Created by Dominic Rodemer on 11.11.25.
//

import AppKit
import Foundation
import IOKit.pwr_mgt
import os

/// Manages the core functionality of preventing system sleep.
///
/// A single power assertion is held for as long as sleep prevention is wanted.
/// It has no timeout, so there is never a window where the system is unprotected.
/// If the app quits or crashes, the kernel releases the assertion automatically.
final class SleepPreventionManager {
    static let shared = SleepPreventionManager()

    private static let log = Logger(subsystem: "io.ir77.tripleespresso", category: "SleepPrevention")

    private var sleepAssertionID: IOPMAssertionID?

    /// Whether the user wants sleep prevented (independent of the session being active).
    private var wantsSleepPrevented = false
    private var isUserSessionActive = true

    private init() {
        self.setupWorkspaceNotifications()
    }

    deinit {
        releaseSleepAssertion()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Prevents the system from sleeping
    func preventSleep() {
        self.wantsSleepPrevented = true
        self.updateAssertion()
    }

    /// Allows the system to sleep normally
    func allowSleep() {
        self.wantsSleepPrevented = false
        self.updateAssertion()
    }

    // MARK: - Private Methods

    /// Brings the held assertion in line with the desired state. Safe to call repeatedly.
    private func updateAssertion() {
        if self.wantsSleepPrevented, self.isUserSessionActive {
            self.acquireSleepAssertion()
        } else {
            self.releaseSleepAssertion()
        }
    }

    private func acquireSleepAssertion() {
        guard self.sleepAssertionID == nil else { return }

        var assertionID: IOPMAssertionID = 0
        let reason = String(localized: "Triple Espresso prevents sleep") as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        if result == kIOReturnSuccess {
            self.sleepAssertionID = assertionID
        } else {
            Self.log.error("Failed to create sleep assertion (IOReturn \(result, privacy: .public))")
        }
    }

    private func releaseSleepAssertion() {
        guard let assertionID = sleepAssertionID else { return }
        IOPMAssertionRelease(assertionID)
        self.sleepAssertionID = nil
    }

    private func setupWorkspaceNotifications() {
        let notificationCenter = NSWorkspace.shared.notificationCenter

        notificationCenter.addObserver(
            self,
            selector: #selector(self.sessionDidResignActive),
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(self.sessionDidBecomeActive),
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )
    }

    @objc
    private func sessionDidResignActive() {
        self.isUserSessionActive = false
        self.updateAssertion()
    }

    @objc
    private func sessionDidBecomeActive() {
        self.isUserSessionActive = true
        self.updateAssertion()
    }
}
