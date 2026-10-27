import SwiftUI

// MARK: - Logo (şapkalı sihirli kavanoz)

struct MandirakeLogo: View {
    var size: CGFloat = 44

    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 200
            func r(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
                CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
            }
            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            let ink = GraphicsContext.Shading.color(Theme.ink)

            // zemin daire
            ctx.fill(Path(ellipseIn: r(4, 4, 192, 192)), with: .color(Theme.butter))

            // kavanoz gövdesi
            let jar = Path(roundedRect: r(58, 96, 84, 78), cornerRadius: 22 * s)
            ctx.fill(jar, with: .color(Theme.paper))
            ctx.stroke(jar, with: ink, lineWidth: 6 * s)

            // şapka: gövde, bant, kenar
            ctx.fill(Path(roundedRect: r(62, 30, 76, 58), cornerRadius: 9 * s), with: ink)
            ctx.fill(Path(r(62, 66, 76, 12)), with: .color(Theme.pink))
            ctx.fill(Path(roundedRect: r(42, 84, 116, 14), cornerRadius: 7 * s), with: ink)

            // gözler
            ctx.fill(Path(ellipseIn: r(80, 114, 8, 8)), with: ink)
            ctx.fill(Path(ellipseIn: r(112, 114, 8, 8)), with: ink)

            // ağız
            var mouth = Path()
            mouth.move(to: pt(100, 132))
            mouth.addCurve(to: pt(77, 137), control1: pt(92, 122), control2: pt(74, 126))
            mouth.addCurve(to: pt(100, 136), control1: pt(79, 143), control2: pt(90, 141))
            mouth.addCurve(to: pt(123, 137), control1: pt(110, 141), control2: pt(121, 143))
            mouth.addCurve(to: pt(100, 132), control1: pt(126, 126), control2: pt(108, 122))
            mouth.closeSubpath()
            ctx.fill(mouth, with: ink)

            // asa
            var wand = Path()
            wand.move(to: pt(150, 66))
            wand.addLine(to: pt(170, 44))
            ctx.stroke(wand, with: ink, style: StrokeStyle(lineWidth: 6 * s, lineCap: .round))

            // yıldız
            let starPts: [(CGFloat, CGFloat)] = [
                (176, 14), (180, 26), (192, 30), (180, 34),
                (176, 46), (172, 34), (160, 30), (172, 26)
            ]
            var star = Path()
            for (i, p) in starPts.enumerated() {
                if i == 0 { star.move(to: pt(p.0, p.1)) } else { star.addLine(to: pt(p.0, p.1)) }
            }
            star.closeSubpath()
            ctx.fill(star, with: .color(Theme.sun))
            ctx.stroke(star, with: ink, lineWidth: 3 * s)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Mandırake")
    }
}

// MARK: - Yoğurt kavanozu (gülen yüzlü, renkli kapaklı)

