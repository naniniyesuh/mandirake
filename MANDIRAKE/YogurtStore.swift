import Foundation
import Combine
import UserNotifications

struct YogurtBatch: Identifiable, Codable, Equatable {
    var id = UUID()
    var createdAt: Date
    var jarCount: Int
    var note: String
    /// "Mevcut kavanozları bitir" ile kapatıldıysa, kapatıldığı an
    var endedAt: Date?
}

struct StockSnapshot {
    var remaining = 0
    var remainingByBatch: [UUID: Int] = [:]
    var currentBatchID: UUID?      // şu an yenen yoğurdun batch'i
    var nextEatTime: Date?         // bir sonraki kavanozun düşeceği an
    var lastJarDay: Date?          // son kavanozun yeneceği gün
}

@MainActor
final class YogurtStore: ObservableObject {
    @Published var batches: [YogurtBatch] = [] {
        didSet {
            save()
            scheduleReminder()
        }
    }

    /// Mayalama sayacı: başlatıldığı an (çalışıyorsa)
    @Published var fermentStart: Date? {
        didSet { saveFerment() }
    }
    /// Son biten mayalamanın süresi (dakika)
    @Published var lastFermentMinutes: Int? {
        didSet { saveFerment() }
    }

    private let storageKey = "mandirake.batches.v1"
    private let fermentStartKey = "mandirake.fermentStart"
    private let fermentLastKey = "mandirake.fermentLastMinutes"
    private let reminderID = "mandirake.lastJarReminder"
    private let cal = Calendar.current

    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([YogurtBatch].self, from: data) {
            batches = decoded
        }
        fermentStart = defaults.object(forKey: fermentStartKey) as? Date
        lastFermentMinutes = defaults.object(forKey: fermentLastKey) as? Int
    }

    // MARK: - CRUD

    /// endCurrent = true ise eldeki kalan kavanozlar bitmiş sayılır,
    /// yeni yoğurt hemen sıraya girer.
    func add(jarCount: Int, date: Date, note: String, endCurrent: Bool = false) {
        var updated = batches
        if endCurrent {
            let snap = snapshot()
            let now = Date()
            for i in updated.indices where (snap.remainingByBatch[updated[i].id] ?? 0) > 0 {
                updated[i].endedAt = now
            }
        }
        updated.append(YogurtBatch(createdAt: date, jarCount: jarCount, note: note))
        batches = updated
    }

    /// Yedekten geri yükleme
    func replaceAll(batches newBatches: [YogurtBatch], fermentStart start: Date?, lastFermentMinutes last: Int?) {
        fermentStart = start
        lastFermentMinutes = last
        batches = newBatches
    }

    /// Tüm yoğurt kayıtlarını ve sayacı sıfırla
    func resetAll() {
        replaceAll(batches: [], fermentStart: nil, lastFermentMinutes: nil)
    }

    func delete(_ batch: YogurtBatch) {
        batches.removeAll { $0.id == batch.id }
    }

    func updateNote(for id: UUID, note: String) {
        guard let i = batches.firstIndex(where: { $0.id == id }) else { return }
        batches[i].note = note
    }

    private func save() {
        if let data = try? JSONEncoder().encode(batches) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Mayalama sayacı

    func startFerment() {
        lastFermentMinutes = nil
        fermentStart = Date()
    }

    /// Yeni yoğurt formu kaydedilince çağrılır: sayacı durdurur, süreyi saklar.
    func finishFerment(minutes: Int) {
        lastFermentMinutes = minutes
        fermentStart = nil
    }

    private func saveFerment() {
        let defaults = UserDefaults.standard
        defaults.set(fermentStart, forKey: fermentStartKey)
        defaults.set(lastFermentMinutes, forKey: fermentLastKey)
    }

    // MARK: - Stok hesabı

    private func eatTime(on day: Date) -> Date {
        cal.date(bySettingHour: Prefs.eatHour, minute: 0, second: 0, of: day)!
    }

    /// Kurallar:
    /// - Yoğurt yapıldığı günün ertesi gününden itibaren yenmeye başlar
    ///   (mayalanması için bir gün gerekir).
    /// - Her gün ayarlardaki saatte (varsayılan 16:00), eldeki en eski batch'ten
    ///   ayarlardaki sayıda (varsayılan 1) kavanoz düşer.
    func snapshot(at now: Date = .now) -> StockSnapshot {
        let perDay = Prefs.jarsPerDay
        let sorted = batches.filter { $0.createdAt <= now }.sorted { $0.createdAt < $1.createdAt }
        guard let first = sorted.first else { return StockSnapshot() }

        var left = Dictionary(uniqueKeysWithValues: sorted.map { ($0.id, $0.jarCount) })

        @discardableResult
        func consume(onDay day: Date) -> Bool {
            let tick = eatTime(on: day)
            guard let b = sorted.first(where: {
                (left[$0.id] ?? 0) > 0
                    && cal.startOfDay(for: $0.createdAt) < day
                    && ($0.endedAt.map { $0 > tick } ?? true)
            }) else { return false }
            left[b.id]! -= 1
            return true
        }

        // Geçmiş: şimdiye kadar düşen kavanozlar
        var day = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: first.createdAt))!
        while eatTime(on: day) <= now {
            for _ in 0..<perDay { consume(onDay: day) }
            day = cal.date(byAdding: .day, value: 1, to: day)!
        }

        // "Bitir" ile kapatılan batch'lerde kalan kavanoz kalmaz
        for b in sorted where b.endedAt != nil { left[b.id] = 0 }

        var snap = StockSnapshot()
        snap.remainingByBatch = left
        snap.remaining = left.values.reduce(0, +)
        guard snap.remaining > 0 else { return snap }

        // Gelecek: son kavanozun düşeceği günü simüle et
        var future = left
        func consumeFuture(onDay d: Date) -> UUID? {
            guard let b = sorted.first(where: {
                (future[$0.id] ?? 0) > 0 && cal.startOfDay(for: $0.createdAt) < d
            }) else { return nil }
            future[b.id]! -= 1
            return b.id
        }

        var d = day
        var steps = 0
        while future.values.reduce(0, +) > 0 && steps < 500 {
            for _ in 0..<perDay {
                if let id = consumeFuture(onDay: d) {
                    if snap.nextEatTime == nil {
                        snap.nextEatTime = eatTime(on: d)
                        snap.currentBatchID = id
                    }
                    snap.lastJarDay = d
                }
            }
            d = cal.date(byAdding: .day, value: 1, to: d)!
            steps += 1
        }
        return snap
    }

    // MARK: - Bildirim

    func requestNotificationPermission() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
        scheduleReminder()
    }

    /// Son kavanozun yeneceği günün öğlen 12:00'si için tek bir bildirim kurar.
    /// Stok her değiştiğinde, dil değiştiğinde ve uygulama her açıldığında yeniden hesaplanır.
    func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])

        guard Prefs.reminderOn,
              let lastDay = snapshot().lastJarDay,
              let fire = cal.date(bySettingHour: Prefs.reminderMinutes / 60,
                                  minute: Prefs.reminderMinutes % 60, second: 0, of: lastDay),
              fire > .now else { return }

        let lang = AppSettings.storedLang
        let content = UNMutableNotificationContent()
        content.title = L10n.text(.notifTitle, lang)
        content.body = L10n.text(.notifBody, lang)
        content.sound = .default

        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger))
    }
}
