import SwiftUI
import UniformTypeIdentifiers

// MARK: - Ayarlar ana liste

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette

    var body: some View {
        NavigationStack {
            ZStack {
                palette.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(settings.t(.settingsT))
                            .font(AppFont.font(31, .black))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 4)
                            .padding(.bottom, 4)

                        row(.globe, settings.t(.langRow),
                            value: settings.lang == .tr ? "Türkçe" : "English") { LanguageSettings() }
                        row(.bottle, settings.t(.tabMilk), value: nil) { MilkSettings() }
                        row(.jar, settings.t(.tabYogurt), value: nil) { YogurtSettings() }
                        row(.backup, settings.t(.rowBackup), value: nil) { BackupSettings() }
                        row(.trash, settings.t(.rowReset), value: nil) { ResetSettings() }
                        row(.info, settings.t(.rowAbout), value: nil) { AboutSettings() }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func row<Destination: View>(_ icon: MIconName, _ title: String, value: String?,
                                        @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 14) {
                MIcon(name: icon, size: 30)
                Text(title)
                    .font(AppFont.font(20, .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 8)
                if let value {
                    Text(value)
                        .font(AppFont.font(16, .heavy))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .black))
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Theme.paper, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ortak parçalar

/// Alt sayfa kabuğu: başlık + kaydırılabilir içerik
private struct SettingsPage<Content: View>: View {
    @Environment(\.palette) private var palette
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            palette.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(title)
                        .font(AppFont.font(31, .black))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 4)
                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

/// Çerçeveli beyaz kart
private struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.paper, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: 3)
            )
    }
}

private func cardTitle(_ text: String) -> some View {
    Text(text).font(AppFont.font(18, .black))
}

private func hint(_ text: String) -> some View {
    Text(text)
        .font(AppFont.font(14, .bold))
        .foregroundStyle(Theme.muted)
        .fixedSize(horizontal: false, vertical: true)
}

/// Seçenek hapları (birim, ay sayısı…)
private struct ChipPicker<Value: Hashable>: View {
    let options: [(label: String, value: Value)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options.indices, id: \.self) { i in
                let on = options[i].value == selection
                Button { selection = options[i].value } label: {
                    Text(options[i].label)
                        .font(AppFont.font(16, .heavy))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(on ? Theme.paper : Theme.ink)
                        .padding(.horizontal, 12)
                        .frame(minWidth: 44, maxWidth: .infinity)
                        .frame(height: 38)
                        .background(on ? Theme.ink : Theme.paper, in: Capsule())
                        .overlay(Capsule().strokeBorder(Theme.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
    }
}

/// − değer + denetimi
private struct StepperRow: View {
    let title: String
    let valueText: String
    let canDec: Bool
    let canInc: Bool
    let dec: () -> Void
    let inc: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(AppFont.font(17, .heavy))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 6)
            stepButton("−", enabled: canDec, action: dec)
            Text(valueText)
                .font(AppFont.font(20, .black))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(minWidth: 54)
            stepButton("+", enabled: canInc, action: inc)
        }
    }

    private func stepButton(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(AppFont.font(22, .black))
                .foregroundStyle(Theme.ink)
                .frame(width: 40, height: 40)
                .background(Theme.paper, in: Circle())
                .overlay(Circle().strokeBorder(Theme.ink, lineWidth: 2.5))
                .opacity(enabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Alttaki büyük aksiyon butonu
private struct ActionButton: View {
    @Environment(\.palette) private var palette
    let title: String
    var destructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.font(18, .black))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(destructive ? Theme.pink : palette.btn, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.ink, lineWidth: destructive ? 2.5 : 0))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dil

struct LanguageSettings: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        SettingsPage(title: settings.t(.langT)) {
            option(.tr, code: "TR", color: Theme.pink, name: "Türkçe")
            option(.en, code: "EN", color: Theme.sky, name: "English")
        }
    }

