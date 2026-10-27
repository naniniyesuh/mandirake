import SwiftUI
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Uygulama açıkken de bildirim banner'ı göster
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

@main
struct MandirakeApp: App {
    @StateObject private var store = YogurtStore()
    @StateObject private var milk = MilkStore()
    @StateObject private var settings = AppSettings()
    @Environment(\.scenePhase) private var scenePhase
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(milk)
                .environmentObject(settings)
                .environment(\.locale, settings.lang.locale)
                .task { await store.requestNotificationPermission() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        store.scheduleReminder()
                        milk.scheduleAlerts()
                    }
                }
                // Dil ya da ayar değişince bildirimler yeniden kurulsun
                .onChange(of: settings.scheduleKey) { _, _ in
                    store.scheduleReminder()
                    milk.scheduleAlerts()
                }
        }
    }
}
