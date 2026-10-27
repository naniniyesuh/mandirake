import Foundation
import Combine
import UserNotifications

/// Buzlukta saklanan tek bir anne sütü torbası.
/// createdAt: sütün buzluğa konduğu gün ve saat.
/// thawedAt: çözüldüyse çözüldüğü an (nil ise hâlâ buzlukta).
struct MilkBag: Identifiable, Codable, Equatable {
    var id = UUID()
    var ml: Int
    var createdAt: Date
    var note: String
    var thawedAt: Date?
}

@MainActor
final class MilkStore: ObservableObject {
    @Published var bags: [MilkBag] = [] {
        didSet {
            save()
            scheduleAlerts()
        }
    }

    private let storageKey = "mandirake.milk.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([MilkBag].self, from: data) {
            bags = decoded
        }
    }

    // MARK: - Buzluk

    /// Buzlukta duran torbalar, en eskiden yeniye
    var frozen: [MilkBag] {
        bags.filter { $0.thawedAt == nil }.sorted { $0.createdAt < $1.createdAt }
    }

    /// Buzlukta toplam ml
    var totalMl: Int {
        frozen.reduce(0) { $0 + $1.ml }
    }

    // MARK: - CRUD

    /// Yeni sağım: girildiği an buzluğa konmuş sayılır.
    /// date verilmezse şu an; gelecekteki bir tarih şu ana çekilir.
    func add(ml: Int, note: String, date: Date = Date()) {
        bags.append(MilkBag(ml: ml, createdAt: min(date, Date()), note: note, thawedAt: nil))
    }

    /// Seçilen torbaları çöz: stoktan düşer, notlarda "çözüldü" olarak kalır.
    /// Çözülen torbaların toplam ml değerini döndürür.
    @discardableResult
    func thaw(ids: Set<UUID>) -> Int {
        let now = Date()
        var total = 0
        var updated = bags
        for i in updated.indices where ids.contains(updated[i].id) && updated[i].thawedAt == nil {
            updated[i].thawedAt = now
            total += updated[i].ml
        }
        bags = updated
        return total
    }

    /// Yedekten geri yükleme
    func replaceAll(bags newBags: [MilkBag]) {
        bags = newBags
    }

    /// Tüm anne sütü kayıtlarını sil
    func resetAll() {
        bags = []
    }

    func delete(_ bag: MilkBag) {
        bags.removeAll { $0.id == bag.id }
    }

    func updateNote(for id: UUID, note: String) {
        guard let i = bags.firstIndex(where: { $0.id == id }) else { return }
        bags[i].note = note
    }

    // MARK: - Buzluk süresi uyarısı

    private static let alertPrefix = "mandirake.milk."

    /// Ayarlardaki süreyi (örn. 3 ay) dolduran her buzluktaki torba için sabah 10:00'da
    /// bir bildirim kurar. Torbalar, ayarlar, dil ya da uygulama açılışında yeniden hesaplanır.
    func scheduleAlerts() {
        let center = UNUserNotificationCenter.current()
        let months = Prefs.milkAlertMonths
        let lang = AppSettings.storedLang
        let unit = Prefs.unit
        let cal = Calendar.current
        let now = Date()

        var items: [(id: String, fire: Date, body: String)] = []
        if months > 0 {
            for bag in frozen {
                guard let due = cal.date(byAdding: .month, value: months, to: bag.createdAt),
                      let fire = cal.date(bySettingHour: 10, minute: 0, second: 0, of: due),
                      fire > now else { continue }
                let amount = AppSettings.amountNumber(bag.ml, unit: unit, lang: lang) + " " + unit.symbol
                let body = L10n.text(.milkAlertBody, lang, ["a": amount, "n": "\(months)"])
                items.append((Self.alertPrefix + bag.id.uuidString, fire, body))
            }
            // iOS en fazla 64 bekleyen bildirime izin verir; yoğurt için yer bırak
            items = Array(items.sorted { $0.fire < $1.fire }.prefix(40))
        }
        let scheduled = items
        let title = L10n.text(.milkAlertTitle, lang)
        let prefix = Self.alertPrefix

        center.getPendingNotificationRequests { requests in
            let old = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: old)
            for item in scheduled {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = item.body
                content.sound = .default
                let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: item.fire)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                center.add(UNNotificationRequest(identifier: item.id, content: content, trigger: trigger))
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(bags) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
