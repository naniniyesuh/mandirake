import SwiftUI
import Combine

// MARK: - Diller

enum Lang: String, CaseIterable, Identifiable {
    case tr, en

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: self == .tr ? "tr_TR" : "en_GB") }
}

enum Key: String {
    // Sekmeler
    case tabMilk, tabYogurt, tabNotes, tabSettings
    // Yoğurt sayfası
    case jarsLeft, batchLbl
    case noYogT, noYogS, outT, outS, todayT, todayS, lastT, lastS, lastSOff
    case addYog
    case swT, swIdle, swLast, swRun, swStart, swStop
    // Yeni yoğurt formu
    case yTitle, yQ, dec, inc, yDate, endT, endOn, endOff, yNotes, yPh
    case save, cancel, done
    // Anne sütü sayfası
    case mTotal, mMeta, mNone, noMilkT, noMilkS, bagsT, bagsHint
    case pickOne, pickN, mlTotal, no, yes, toast, bag1, bagN, addMilk
    case mTitle, mQ, mWhen, mDate, mNotes, mPh
    // Notlar
    case notesTitle, fAll, fMilk, fYog, empty
    case left, closed, frozen, thawed, noNote, del, back, jarsN, notesLbl
    // Ayarlar
    case langT, langRow, settingsT
    case rowBackup, rowReset, rowAbout
    case remindT, remindOn, remindTime, remindHint
    case eatTimeT, perDayT, rulesHint
    case unitT, mAlertT, mAlertOff, mAlertHint, monthsN
    case exportT, exportS, importT, importS, importAsk, importOk, importFail, exportOk
    case resetYog, resetMilk, resetAsk
    case aboutVersion, aboutPrivacy, aboutContact, aboutNote
    case milkAlertTitle, milkAlertBody
    // Bildirim
    case notifTitle, notifBody
}

enum L10n {
    static func text(_ key: Key, _ lang: Lang, _ args: [String: String] = [:]) -> String {
        var s = (lang == .tr ? tr[key] : en[key]) ?? key.rawValue
        for (k, v) in args {
            s = s.replacingOccurrences(of: "{\(k)}", with: v)
        }
        return s
    }