struct JarView: View {
    var lid: Color
    /// true: yoğurt dolu ve gülen yüzlü. false: yenmiş, boş cam.
    var full: Bool = true

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width / 40, size.height / 48)
            let ox = (size.width - 40 * s) / 2
            let oy = (size.height - 48 * s) / 2
            func r(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
                CGRect(x: ox + x * s, y: oy + y * s, width: w * s, height: h * s)
            }
            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: ox + x * s, y: oy + y * s) }
            let ink = GraphicsContext.Shading.color(Theme.ink)

            // cam gövde
            let body = Path(roundedRect: r(4.5, 10.5, 31, 33), cornerRadius: 10 * s)
            ctx.fill(body, with: .color(full ? Color(hex: 0xE8F2FF) : Color(hex: 0xF1F7FF)))
            ctx.stroke(body, with: ink, lineWidth: 2.2 * s)

            if full {
                // yoğurt
                ctx.fill(Path(roundedRect: r(7.5, 16, 25, 24), cornerRadius: 7.5 * s),
                         with: .color(Theme.paper))
                // gözler
                ctx.fill(Path(ellipseIn: r(13.3, 25.9, 3.4, 4.2)), with: ink)
                ctx.fill(Path(ellipseIn: r(23.3, 25.9, 3.4, 4.2)), with: ink)
                // yanaklar
                ctx.fill(Path(ellipseIn: r(9.3, 30.1, 4.6, 4.6)), with: .color(Theme.pink.opacity(0.6)))
                ctx.fill(Path(ellipseIn: r(26.1, 30.1, 4.6, 4.6)), with: .color(Theme.pink.opacity(0.6)))
                // gülümseme
                var smile = Path()
                smile.move(to: pt(17.6, 31.6))
                smile.addQuadCurve(to: pt(22.4, 31.6), control: pt(20, 34.4))
                ctx.stroke(smile, with: ink, style: StrokeStyle(lineWidth: 1.7 * s, lineCap: .round))
            } else {
                // boş camın yansıması
                var shine = Path()
                shine.move(to: pt(10, 18))
                shine.addLine(to: pt(10, 34))
                ctx.stroke(shine, with: .color(.white),
                           style: StrokeStyle(lineWidth: 3 * s, lineCap: .round))
            }

            // kapak
            let lidPath = Path(roundedRect: r(7, 2.5, 26, 9.5), cornerRadius: 4.5 * s)
            ctx.fill(lidPath, with: .color(lid))
            ctx.stroke(lidPath, with: ink, lineWidth: 2.2 * s)
            if full {
                var shine = Path()
                shine.move(to: pt(11.5, 6.2))
                shine.addLine(to: pt(21, 6.2))
                ctx.stroke(shine, with: .color(.white.opacity(0.6)),
                           style: StrokeStyle(lineWidth: 1.8 * s, lineCap: .round))
            }
        }
    }
}

/// Sıradaki kavanozun köşesindeki pırıltı (kapak renginde)
struct SparkleStar: View {
    var color: Color

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height) / 24
            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            var p = Path()
            p.move(to: pt(12, 2))
            p.addLine(to: pt(14.6, 9.4))
            p.addLine(to: pt(22, 12))
            p.addLine(to: pt(14.6, 14.6))
            p.addLine(to: pt(12, 22))
            p.addLine(to: pt(9.4, 14.6))
            p.addLine(to: pt(2, 12))
            p.addLine(to: pt(9.4, 9.4))
            p.closeSubpath()
            ctx.fill(p, with: .color(color))
            ctx.stroke(p, with: .color(Theme.ink),
                       style: StrokeStyle(lineWidth: 1.8 * s, lineJoin: .round))
        }
        .frame(width: 18, height: 18)
    }
}

// MARK: - Anne sütü saklama torbası

