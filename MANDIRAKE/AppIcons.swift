import SwiftUI

// MARK: - Emoji yerine Mandırake ikonları
// İkon verisi AppIconParts.swift içinde (24x24 ızgara, sadece M L H V C Q Z komutları).

/// Basit SVG yol çözümleyici (mutlak komutlar: M L H V C Q Z)
private enum SVGPath {
    static func make(_ d: String) -> Path {
        let spaced = d.map { $0.isLetter ? " \($0) " : String($0) }.joined()
        let tokens = spaced.split(whereSeparator: { $0 == " " || $0 == "," }).map(String.init)
        var path = Path()
        var cur = CGPoint.zero
        var cmd = ""
        var i = 0

        func num() -> CGFloat {
            defer { i += 1 }
            return CGFloat(Double(tokens[i]) ?? 0)
        }

        while i < tokens.count {
            if let first = tokens[i].first, first.isLetter {
                cmd = tokens[i]
                i += 1
                if cmd == "Z" {
                    path.closeSubpath()
                    continue
                }
            }
            switch cmd {
            case "M":
                cur = CGPoint(x: num(), y: num())
                path.move(to: cur)
                cmd = "L"
            case "L":
                cur = CGPoint(x: num(), y: num())
                path.addLine(to: cur)
            case "H":
                cur = CGPoint(x: num(), y: cur.y)
                path.addLine(to: cur)
            case "V":
                cur = CGPoint(x: cur.x, y: num())
                path.addLine(to: cur)
            case "C":
                let c1 = CGPoint(x: num(), y: num())
                let c2 = CGPoint(x: num(), y: num())
                cur = CGPoint(x: num(), y: num())
                path.addCurve(to: cur, control1: c1, control2: c2)
            case "Q":
                let c = CGPoint(x: num(), y: num())
                cur = CGPoint(x: num(), y: num())
                path.addQuadCurve(to: cur, control: c)
            default:
                i += 1
            }
        }
        return path
    }
}

private struct SVGShape: Shape {
    let d: String

    func path(in rect: CGRect) -> Path {
        let s = rect.width / 24
        return SVGPath.make(d).applying(CGAffineTransform(scaleX: s, y: s))
    }
}

/// Tek bir ikon. Renkleri kendi içinde (lacivert çizgi + pastel dolgu).
struct MIcon: View {
    let name: MIconName
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            ForEach(Array(name.parts.enumerated()), id: \.offset) { _, part in
                if let fill = part.fill {
                    SVGShape(d: part.d).fill(Color(hex: fill))
                }
                if let stroke = part.stroke {
                    SVGShape(d: part.d)
                        .stroke(Color(hex: stroke),
                                style: StrokeStyle(lineWidth: part.width * size / 24,
                                                   lineCap: .round, lineJoin: .round))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

/// İkonları metnin içine gömmek için resme çevirir (bir kez çizilir, saklanır)
@MainActor
private enum IconImages {
    static var cache: [String: Image] = [:]

    static func image(_ name: MIconName, size: CGFloat) -> Image {
        let key = "\(name.rawValue)-\(Int(size))"
        if let hit = cache[key] { return hit }
        let renderer = ImageRenderer(content: MIcon(name: name, size: size))
        renderer.scale = 3
        let image = renderer.uiImage.map { Image(uiImage: $0) } ?? Image(systemName: "circle")
        cache[key] = image
        return image
    }
}

/// "[[bottle]] Yeni süt" gibi metinleri, ikonu satır içine koyarak gösterir.
/// Kullanılabilir adlar: MIconName içindeki tüm ikonlar.
@MainActor
func iconText(_ string: String, size: CGFloat = 20) -> Text {
    var result = Text("")
    var rest = Substring(string)
    while let open = rest.range(of: "[[") {
        result = result + Text(String(rest[..<open.lowerBound]))
        let afterOpen = rest[open.upperBound...]
        guard let close = afterOpen.range(of: "]]") else {
            rest = rest[open.lowerBound...]
            break
        }
        let name = String(afterOpen[..<close.lowerBound])
        if let icon = MIconName(rawValue: name) {
            result = result + Text(IconImages.image(icon, size: size))
                .baselineOffset(-size * 0.16)
        }
        rest = afterOpen[close.upperBound...]
    }
    return result + Text(String(rest))
}
