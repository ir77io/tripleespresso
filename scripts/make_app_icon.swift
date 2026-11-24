#!/usr/bin/env swift
//
//  make_app_icon.swift
//  Draws the Triple Espresso app icon artwork.
//
//  Usage: swift scripts/make_app_icon.swift <layer.png> <flattened.png>
//    layer.png      transparent espresso cup for the Icon Composer layer (1024x1024)
//    flattened.png  same cup on the espresso-brown background (README / previews)
//

import AppKit

let S: CGFloat = 1024

func color(_ hex: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> NSBezierPath {
    NSBezierPath(ovalIn: NSRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
}

func drawCup() {
    // Soft contact shadow under the saucer
    color(0x000000, 0.25).setFill()
    ellipse(512, 292, 350, 62).fill()

    // Saucer
    let saucer = ellipse(512, 318, 340, 74)
    NSGradient(colors: [color(0xF7EBDD), color(0xD9C3A8)])!.draw(in: saucer, angle: -90)
    color(0xFFFFFF, 0.55).setFill()
    ellipse(512, 328, 250, 40).fill()
    color(0xCDB394).setFill()
    ellipse(512, 326, 190, 28).fill() // well the cup sits in

    // Handle (behind the body)
    let handle = NSBezierPath()
    handle.appendArc(withCenter: NSPoint(x: 722, y: 500), radius: 78, startAngle: 105, endAngle: -105, clockwise: true)
    handle.lineWidth = 38
    handle.lineCapStyle = .round
    color(0xE8D5BC).setStroke()
    handle.stroke()

    // Cup body: squat demitasse
    let body = NSBezierPath()
    body.move(to: NSPoint(x: 282, y: 590))
    body.curve(to: NSPoint(x: 512, y: 346),
               controlPoint1: NSPoint(x: 282, y: 440), controlPoint2: NSPoint(x: 380, y: 346))
    body.curve(to: NSPoint(x: 742, y: 590),
               controlPoint1: NSPoint(x: 644, y: 346), controlPoint2: NSPoint(x: 742, y: 440))
    body.close()
    NSGradient(colors: [color(0xFFF8EE), color(0xE9D6BD)])!.draw(in: body, angle: -90)

    // Rim and espresso surface
    let rim = ellipse(512, 590, 230, 62)
    NSGradient(colors: [color(0xFFFFFF), color(0xF1E2CE)])!.draw(in: rim, angle: -90)
    let surface = ellipse(512, 586, 196, 46)
    NSGradient(colors: [color(0xD9A064), color(0x8A4A22)])!
        .draw(in: surface, relativeCenterPosition: NSPoint(x: -0.2, y: 0.3))
    color(0x3A1B0B, 0.55).setFill()
    ellipse(512, 580, 110, 22).fill()

    // Three wisps of steam
    for (i, x) in [412, 512, 612].enumerated() {
        let x = CGFloat(x)
        let lift = CGFloat(i == 1 ? 40 : 0)
        let steam = NSBezierPath()
        steam.move(to: NSPoint(x: x, y: 690))
        steam.curve(to: NSPoint(x: x, y: 880 + lift),
                    controlPoint1: NSPoint(x: x + 70, y: 750), controlPoint2: NSPoint(x: x - 70, y: 820 + lift))
        steam.lineWidth = 26
        steam.lineCapStyle = .round
        color(0xFFFFFF, 0.9).setStroke()
        steam.stroke()
    }
}

func render(background: Bool, to path: String) throws {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(S), pixelsHigh: Int(S),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.shouldAntialias = true
    if background {
        NSGradient(colors: [color(0x6B3A1E), color(0x2A140A)])!
            .draw(in: NSRect(x: 0, y: 0, width: S, height: S), angle: -90)
    }
    drawCup()
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

guard CommandLine.arguments.count == 3 else {
    print("usage: make_app_icon.swift <layer.png> <flattened.png>")
    exit(1)
}
try render(background: false, to: CommandLine.arguments[1])
try render(background: true, to: CommandLine.arguments[2])
print("Wrote app icon artwork")