    static let tr: [Key: String] = [
        .tabMilk: "Anne sütü", .tabYogurt: "Yoğurt", .tabNotes: "Notlar", .tabSettings: "Ayarlar",
        .jarsLeft: "kavanoz kaldı", .batchLbl: "Bu batch · {d}",
        .noYogT: "[[jar]] Henüz yoğurt yok", .noYogS: "Aşağıdaki butonla ilk yoğurdunu ekle!",
        .outT: "[[alert]] Kavanozlar bitti!", .outS: "Yeni yoğurt mayalama zamanı.",
        .todayT: "[[alarm]] Son kavanoz bugün!", .todayS: "Yeni yoğurdu bugün mayala ki yarın {t} için hazır olsun.",
        .lastT: "[[calendar]] Son kavanoz: {d}", .lastS: "Mayalama hatırlatması: o gün {t} [[bell]]", .lastSOff: "Hatırlatıcı kapalı",
        .addYog: "Yeni yoğurt ekle",
        .swT: "[[timer]] Mayalama sayacı", .swIdle: "Yoğurdu mayaladığın an başlat.",
        .swLast: "Son mayalama: {t}", .swRun: "{t}'dır yoğurt mayalanıyor",
        .swStart: "Başlat", .swStop: "Dolaba kaldırdım",
        .yTitle: "[[bowl]] Yeni yoğurt yaptım!", .yQ: "Kaç kavanoz?", .dec: "Azalt", .inc: "Arttır",
        .yDate: "Yapılış tarihi", .endT: "Mevcut kavanozları bitir",
        .endOn: "Kalan {n} kavanoz kaldırılacak, yeni yoğurt hemen başlayacak.",
        .endOff: "Kapalıyken yeni yoğurt, eldeki {n} kavanoz bitince başlar.",
        .yNotes: "[[note]] Bu yoğurdun notları", .yPh: "Örn: X marka süt, 8 saat mayaladım, oda ısısı soğuktu…",
        .save: "Kaydet", .cancel: "Vazgeç", .done: "Tamam",
        .mTotal: "[[ice]] Buzlukta toplam", .mMeta: "{n} torba · en eski {d}", .mNone: "Henüz dondurulmuş süt yok",
        .noMilkT: "[[bottle]] Buzlukta süt yok", .noMilkS: "Aşağıdaki butonla ilk sağımını ekle!",
        .bagsT: "Dondurulmuş torbalar", .bagsHint: "[[star]] en eski torba. Çözmek istediklerine dokun.",
        .pickOne: "Bu sütü çözmek istiyor musun?", .pickN: "Bu {n} torbayı çözmek istiyor musun?",
        .mlTotal: "{ml} toplam", .no: "Hayır", .yes: "Evet",
        .toast: "[[bottle]] {b} çözüldü, stoktan {ml} düşüldü", .bag1: "1 torba", .bagN: "{n} torba",
        .addMilk: "Yeni anne sütü ekle",
        .mTitle: "[[bottle]] Yeni süt sağdım!", .mQ: "Kaç {u}?", .mDate: "[[ice]] Buzluğa konma zamanı", .mWhen: "[[ice]] Şimdi buzluğa konmuş olarak kaydedilir",
        .mNotes: "[[note]] Bu sütün notu", .mPh: "Örn: sabah sağımı, buzdolabında 2 saat bekledi…",
        .notesTitle: "Notlar", .fAll: "Tümü", .fMilk: "Anne sütü", .fYog: "Yoğurt",
        .empty: "Henüz not yok.\nİlk kaydını ekleyince burada görünecek!",
        .left: "{n} kaldı", .closed: "kapatıldı", .frozen: "buzlukta", .thawed: "çözüldü",
        .noNote: "Not eklenmemiş", .del: "Sil", .back: "Notlar", .jarsN: "[[jar]] {n} kavanoz",
        .notesLbl: "[[note]] Notlar",
        .langT: "Dil / Language", .langRow: "Dil", .settingsT: "Ayarlar",
        .rowBackup: "Yedekleme", .rowReset: "Verileri sıfırla", .rowAbout: "Hakkında",
        .remindT: "Son kavanoz hatırlatıcısı", .remindOn: "Hatırlatıcı", .remindTime: "Hatırlatma saati",
        .remindHint: "Son kavanozun yeneceği gün bu saatte bildirim gelir.",
        .eatTimeT: "Günlük yeme saati", .perDayT: "Günde kaç kavanoz",
        .rulesHint: "Değişiklik stok hesabının tamamına uygulanır.",
        .unitT: "Birim", .mAlertT: "Buzluk süresi uyarısı", .mAlertOff: "Kapalı",
        .mAlertHint: "Bir torba seçtiğin süredir buzluktaysa bildirim gelir.", .monthsN: "{n} ay",
        .exportT: "Verileri dışa aktar",
        .exportS: "Yoğurt ve anne sütü kayıtlarını dosya olarak kaydet. iCloud Drive'a da kaydedebilirsin.",
        .importT: "Yedekten geri yükle", .importS: "Mevcut kayıtlar yedekteki kayıtlarla değiştirilir.",
        .importAsk: "Mevcut tüm kayıtlar silinip yedektekiler yüklensin mi?",
        .importOk: "[[check]] Yedek yüklendi", .importFail: "Dosya okunamadı", .exportOk: "[[check]] Yedek kaydedildi",
        .resetYog: "Yoğurt kayıtlarını sil", .resetMilk: "Anne sütü kayıtlarını sil",
        .resetAsk: "Bu işlem geri alınamaz. Silinsin mi?",
        .aboutVersion: "Sürüm", .aboutPrivacy: "Gizlilik politikası", .aboutContact: "İletişim",
        .aboutNote: "Verilerin yalnızca bu telefonda saklanır, hiçbir yere gönderilmez.",
        .milkAlertTitle: "Dondurulmuş süt hatırlatması 🍼",
        .milkAlertBody: "{a} süt {n} aydır buzlukta.",
        .notifTitle: "Yoğurt mayalama vakti! 🥛",
        .notifBody: "Bugün son kavanoz yeniyor. Yarın için yeni yoğurdu şimdi mayala!"
    ]