    private func option(_ lang: Lang, code: String, color: Color, name: String) -> some View {
        let on = settings.lang == lang
        return Button {
            settings.lang = lang
        } label: {
            HStack(spacing: 14) {
                Text(code)
                    .font(AppFont.font(14, .black))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 38, height: 38)
                    .background(color, in: Circle())
                    .overlay(Circle().strokeBorder(Theme.ink, lineWidth: 2.5))
                Text(name).font(AppFont.font(21, .black))
                Spacer()
                if on {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .black))
                }
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(on ? Theme.sun : Theme.paper,
                        in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

// MARK: - Anne sütü ayarları

struct MilkSettings: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        SettingsPage(title: settings.t(.tabMilk)) {
            SettingsCard {
                cardTitle(settings.t(.unitT))
                ChipPicker(options: [("ml", MilkUnit.ml), ("fl oz", MilkUnit.floz)],
                           selection: $settings.unit)
            }
            SettingsCard {
                cardTitle(settings.t(.mAlertT))
                ChipPicker(options: [
                    (settings.t(.mAlertOff), 0),
                    (settings.t(.monthsN, ["n": "1"]), 1),
                    (settings.t(.monthsN, ["n": "2"]), 2),
                    (settings.t(.monthsN, ["n": "3"]), 3),
                    (settings.t(.monthsN, ["n": "6"]), 6)
                ], selection: $settings.milkAlertMonths)
                hint(settings.t(.mAlertHint))
            }
        }
    }
}

// MARK: - Yoğurt ayarları

struct YogurtSettings: View {
    @EnvironmentObject private var settings: AppSettings

    /// Dakika <-> Date dönüşümü (DatePicker için)
    private var reminderDate: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: settings.reminderMinutes / 60,
                                      minute: settings.reminderMinutes % 60,
                                      second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                settings.reminderMinutes = (c.hour ?? 12) * 60 + (c.minute ?? 0)
            }
        )
    }

    var body: some View {
        SettingsPage(title: settings.t(.tabYogurt)) {
            SettingsCard {
                cardTitle(settings.t(.remindT))
                Toggle(isOn: $settings.reminderOn) {
                    Text(settings.t(.remindOn)).font(AppFont.font(17, .heavy))
                }
                .tint(Theme.ink)
                DatePicker(selection: reminderDate, displayedComponents: .hourAndMinute) {
                    Text(settings.t(.remindTime)).font(AppFont.font(17, .heavy))
                }
                .environment(\.locale, settings.lang.locale)
                .tint(Theme.ink)
                .disabled(!settings.reminderOn)
                .opacity(settings.reminderOn ? 1 : 0.4)
                hint(settings.t(.remindHint))
            }
            SettingsCard {
                StepperRow(title: settings.t(.eatTimeT),
                           valueText: String(format: "%02d:00", settings.eatHour),
                           canDec: settings.eatHour > 0, canInc: settings.eatHour < 23,
                           dec: { settings.eatHour -= 1 }, inc: { settings.eatHour += 1 })
                StepperRow(title: settings.t(.perDayT),
                           valueText: "\(settings.jarsPerDay)",
                           canDec: settings.jarsPerDay > 1, canInc: settings.jarsPerDay < 5,
                           dec: { settings.jarsPerDay -= 1 }, inc: { settings.jarsPerDay += 1 })
                hint(settings.t(.rulesHint))
            }
        }
    }
}

// MARK: - Yedekleme

struct BackupSettings: View {
    @EnvironmentObject private var store: YogurtStore
    @EnvironmentObject private var milk: MilkStore
    @EnvironmentObject private var settings: AppSettings

    @State private var exporting = false
    @State private var importing = false
    @State private var document = BackupDocument(payload: BackupPayload(batches: [], bags: []))
    @State private var pending: BackupPayload?
    @State private var message: String?

