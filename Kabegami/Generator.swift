//
//  Generator.swift
//  Kabegami
//
//  Created by Victor Gama on 29/11/21.
//

import Cocoa

class Generator {
    func random() -> CGFloat { CGFloat.random(in: 0.0 ... 1.0) }

    func makeImage() -> NSImage { makeImages(quantity: 1)[0] }

    func makeImages(quantity q: Int) -> [NSImage] {
        let width = CGFloat(1920 * 2)
        let height = CGFloat(1080 * 2)

        var segments = 1 + floor(random() * 9.0)
        if random() < 0.5 {
            segments = 200
        }

        let layers = 3 + Int(floor(random() * 10.0))
        let hueStart = CGFloat(360.0 * random())
        let hueIncrement = 20.0 - (40.0 * random())
        let light = 15.0 + (45.0 * random())
        let lightIncrement = (random() < 0.5)
            ? (2.0 + (4.0 * random()))
            : -(2.0 + (4.0 * random()))

        var result: [NSImage] = []

        for _ in 0 ..< q {
            let wl = width / (random() * 10.0) + 5.0
            let ampl = (0.1 * wl) + (0.9 * wl) * random()
            let offset = width * random()
            let offsetIncrement = width / 20.0 + (width / 10.0) * random()
            let sat = 10.0 + (30.0 * random())

            let img = NSImage(size: NSSize(width: width, height: height))
            img.lockFocus()

            let ctx = NSGraphicsContext.current!.cgContext
            ctx.saveGState()
            ctx.translateBy(x: 0, y: height)
            ctx.scaleBy(x: 1, y: -1)

            var color = NSColor(calibratedHue: hueStart / 360.0, saturation: sat / 100.0, brightness: light / 100.0, alpha: 1)
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

            for l in 0 ..< layers {
                let cgL = CGFloat(l)
                let h = hueStart + ((cgL + 1.0) * hueIncrement)
                let s = sat
                let v = light + ((cgL + 1.0) * lightIncrement)
                color = NSColor(calibratedHue: h / 360.0, saturation: s / 100.0, brightness: v / 100.0, alpha: 1)
                ctx.setFillColor(color.cgColor)

                ctx.beginPath()
                let layerOffset = offset + (offsetIncrement * cgL)
                let offsetY = (cgL + 0.5) * (height / CGFloat(layers))
                let startY = offsetY + (ampl * sin(layerOffset / wl))
                ctx.move(to: CGPoint(x: 0, y: startY))
                for i in 0 ... Int(segments) {
                    let x = CGFloat(i) * (width / segments)
                    ctx.addLine(to: CGPoint(x: x, y: startY + (ampl * sin((layerOffset + x) / wl))))
                }
                ctx.addLine(to: CGPoint(x: width, y: height))
                ctx.addLine(to: CGPoint(x: 0, y: height))
                ctx.addLine(to: CGPoint(x: 0, y: startY))
                ctx.fillPath()
            }

            ctx.restoreGState()
            img.unlockFocus()
            result.append(img)
        }

        return result
    }
}