    static let en: [Key: String] = [
        .tabMilk: "Breast milk", .tabYogurt: "Yogurt", .tabNotes: "Notes", .tabSettings: "Settings",
        .jarsLeft: "jars left", .batchLbl: "This batch · {d}",
        .noYogT: "[[jar]] No yogurt yet", .noYogS: "Add your first yogurt with the button below!",
        .outT: "[[alert]] Out of jars!", .outS: "Time to start a new batch of yogurt.",
        .todayT: "[[alarm]] Last jar is today!", .todayS: "Start the new yogurt today so it is ready for {t} tomorrow.",
        .lastT: "[[calendar]] Last jar: {d}", .lastS: "Reminder to start a new batch: that day at {t} [[bell]]", .lastSOff: "Reminder is off",
        .addYog: "Add new yogurt",
        .swT: "[[timer]] Fermentation timer", .swIdle: "Start it the moment you set the yogurt.",
        .swLast: "Last fermentation: {t}", .swRun: "Yogurt has been fermenting for {t}",
        .swStart: "Start", .swStop: "Put in the fridge",
        .yTitle: "[[bowl]] I made new yogurt!", .yQ: "How many jars?", .dec: "Decrease", .inc: "Increase",
        .yDate: "Date made", .endT: "Finish current jars",
        .endOn: "The remaining {n} jars will be removed and the new yogurt starts right away.",
        .endOff: "When off, the new yogurt starts once your {n} jars are finished.",
        .yNotes: "[[note]] Notes for this yogurt", .yPh: "e.g. brand X milk, fermented 8 hours, the room was cold…",
        .save: "Save", .cancel: "Cancel", .done: "Done",
        .mTotal: "[[ice]] Total in the freezer", .mMeta: "{n} bags · oldest {d}", .mNone: "No frozen milk yet",
        .noMilkT: "[[bottle]] No milk in the freezer", .noMilkS: "Add your first pumped milk with the button below!",
        .bagsT: "Frozen bags", .bagsHint: "[[star]] oldest bag. Tap the ones you want to thaw.",
        .pickOne: "Do you want to thaw this milk?", .pickN: "Do you want to thaw these {n} bags?",
        .mlTotal: "{ml} total", .no: "No", .yes: "Yes",
        .toast: "[[bottle]] {b} thawed, {ml} removed from stock", .bag1: "1 bag", .bagN: "{n} bags",
        .addMilk: "Add new breast milk",
        .mTitle: "[[bottle]] I pumped new milk!", .mQ: "How many {u}?", .mDate: "[[ice]] Put in the freezer at", .mWhen: "[[ice]] Saved as put in the freezer right now",
        .mNotes: "[[note]] Note for this milk", .mPh: "e.g. morning pump, waited 2 hours in the fridge…",
        .notesTitle: "Notes", .fAll: "All", .fMilk: "Breast milk", .fYog: "Yogurt",
        .empty: "No notes yet.\nThey will appear here once you add your first entry!",
        .left: "{n} left", .closed: "closed", .frozen: "frozen", .thawed: "thawed",
        .noNote: "No note added", .del: "Delete", .back: "Notes", .jarsN: "[[jar]] {n} jars",
        .notesLbl: "[[note]] Notes",
        .langT: "Dil / Language", .langRow: "Language", .settingsT: "Settings",
        .rowBackup: "Backup", .rowReset: "Reset data", .rowAbout: "About",
        .remindT: "Last jar reminder", .remindOn: "Reminder", .remindTime: "Reminder time",
        .remindHint: "A notification arrives at this time on the day the last jar is eaten.",
        .eatTimeT: "Daily eating time", .perDayT: "Jars per day",
        .rulesHint: "Changes apply to the whole stock calculation.",
        .unitT: "Unit", .mAlertT: "Freezer time alert", .mAlertOff: "Off",
        .mAlertHint: "You get a notification when a bag has been in the freezer for the chosen time.", .monthsN: "{n} mo",
        .exportT: "Export data",
        .exportS: "Save your yogurt and breast milk records as a file. You can save it to iCloud Drive too.",
        .importT: "Restore from backup", .importS: "Current records will be replaced by the ones in the backup.",
        .importAsk: "Delete all current records and load the ones from the backup?",
        .importOk: "[[check]] Backup restored", .importFail: "Could not read the file", .exportOk: "[[check]] Backup saved",
        .resetYog: "Delete yogurt records", .resetMilk: "Delete breast milk records",
        .resetAsk: "This cannot be undone. Delete?",
        .aboutVersion: "Version", .aboutPrivacy: "Privacy policy", .aboutContact: "Contact",
        .aboutNote: "Your data stays on this phone only and is never sent anywhere.",
        .milkAlertTitle: "Frozen milk reminder 🍼",
        .milkAlertBody: "{a} of milk has been in the freezer for {n} months.",
        .notifTitle: "Time to start the yogurt! 🥛",
        .notifBody: "Today is the last jar. Start the new yogurt now so it is ready for tomorrow!"
    ]
}