    var body: some View {
        SettingsPage(title: settings.t(.rowBackup)) {
            SettingsCard {
                cardTitle(settings.t(.exportT))
                hint(settings.t(.exportS))
                ActionButton(title: settings.t(.exportT)) {
                    document = BackupDocument(payload: BackupPayload(
                        batches: store.batches,
                        bags: milk.bags,
                        fermentStart: store.fermentStart,
                        lastFermentMinutes: store.lastFermentMinutes))
                    exporting = true
                }
            }
            SettingsCard {
                cardTitle(settings.t(.importT))
                hint(settings.t(.importS))
                ActionButton(title: settings.t(.importT)) { importing = true }
            }
            if let message {
                iconText(message, size: 18)
                    .font(AppFont.font(16, .heavy))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 4)
            }
        }
        .fileExporter(isPresented: $exporting, document: document,
                      contentType: .json, defaultFilename: "Mandirake-yedek") { result in
            if case .success = result { message = settings.t(.exportOk) }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            guard case .success(let url) = result else { return }
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            if let data = try? Data(contentsOf: url),
               let payload = try? BackupDocument.decode(data) {
                pending = payload
            } else {
                message = settings.t(.importFail)
            }
        }
        .alert(settings.t(.importAsk), isPresented: Binding(
            get: { pending != nil },
            set: { if !$0 { pending = nil } })
        ) {
            Button(settings.t(.cancel), role: .cancel) { pending = nil }
            Button(settings.t(.yes), role: .destructive) {
                if let p = pending {
                    store.replaceAll(batches: p.batches, fermentStart: p.fermentStart,
                                     lastFermentMinutes: p.lastFermentMinutes)
                    milk.replaceAll(bags: p.bags)
                    message = settings.t(.importOk)
                }
                pending = nil
            }
        }
    }
}

// MARK: - Verileri sıfırla

struct ResetSettings: View {
    @EnvironmentObject private var store: YogurtStore
    @EnvironmentObject private var milk: MilkStore
    @EnvironmentObject private var settings: AppSettings

    private enum Target: Identifiable {
        case yogurt, milk
        var id: Self { self }
    }

    @State private var target: Target?

    var body: some View {
        SettingsPage(title: settings.t(.rowReset)) {
            SettingsCard {
                ActionButton(title: settings.t(.resetYog), destructive: true) { target = .yogurt }
                ActionButton(title: settings.t(.resetMilk), destructive: true) { target = .milk }
            }
        }
        .alert(settings.t(.resetAsk), isPresented: Binding(
            get: { target != nil },
            set: { if !$0 { target = nil } })
        ) {
            Button(settings.t(.cancel), role: .cancel) { target = nil }
            Button(settings.t(.del), role: .destructive) {
                switch target {
                case .yogurt: store.resetAll()
                case .milk: milk.resetAll()
                case nil: break
                }
                target = nil
            }
        }
    }
}

// MARK: - Hakkında

/// App Store'a göndermeden önce kendi bilgilerinle değiştir.
enum AppInfo {
    static let privacyURL = URL(string: "https://alpp.studio/mandirake/privacy/")!
    static let contactEmail = "help@alpp.studio"
}

struct AboutSettings: View {
    @EnvironmentObject private var settings: AppSettings

    private var version: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        SettingsPage(title: settings.t(.rowAbout)) {
            SettingsCard {
                HStack {
                    Text(settings.t(.aboutVersion)).font(AppFont.font(17, .heavy))
                    Spacer()
                    Text(version).font(AppFont.font(17, .black))
                }
                Link(destination: AppInfo.privacyURL) {
                    linkRow(settings.t(.aboutPrivacy), "arrow.up.right")
                }
                Link(destination: URL(string: "mailto:\(AppInfo.contactEmail)")!) {
                    linkRow(settings.t(.aboutContact), "envelope")
                }
            }
            hint(settings.t(.aboutNote)).padding(.horizontal, 4)
        }
    }

    private func linkRow(_ title: String, _ symbol: String) -> some View {
        HStack {
            Text(title).font(AppFont.font(17, .heavy))
            Spacer()
            Image(systemName: symbol).font(.system(size: 15, weight: .black))
        }
        .foregroundStyle(Theme.ink)
    }
}
