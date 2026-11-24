#!/usr/bin/env swift
//
//  make_icons.swift
//  Generates the espresso-cup menu bar template icons (black on transparent).
//
//  Usage: swift scripts/make_icons.swift <output-dir>
//  Writes active.png, active@2x.png, inactive.png, inactive@2x.png (22x20 pt).
//

import AppKit

let size = CGSize(width: 22, height: 20)

/// Demitasse: squat bowl, small ring handle, wide flat saucer.
func drawCup(active: Bool) {
    let lw: CGFloat = 1.5
    NSColor.black.setFill()
    NSColor.black.setStroke()

    // Saucer
    let saucer = NSBezierPath(roundedRect: NSRect(x: 2.5, y: 2.2, width: 17, height: 1.7),
                              xRadius: 0.85, yRadius: 0.85)
    saucer.fill()

    // Bowl
    let bowl = NSBezierPath()
    bowl.move(to: NSPoint(x: 4.8, y: 11))
    bowl.line(to: NSPoint(x: 14.8, y: 11))
    bowl.curve(to: NSPoint(x: 9.8, y: 5.2),
               controlPoint1: NSPoint(x: 14.8, y: 7.2),
               controlPoint2: NSPoint(x: 12.8, y: 5.2))
    bowl.curve(to: NSPoint(x: 4.8, y: 11),
               controlPoint1: NSPoint(x: 6.8, y: 5.2),
               controlPoint2: NSPoint(x: 4.8, y: 7.2))
    bowl.close()

    if active {
        bowl.fill()
    } else {
        bowl.lineWidth = lw
        bowl.lineJoinStyle = .round
        bowl.stroke()
    }

    // Handle
    let handle = NSBezierPath()
    handle.appendArc(withCenter: NSPoint(x: 15.2, y: 8.5), radius: 2.2,
                     startAngle: 90, endAngle: -90, clockwise: true)
    handle.lineWidth = lw
    handle.lineCapStyle = .round
    handle.stroke()

    // Steam (active only): two short wisps
    if active {
        for x: CGFloat in [7.6, 11.8] {
            let steam = NSBezierPath()
            steam.move(to: NSPoint(x: x, y: 13.2))
            steam.curve(to: NSPoint(x: x, y: 18.2),
                        controlPoint1: NSPoint(x: x + 1.7, y: 14.8),
                        controlPoint2: NSPoint(x: x - 1.7, y: 16.6))
            steam.lineWidth = 1.3
            steam.lineCapStyle = .round
            steam.stroke()
        }
    }
}

func render(active: Bool, scale: Int, to url: URL) throws {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width) * scale, pixelsHigh: Int(size.height) * scale,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.shouldAntialias = true
    drawCup(active: active)
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: url)
}

let out = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
for (name, active) in [("active", true), ("inactive", false)] {
    try render(active: active, scale: 1, to: out.appendingPathComponent("\(name).png"))
    try render(active: active, scale: 2, to: out.appendingPathComponent("\(name)@2x.png"))
}
print("Wrote icons to \(out.path)")
