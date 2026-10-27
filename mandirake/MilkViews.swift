import SwiftUI

// MARK: - Anne sütü sayfası

/// Torba sayısına göre ikon boyutu: çok torba olsa da sayfa ekrana sığsın
private struct BagTier {
    let cols: Int
    let width: CGFloat
    let height: CGFloat
    let showML: Bool
    let showDate: Bool

    init(count n: Int) {
        switch n {
        case ...10: self.init(cols: 5, width: 46, height: 59, showML: true, showDate: true)
        case ...18: self.init(cols: 6, width: 38, height: 49, showML: true, showDate: true)
        case ...32: self.init(cols: 8, width: 30, height: 39, showML: true, showDate: false)
        default:    self.init(cols: 10, width: 24, height: 31, showML: false, showDate: false)
        }
    }

    private init(cols: Int, width: CGFloat, height: CGFloat, showML: Bool, showDate: Bool) {
        self.cols = cols; self.width = width; self.height = height
        self.showML = showML; self.showDate = showDate
    }
}

struct MilkView: View {
    @EnvironmentObject private var milk: MilkStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette

    @State private var picked: Set<UUID> = []
    @State private var showAdd = false
    @State private var toast: String?

    var body: some View {
        let frozen = milk.frozen
        ZStack {
            palette.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    PageHeader(pageName: settings.t(.tabMilk))
                    hero(frozen)
                    if frozen.isEmpty {
                        InfoCard(title: settings.t(.noMilkT), subtitle: settings.t(.noMilkS), style: .soft)
                    } else {
                        bagsCard(frozen)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { dock(frozen) }
        .overlay(alignment: .bottom) {
            if let toast {
                iconText(toast, size: 17)
                    .font(AppFont.font(15, .heavy))
                    .foregroundStyle(Theme.paper)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18).padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Theme.ink, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.25), value: picked)
        .animation(.easeOut(duration: 0.2), value: toast)
        .sheet(isPresented: $showAdd) {
            AddMilkView()
                .presentationBackground(palette.bg)
                .presentationCornerRadius(32)
        }
    }

    // MARK: Toplam

    private func hero(_ frozen: [MilkBag]) -> some View {
        HeroCard {
            iconText(settings.t(.mTotal), size: 18)
                .font(AppFont.font(16, .heavy))
                .foregroundStyle(palette.acc)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(settings.amountNumber(milk.totalMl))
                    .font(AppFont.font(72, .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(palette.acc)
                    .contentTransition(.numericText())
                Text(settings.unit.symbol)
                    .font(AppFont.font(26, .black))
                    .lineLimit(1)
                    .fixedSize()
                    .foregroundStyle(Theme.paper)
            }
            Text(frozen.isEmpty
                 ? settings.t(.mNone)
                 : settings.t(.mMeta, ["n": "\(frozen.count)",
                                       "d": settings.dayMonthLong(frozen[0].createdAt)]))
                .font(AppFont.font(16, .heavy))
                .foregroundStyle(palette.accSoft)
                .padding(.top, 6)
        }
        .animation(.spring, value: milk.totalMl)
    }

    // MARK: Torbalar

    private func bagsCard(_ frozen: [MilkBag]) -> some View {
        let tier = BagTier(count: frozen.count)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: tier.cols)
        return OutlinedCard {
            VStack(alignment: .leading, spacing: 2) {
                Text(settings.t(.bagsT))
                    .font(AppFont.font(20, .heavy))
                    .foregroundStyle(Theme.ink)
                    .padding(.leading, 10)
                iconText(settings.t(.bagsHint), size: 16)
                    .font(AppFont.font(14, .bold))
                    .foregroundStyle(Theme.muted)
                    .padding(.leading, 10)
                    .padding(.bottom, 10)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(frozen.enumerated()), id: \.element.id) { index, bag in
                        bagCell(bag, isOldest: index == 0, tier: tier)
                    }
                }
            }
            .padding(.top, 18)
            .padding(.bottom, 14)
            .padding(.horizontal, 10)
        }
    }

    private func bagCell(_ bag: MilkBag, isOldest: Bool, tier: BagTier) -> some View {
        let on = picked.contains(bag.id)
        return Button {
            if on { picked.remove(bag.id) } else { picked.insert(bag.id) }
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    MilkBagView(ml: bag.ml)
                        .frame(width: tier.width, height: tier.height)
                    if isOldest {
                        MIcon(name: .star, size: 14).offset(x: 7, y: -5)
                    }
                }
                if tier.showML {
                    Text(settings.amount(bag.ml))
                        .font(AppFont.font(tier.showDate ? 13 : 11, .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(Theme.ink)
                        .padding(.top, 3)
                }
                if tier.showDate {
                    Text(settings.dayMonth(bag.createdAt) + "\n" + settings.time(bag.createdAt))
                        .font(AppFont.font(10.5, .bold))
                        .foregroundStyle(on ? Theme.ink : Theme.muted)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 7).padding(.bottom, 5)
            .frame(maxWidth: .infinity)
            .background(on ? palette.acc : Color.clear,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                if on {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.ink, lineWidth: 3)
                }
            }
            .offset(y: on ? -3 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(settings.amount(bag.ml)), \(settings.dayMonthTime(bag.createdAt))")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    // MARK: Alt alan: ekleme butonu ya da çözme onayı

    @ViewBuilder
    private func dock(_ frozen: [MilkBag]) -> some View {
        let selected = frozen.filter { picked.contains($0.id) }
        Group {
            if selected.isEmpty {
                PillButton(title: settings.t(.addMilk)) { showAdd = true }
            } else {
                pickBar(selected)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(palette.bg)
    }

    private func pickBar(_ selected: [MilkBag]) -> some View {
        let ml = selected.reduce(0) { $0 + $1.ml }
        return VStack(alignment: .leading, spacing: 3) {
            Text(selected.count == 1
                 ? settings.t(.pickOne)
                 : settings.t(.pickN, ["n": "\(selected.count)"]))
                .font(AppFont.font(19, .black))
            Text(selected.count == 1
                 ? "\(settings.amount(ml)) · \(settings.dayMonthTime(selected[0].createdAt))"
                 : settings.t(.mlTotal, ["ml": settings.amount(ml)]))
                .font(AppFont.font(14, .bold))
                .foregroundStyle(palette.acc)
            HStack(spacing: 10) {
                Button { picked = [] } label: {
                    Text(settings.t(.no))
                        .font(AppFont.font(18, .black))
                        .foregroundStyle(Theme.paper)
                        .frame(maxWidth: .infinity).frame(height: 46)
                        .overlay(Capsule().strokeBorder(Theme.paper, lineWidth: 2))
                }
                Button { thawPicked(selected) } label: {
                    Text(settings.t(.yes))
                        .font(AppFont.font(18, .black))
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity).frame(height: 46)
                        .background(palette.btn, in: Capsule())
                }
            }
            .padding(.top, 9)
        }
        .foregroundStyle(Theme.paper)
        .padding(.horizontal, 20).padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.ink, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func thawPicked(_ selected: [MilkBag]) {
        let count = selected.count
        let ml = milk.thaw(ids: Set(selected.map(\.id)))
        picked = []
        toast = settings.t(.toast, [
            "b": count == 1 ? settings.t(.bag1) : settings.t(.bagN, ["n": "\(count)"]),
            "ml": settings.amount(ml)
        ])
        Task {
            try? await Task.sleep(for: .seconds(2.8))
            toast = nil
        }
    }
}

// MARK: - Yeni anne sütü formu

struct AddMilkView: View {
    @EnvironmentObject private var milk: MilkStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss

    @State private var ml = 70
    @State private var note = ""
    @State private var date = Date()
    @FocusState private var mlFocused: Bool

    /// Hızlı seçim değerleri (ml olarak saklanır, birime göre gösterilir)
    private var quick: [Int] {
        settings.unit == .ml ? [50, 70, 100, 120, 150]
                             : [2, 3, 4, 5].map { settings.unit.toMl(Double($0)) }
    }

    /// Eksi / artı adımı: ml'de 10 ml, fl oz'da 1 fl oz
    private var step: Int { settings.unit == .ml ? 10 : settings.unit.toMl(1) }

    /// Metin alanı seçili birimde çalışır, değer ml olarak saklanır
    private var amountBinding: Binding<Double> {
        Binding(get: { settings.unit.display(ml) },
                set: { ml = settings.unit.toMl($0) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                palette.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        iconText(settings.t(.mTitle), size: 34)
                            .font(AppFont.font(31, .black))
                            .foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)

                        counterCard
                        whenBox

                        VStack(alignment: .leading, spacing: 6) {
                            iconText(settings.t(.mNotes), size: 17)
                                .font(AppFont.font(15, .heavy))
                                .foregroundStyle(Theme.ink)
                            TextEditor(text: $note)
                                .font(AppFont.font(16, .bold))
                                .foregroundStyle(Theme.ink)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .inputBox()
                                .overlay(alignment: .topLeading) {
                                    if note.isEmpty {
                                        Text(settings.t(.mPh))
                                            .font(AppFont.font(16, .bold))
                                            .foregroundStyle(Theme.ink.opacity(0.45))
                                            .padding(.horizontal, 14).padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            milk.add(ml: max(1, ml), note: note.trimmingCharacters(in: .whitespacesAndNewlines), date: date)
                            dismiss()
                        } label: {
                            iconText(settings.t(.save), size: 24)
                                .font(AppFont.font(21, .black))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(palette.btn, in: Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(settings.t(.cancel)) { dismiss() }
                        .font(AppFont.font(17, .heavy))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(settings.t(.done)) { mlFocused = false }
                }
            }
        }
        .tint(Theme.ink)
    }

    private var counterCard: some View {
        VStack(spacing: 6) {
            Text(settings.t(.mQ, ["u": settings.unit.symbol]))
                .font(AppFont.font(20, .heavy))
            HStack(spacing: 12) {
                roundButton("−", filled: false, label: settings.t(.dec)) { ml = max(5, ml - step) }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    TextField("", value: amountBinding,
                              format: .number.precision(.fractionLength(0...1)))
                        .keyboardType(settings.unit == .ml ? .numberPad : .decimalPad)
                        .focused($mlFocused)
                        .multilineTextAlignment(.center)
                        .font(AppFont.font(68, .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                    Text(settings.unit.symbol)
                        .font(AppFont.font(24, .black))
                        .lineLimit(1)
                        .fixedSize()
                }
                .frame(maxWidth: .infinity)
                roundButton("+", filled: true, label: settings.t(.inc)) { ml = min(500, ml + step) }
            }
            HStack(spacing: 8) {
                ForEach(quick, id: \.self) { value in
                    Button { ml = value } label: {
                        Text(settings.amountNumber(value))
                            .font(AppFont.font(15, .heavy))
                            .foregroundStyle(ml == value ? Theme.paper : Theme.ink)
                            .padding(.horizontal, 14).frame(height: 36)
                            .background(ml == value ? Theme.ink : Theme.paper, in: Capsule())
                            .overlay(Capsule().strokeBorder(Theme.ink, lineWidth: 2))
                    }
                }
            }
            .padding(.top, 8)
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 20).padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(palette.accSoft, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .animation(.spring, value: ml)
    }

    private var whenBox: some View {
        // Varsayılan: şu an. Elle başka gün/saat seçilebilir (gelecek tarih seçilemez).
        DatePicker(selection: $date, in: ...Date(), displayedComponents: [.date, .hourAndMinute]) {
            iconText(settings.t(.mDate), size: 18)
                .font(AppFont.font(16, .black))
        }
        .environment(\.locale, settings.lang.locale)
        .tint(Theme.ink)
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inputBox()
    }

    private func roundButton(_ symbol: String, filled: Bool, label: String,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(AppFont.font(30, .black))
                .foregroundStyle(filled ? Theme.paper : Theme.ink)
                .frame(width: 56, height: 56)
                .background(filled ? Theme.ink : Theme.paper, in: Circle())
                .overlay(Circle().strokeBorder(Theme.ink, lineWidth: 3))
        }
        .accessibilityLabel(label)
    }
}
