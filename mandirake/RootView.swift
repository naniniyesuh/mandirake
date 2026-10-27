import SwiftUI

enum AppTab: CaseIterable, Identifiable {
    case milk, yogurt, notes, settings

    var id: Self { self }

    var titleKey: Key {
        switch self {
        case .milk: return .tabMilk
        case .yogurt: return .tabYogurt
        case .notes: return .tabNotes
        case .settings: return .tabSettings
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var tab: AppTab = .milk

    var body: some View {
        ZStack {
            switch tab {
            case .milk:
                MilkView().environment(\.palette, .warm)
            case .yogurt:
                YogurtView().environment(\.palette, .cool)
            case .notes:
                NotesView().environment(\.palette, .warm)
            case .settings:
                SettingsView().environment(\.palette, .warm)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { tabBar }
        .tint(Theme.ink)
        .preferredColorScheme(.light)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { t in
                Button { tab = t } label: {
                    Group {
                        if t == .settings {
                            GearIcon(selected: tab == t)
                        } else {
                            Text(settings.t(t.titleKey))
                                .font(AppFont.font(14.5, .heavy))
                                .foregroundStyle(tab == t ? Theme.sun : Theme.paper)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(settings.t(t.titleKey))
                .accessibilityAddTraits(tab == t ? .isSelected : [])
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                .fill(Theme.ink)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