struct MilkBagView: View {
    let ml: Int

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width / 56, size.height / 72)
            let ox = (size.width - 56 * s) / 2
            let oy = (size.height - 72 * s) / 2
            func r(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
                CGRect(x: ox + x * s, y: oy + y * s, width: w * s, height: h * s)
            }
            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: ox + x * s, y: oy + y * s) }
            let ink = GraphicsContext.Shading.color(Theme.ink)

            // plastik torba gövdesi
            let bag = UnevenRoundedRectangle(topLeadingRadius: 3 * s, bottomLeadingRadius: 8 * s,
                                             bottomTrailingRadius: 8 * s, topTrailingRadius: 3 * s,
                                             style: .continuous).path(in: r(4, 5, 48, 65))
            ctx.fill(bag, with: .color(Color(hex: 0xE6F1FF)))

            // süt (ml'ye göre yükselir)
            let level = 34 * max(0.35, min(1, CGFloat(ml) / 150))
            let top = 67 - level
            var milk = Path()
            milk.move(to: pt(8, top))
            milk.addQuadCurve(to: pt(28, top), control: pt(18, top - 3))
            milk.addQuadCurve(to: pt(48, top), control: pt(38, top + 3))
            milk.addLine(to: pt(48, 61))
            milk.addQuadCurve(to: pt(42, 67), control: pt(48, 67))
            milk.addLine(to: pt(14, 67))
            milk.addQuadCurve(to: pt(8, 61), control: pt(8, 67))
            milk.closeSubpath()
            ctx.fill(milk, with: .color(.white))

            // ölçü çizgileri
            var ticks = Path()
            for (x1, x2, y) in [(41.0, 47.0, 35.0), (43.5, 47.0, 43.0), (41.0, 47.0, 51.0), (43.5, 47.0, 59.0)] {
                ticks.move(to: pt(CGFloat(x1), CGFloat(y)))
                ticks.addLine(to: pt(CGFloat(x2), CGFloat(y)))
            }
            ctx.stroke(ticks, with: .color(Theme.ink.opacity(0.45)),
                       style: StrokeStyle(lineWidth: 1.6 * s, lineCap: .round))

            // yazı alanı
            let label = Path(roundedRect: r(11, 21, 24, 9), cornerRadius: 3 * s)
            ctx.fill(label, with: .color(Theme.paper))
            ctx.stroke(label, with: ink, lineWidth: 1.6 * s)
            var scribble = Path()
            scribble.move(to: pt(14.5, 25.5))
            scribble.addLine(to: pt(27, 25.5))
            ctx.stroke(scribble, with: .color(Theme.ink.opacity(0.5)),
                       style: StrokeStyle(lineWidth: 1.6 * s, lineCap: .round))

            // pembe çift fermuar
            ctx.fill(Path(r(5.5, 6.5, 45, 11)), with: .color(Theme.pink))
            var zip = Path()
            zip.move(to: pt(5.5, 10.5)); zip.addLine(to: pt(50.5, 10.5))
            zip.move(to: pt(5.5, 13.5)); zip.addLine(to: pt(50.5, 13.5))
            ctx.stroke(zip, with: .color(Theme.paper), lineWidth: 1.6 * s)

            // dış çizgi
            ctx.stroke(bag, with: ink, style: StrokeStyle(lineWidth: 3 * s, lineJoin: .round))
        }
    }
}

// MARK: - Ayarlar simgesi (dişli + pırıltı)

struct GearIcon: View {
    var selected: Bool

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height) / 32
            let gear = selected ? Theme.sun : Theme.paper
            let spark = selected ? Theme.paper : Theme.sun

            // dişler
            for i in 0..<8 {
                var c = ctx
                c.translateBy(x: 16 * s, y: 16 * s)
                c.rotate(by: .degrees(Double(i) * 45))
                let tooth = Path(roundedRect: CGRect(x: -3 * s, y: -14.5 * s, width: 6 * s, height: 7 * s),
                                 cornerRadius: 2 * s)
                c.fill(tooth, with: .color(gear))
            }
            // gövde ve delik
            ctx.fill(Path(ellipseIn: CGRect(x: 5.5 * s, y: 5.5 * s, width: 21 * s, height: 21 * s)),
                     with: .color(gear))
            ctx.fill(Path(ellipseIn: CGRect(x: 9.6 * s, y: 9.6 * s, width: 12.8 * s, height: 12.8 * s)),
                     with: .color(Theme.ink))

            // ortadaki pırıltı
            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            var star = Path()
            star.move(to: pt(16, 10.8))
            star.addLine(to: pt(17.5, 14.5))
            star.addLine(to: pt(21.2, 16))
            star.addLine(to: pt(17.5, 17.5))
            star.addLine(to: pt(16, 21.2))
            star.addLine(to: pt(14.5, 17.5))
            star.addLine(to: pt(10.8, 16))
            star.addLine(to: pt(14.5, 14.5))
            star.closeSubpath()
            ctx.fill(star, with: .color(spark))
        }
        .frame(width: 32, height: 32)
    }
}
