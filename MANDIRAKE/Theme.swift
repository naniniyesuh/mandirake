import SwiftUI

// MARK: - Renkler

enum Theme {
    static let cream   = Color(hex: 0xFFF8EC)
    static let paper   = Color(hex: 0xFFFDF7)
    static let butter  = Color(hex: 0xFFE9B8)
    static let pink    = Color(hex: 0xFF8FA3)
    static let sun     = Color(hex: 0xFFD66B)
    static let ink     = Color(hex: 0x2B2A5E)
    static let muted   = Color(hex: 0x5A5985)

    // Yoğurt sayfasının soğuk tonları
    static let coolBG  = Color(hex: 0xEDF3FF)
    static let sky     = Color(hex: 0xA9D8FF)
    static let skySoft = Color(hex: 0xD6EBFF)
    static let lilac   = Color(hex: 0xCFC4FF)

    // Kavanoz kapak renkleri
    static let mint    = Color(hex: 0x73CDB3)
    static let violet  = Color(hex: 0xA99BEB)
    static let blue    = Color(hex: 0x7DB8F5)
    static let lids: [Color] = [pink, sun, mint, violet, blue]
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

/// Sayfaya göre değişen renk takımı.
/// Anne sütü, Notlar, Ayarlar: sıcak (krem, sarı, pembe). Yoğurt: soğuk (gök mavisi, leylak).
struct Palette: Sendable {
    let bg: Color        // sayfa zemini
    let acc: Color       // koyu kart üzerindeki vurgu rengi
    let accSoft: Color   // açık kart rengi
    let btn: Color       // ana buton
    let hl: Color        // uyarı / vurgu kartı

    static let warm = Palette(bg: Theme.cream, acc: Theme.sun, accSoft: Theme.butter,
                              btn: Theme.pink, hl: Theme.sun)
    static let cool = Palette(bg: Theme.coolBG, acc: Theme.sky, accSoft: Theme.skySoft,
                              btn: Theme.sky, hl: Theme.sky)
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.warm
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

// MARK: - Yazı tipi
// Nunito projeye eklenmişse o kullanılır, eklenmemişse iOS'in yuvarlak sistem
// yazı tipi (SF Rounded) kullanılır. İkisi de Türkçe karakterleri tam destekler.

enum AppFont {
    private static let hasNunito = UIFont.familyNames.contains("Nunito")

    static func font(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        if hasNunito { return .custom("Nunito", size: size).weight(weight) }
        return .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Ortak görünümler

extension View {
    /// Çerçeveli, kâğıt beyazı input görünümü
    func inputBox(radius: CGFloat = 18, border: CGFloat = 2) -> some View {
        self
            .background(Theme.paper, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: border)
            )
    }
}

/// Logo + MANDIRAKE + sayfa adı
struct PageHeader: View {
    let pageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 10) {
                MandirakeLogo(size: 44)
                Text("MANDIRAKE")
                    .font(AppFont.font(28, .black))
                    .foregroundStyle(Theme.ink)
            }
            Text(pageName)
                .font(AppFont.font(15, .black))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

/// Alttaki büyük yuvarlak ana buton
struct PillButton: View {
    @Environment(\.palette) private var palette
    let title: String
    var systemImage: String? = "plus"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .black))
                }
                Text(title)
                    .font(AppFont.font(21, .black))
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(palette.btn, in: Capsule())
        }
    }
}

/// Kart: başlık + alt yazı
struct InfoCard: View {
    enum Style { case highlight, soft, paper }

    @Environment(\.palette) private var palette
    let title: String
    let subtitle: String
    let style: Style

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            iconText(title, size: 24).font(AppFont.font(21, .heavy))
            iconText(subtitle, size: 18).font(AppFont.font(16, .bold))
        }
        .foregroundStyle(Theme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(fill, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            if style == .paper {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: 3)
            }
        }
    }

    private var fill: Color {
        switch style {
        case .highlight: return palette.hl
        case .soft: return palette.accSoft
        case .paper: return Theme.paper
        }
    }
}

/// Lacivert ana kart (Anne sütü toplamı, yoğurt sayısı)
struct HeroCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Theme.ink, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

/// Beyaz, çerçeveli kart (kavanozlar, torbalar)
struct OutlinedCard<Content: View>: View {
    let fill: Color
    let content: Content

    init(fill: Color = .white, @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: 3)
            )
    }
}
