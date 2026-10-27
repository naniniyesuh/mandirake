import SwiftUI

// MARK: - Notlar (yoğurt ve anne sütü birlikte)

private enum NoteFilter: CaseIterable, Identifiable {
    case all, milk, yogurt

    var id: Self { self }

    var titleKey: Key {
        switch self {
        case .all: return .fAll
        case .milk: return .fMilk
        case .yogurt: return .fYog
        }
    }
}

private enum NoteItem: Identifiable {
    case yogurt(YogurtBatch)
    case milk(MilkBag)

    var id: UUID {
        switch self {
        case .yogurt(let b): return b.id
        case .milk(let m): return m.id
        }
    }

    var date: Date {
        switch self {
        case .yogurt(let b): return b.createdAt
        case .milk(let m): return m.createdAt
        }
    }
}

struct NotesView: View {
    @EnvironmentObject private var store: YogurtStore
    @EnvironmentObject private var milk: MilkStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette

    @State private var filter: NoteFilter = .all

    private var items: [NoteItem] {
        var out: [NoteItem] = []
        if filter != .milk { out += store.batches.map { NoteItem.yogurt($0) } }
        if filter != .yogurt { out += milk.bags.map { NoteItem.milk($0) } }
        return out.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            let snap = store.snapshot()
            let list = items
            ZStack {
                palette.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    Text(settings.t(.notesTitle))
                        .font(AppFont.font(31, .black))
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    filterChips
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .padding(.bottom, 6)

                    if list.isEmpty {
                        Spacer()
                        Text(settings.t(.empty))
                            .multilineTextAlignment(.center)
                            .font(AppFont.font(20, .heavy))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 24)
                        Spacer()
                    } else {
                        List {
                            ForEach(list) { item in
                                ZStack {
                                    NavigationLink {
                                        destination(for: item)
                                    } label: {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    row(item, snap: snap)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(item)
                                    } label: {
                                        Text(settings.t(.del))
                                    }
                                    .tint(Theme.pink)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: Filtre

    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(NoteFilter.allCases) { f in
                Button { filter = f } label: {
                    Text(settings.t(f.titleKey))
                        .font(AppFont.font(15, .heavy))
                        .foregroundStyle(filter == f ? Theme.paper : Theme.ink)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(filter == f ? Theme.ink : Theme.paper, in: Capsule())
                        .overlay(Capsule().strokeBorder(Theme.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: Satırlar

    @ViewBuilder
    private func destination(for item: NoteItem) -> some View {
        switch item {
        case .yogurt(let b): YogurtNoteDetail(batchID: b.id)
        case .milk(let m): MilkNoteDetail(bagID: m.id)
        }
    }

    private func delete(_ item: NoteItem) {
        switch item {
        case .yogurt(let b): store.delete(b)
        case .milk(let m): milk.delete(m)
        }
    }

    private func row(_ item: NoteItem, snap: StockSnapshot) -> some View {
        let title: String
        let trailing: String
        let note: String
        let fill: Color
        let badge: (text: String, ink: Bool)?

        switch item {
        case .yogurt(let b):
            let left = snap.remainingByBatch[b.id] ?? 0
            title = settings.dateShort(b.createdAt)
            trailing = "[[jar]] \(b.jarCount)"
            note = b.note
            fill = left > 0 ? Theme.sky : Theme.skySoft
            if left > 0 {
                badge = (settings.t(.left, ["n": "\(left)"]), true)
            } else if b.endedAt != nil {
                badge = (settings.t(.closed), false)
            } else {
                badge = nil
            }
        case .milk(let m):
            title = settings.dayMonthTime(m.createdAt)
            trailing = "[[bottle]] \(settings.amount(m.ml))"
            note = m.note
            fill = m.thawedAt == nil ? Theme.sun : Theme.butter
            badge = m.thawedAt == nil ? (settings.t(.frozen), true) : (settings.t(.thawed), false)
        }

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(title)
                    .font(AppFont.font(19, .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 4)
                iconText(trailing, size: 22).font(AppFont.font(19, .black))
                if let badge {
                    Text(badge.text)
                        .font(AppFont.font(12, .heavy))
                        .foregroundStyle(badge.ink ? Theme.paper : Theme.ink)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(badge.ink ? Theme.ink : Theme.pink, in: Capsule())
                        .overlay {
                            if !badge.ink { Capsule().strokeBorder(Theme.ink, lineWidth: 2) }
                        }
                }
            }
            Text(note.isEmpty ? settings.t(.noNote) : note)
                .font(AppFont.font(16, .heavy))
                .opacity(note.isEmpty ? 0.55 : 1)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fill, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Theme.ink, lineWidth: 3)
        )
    }
}

// MARK: - Not detayları

struct YogurtNoteDetail: View {
    @EnvironmentObject private var store: YogurtStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette
    let batchID: UUID

    @State private var text = ""
    @State private var loaded = false

    var body: some View {
        let batch = store.batches.first { $0.id == batchID }
        ZStack {
            palette.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                if let batch {
                    Text(settings.dateLong(batch.createdAt))
                        .font(AppFont.font(27, .black))
                    iconText(settings.t(.jarsN, ["n": "\(batch.jarCount)"]), size: 22)
                        .font(AppFont.font(20, .heavy))
                }
                noteEditor(title: settings.t(.notesLbl), text: $text)
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            guard !loaded else { return }
            text = batch?.note ?? ""
            loaded = true
        }
        .onChange(of: text) { _, new in store.updateNote(for: batchID, note: new) }
    }
}

struct MilkNoteDetail: View {
    @EnvironmentObject private var milk: MilkStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette
    let bagID: UUID

    @State private var text = ""
    @State private var loaded = false

    var body: some View {
        let bag = milk.bags.first { $0.id == bagID }
        ZStack {
            palette.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                if let bag {
                    Text("\(settings.dateLong(bag.createdAt)) · \(settings.time(bag.createdAt))")
                        .font(AppFont.font(27, .black))
                    iconText("[[bottle]] \(settings.amount(bag.ml)) · \(settings.t(bag.thawedAt == nil ? .frozen : .thawed))")
                        .font(AppFont.font(20, .heavy))
                }
                noteEditor(title: settings.t(.notesLbl), text: $text)
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            guard !loaded else { return }
            text = bag?.note ?? ""
            loaded = true
        }
        .onChange(of: text) { _, new in milk.updateNote(for: bagID, note: new) }
    }
}

@MainActor @ViewBuilder
private func noteEditor(title: String, text: Binding<String>) -> some View {
    iconText(title, size: 17)
        .font(AppFont.font(15, .heavy))
        .padding(.top, 2)
    TextEditor(text: text)
        .font(AppFont.font(16, .bold))
        .scrollContentBackground(.hidden)
        .padding(8)
        .inputBox()
}