// MARK: - Birim

nonisolated enum MilkUnit: String, CaseIterable, Identifiable {
    case ml, floz

    var id: String { rawValue }
    static let mlPerOz = 29.5735

    var symbol: String { self == .ml ? "ml" : "fl oz" }

    /// ml cinsinden saklanan değeri bu birime çevir
    func display(_ ml: Int) -> Double {
        self == .ml ? Double(ml) : Double(ml) / Self.mlPerOz
    }

    /// Bu birimdeki değeri ml'ye çevir
    func toMl(_ value: Double) -> Int {
        self == .ml ? Int(value.rounded()) : Int((value * Self.mlPerOz).rounded())
    }
}

// MARK: - Kullanıcı tercihleri (UserDefaults)

enum Prefs {
    private static let d = UserDefaults.standard

    static var reminderOn: Bool {
        get { d.object(forKey: "mandirake.reminderOn") as? Bool ?? true }
        set { d.set(newValue, forKey: "mandirake.reminderOn") }
    }
    /// Gün içi dakika (12:00 = 720)
    static var reminderMinutes: Int {
        get { d.object(forKey: "mandirake.reminderMinutes") as? Int ?? 12 * 60 }
        set { d.set(newValue, forKey: "mandirake.reminderMinutes") }
    }
    /// 0 = kapalı
    static var milkAlertMonths: Int {
        get { d.object(forKey: "mandirake.milkAlertMonths") as? Int ?? 0 }
        set { d.set(newValue, forKey: "mandirake.milkAlertMonths") }
    }
    static var unit: MilkUnit {
        get { MilkUnit(rawValue: d.string(forKey: "mandirake.unit") ?? "") ?? .ml }
        set { d.set(newValue.rawValue, forKey: "mandirake.unit") }
    }
    static var eatHour: Int {
        get { d.object(forKey: "mandirake.eatHour") as? Int ?? 16 }
        set { d.set(newValue, forKey: "mandirake.eatHour") }
    }
    static var jarsPerDay: Int {
        get { max(1, d.object(forKey: "mandirake.jarsPerDay") as? Int ?? 1) }
        set { d.set(newValue, forKey: "mandirake.jarsPerDay") }
    }
}

// MARK: - Ayarlar (dil ve tercihler)

@MainActor
final class AppSettings: ObservableObject {
    nonisolated static let storageKey = "mandirake.lang"

    /// Bildirim gibi arayüz dışı yerlerde de güncel dile erişmek için
    nonisolated static var storedLang: Lang {
        Lang(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .tr
    }

    @Published var lang: Lang {
        didSet { UserDefaults.standard.set(lang.rawValue, forKey: Self.storageKey) }
    }

    @Published var reminderOn: Bool { didSet { Prefs.reminderOn = reminderOn } }
    @Published var reminderMinutes: Int { didSet { Prefs.reminderMinutes = reminderMinutes } }
    @Published var milkAlertMonths: Int { didSet { Prefs.milkAlertMonths = milkAlertMonths } }
    @Published var unit: MilkUnit { didSet { Prefs.unit = unit } }
    @Published var eatHour: Int { didSet { Prefs.eatHour = eatHour } }
    @Published var jarsPerDay: Int { didSet { Prefs.jarsPerDay = jarsPerDay } }

    init() {
        lang = Self.storedLang
        reminderOn = Prefs.reminderOn
        reminderMinutes = Prefs.reminderMinutes
        milkAlertMonths = Prefs.milkAlertMonths
        unit = Prefs.unit
        eatHour = Prefs.eatHour
        jarsPerDay = Prefs.jarsPerDay
    }

    /// Bildirimleri yeniden kurmayı gerektiren her değişiklikte değişir
    var scheduleKey: String {
        "\(lang.rawValue)|\(reminderOn)|\(reminderMinutes)|\(milkAlertMonths)|\(unit.rawValue)|\(eatHour)|\(jarsPerDay)"
    }

    // MARK: Miktar (ml / fl oz)

    /// Sadece sayı: 130 ya da 4,4
    func amountNumber(_ ml: Int) -> String {
        Self.amountNumber(ml, unit: unit, lang: lang)
    }

    /// Sayı + birim: "130 ml" ya da "4,4 fl oz"
    func amount(_ ml: Int) -> String {
        "\(amountNumber(ml)) \(unit.symbol)"
    }

    nonisolated static func amountNumber(_ ml: Int, unit: MilkUnit, lang: Lang) -> String {
        if unit == .ml { return ml.formatted(.number.locale(lang.locale)) }
        return unit.display(ml).formatted(.number.precision(.fractionLength(0...1)).locale(lang.locale))
    }

    func t(_ key: Key, _ args: [String: String] = [:]) -> String {
        L10n.text(key, lang, args)
    }

    // MARK: Biçimlendirme (dile göre)

    func number(_ value: Int) -> String {
        value.formatted(.number.locale(lang.locale))
    }

    /// 12 Eki 2026
    func dateShort(_ d: Date) -> String {
        d.formatted(.dateTime.day().month(.abbreviated).year().locale(lang.locale))
    }

    /// 24 Ekim Cumartesi
    func dateLong(_ d: Date) -> String {
        d.formatted(.dateTime.day().month(.wide).weekday(.wide).locale(lang.locale))
    }

    /// 19 Ekim
    func dayMonthLong(_ d: Date) -> String {
        d.formatted(.dateTime.day().month(.wide).locale(lang.locale))
    }

    /// 19 Eki
    func dayMonth(_ d: Date) -> String {
        d.formatted(.dateTime.day().month(.abbreviated).locale(lang.locale))
    }

    /// 14:30
    func time(_ d: Date) -> String {
        d.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute().locale(lang.locale))
    }

    /// Gün içi dakika → "12:00"
    func clock(minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    /// 19 Eki 14:30
    func dayMonthTime(_ d: Date) -> String {
        dayMonth(d) + " " + time(d)
    }
}
