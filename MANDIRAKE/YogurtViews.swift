import SwiftUI

/// Yeni yoğurt formunu açar. date: yapılış tarihi (varsayılan şimdi).
/// fermentMinutes doluysa form mayalama sayacından açılmıştır; kaydedilince sayaç durur.
struct AddConfig: Identifiable {
    let id = UUID()
    var date: Date = Date()
    var fermentMinutes: Int? = nil
}

/// Kavanoz sayısına göre ikon boyutu: sayfa ekrana sığsın
private struct JarTier {
    let cols: Int
    let width: CGFloat
    let height: CGFloat
    let gap: CGFloat

    init(count n: Int) {
        switch n {
        case ...10: self.init(cols: 5, width: 52, height: 62, gap: 12)
        case ...18: self.init(cols: 7, width: 40, height: 48, gap: 5)
        case ...30: self.init(cols: 9, width: 30, height: 36, gap: 5)
        default:    self.init(cols: 11, width: 24, height: 29, gap: 4)
        }
    }

    private init(cols: Int, width: CGFloat, height: CGFloat, gap: CGFloat) {
        self.cols = cols; self.width = width; self.height = height; self.gap = gap
    }
}

// MARK: - Yoğurt sayfası

struct YogurtView: View {
    @EnvironmentObject private var store: YogurtStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette

    @State private var addConfig: AddConfig?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let snap = store.snapshot(at: context.date)
            ZStack {
                palette.bg.ignoresSafeArea()
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 12) {
                            PageHeader(pageName: settings.t(.tabYogurt))
                            hero(snap)
                            if !store.batches.isEmpty { jarsCard(snap) }
                            statusCard(snap)
                            Spacer(minLength: 8)
                            timerRow
                            Spacer(minLength: 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .frame(minHeight: geo.size.height, alignment: .top)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                PillButton(title: settings.t(.addYog)) { addConfig = AddConfig() }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(palette.bg)
            }
        }
        .sheet(item: $addConfig) { config in
            AddBatchView(config: config)
                .presentationBackground(palette.bg)
                .presentationCornerRadius(32)
        }
    }

    // MARK: Kavanoz sayısı

    private func hero(_ snap: StockSnapshot) -> some View {
        HeroCard {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(snap.remaining)")
                    .font(AppFont.font(72, .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(palette.acc)
                    .contentTransition(.numericText())
                Text(settings.t(.jarsLeft))
                    .font(AppFont.font(26, .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(Theme.paper)
            }
        }
        .animation(.spring, value: snap.remaining)
    }

    // MARK: Kavanozlar

    /// Şu an yenen batch (yoksa en son yapılan)
    private func displayBatch(_ snap: StockSnapshot) -> YogurtBatch? {
        if let id = snap.currentBatchID,
           let b = store.batches.first(where: { $0.id == id }) { return b }
        return store.batches.filter { $0.createdAt <= Date() }.max { $0.createdAt < $1.createdAt }
    }

    @ViewBuilder
    private func jarsCard(_ snap: StockSnapshot) -> some View {
        if let batch = displayBatch(snap) {
            let total = min(batch.jarCount, 40)
            let filled = min(snap.remainingByBatch[batch.id] ?? 0, total)
            let eaten = total - filled
            let tier = JarTier(count: total)
            OutlinedCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(settings.t(.batchLbl, ["d": settings.dateShort(batch.createdAt)]))
                        .font(AppFont.font(16, .heavy))
                        .foregroundStyle(Theme.ink)
                        .padding(.leading, 6)
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(tier.width), spacing: tier.gap),
                                             count: tier.cols),
                              spacing: tier.gap) {
                        ForEach(0..<total, id: \.self) { i in
                            let lid = Theme.lids[i % Theme.lids.count]
                            JarView(lid: lid, full: i >= eaten)
                                .frame(width: tier.width, height: tier.height)
                                .opacity(i < eaten ? 0.45 : 1)
                                .overlay(alignment: .topTrailing) {
                                    if i == eaten && filled > 0 && total <= 18 {
                                        SparkleStar(color: lid).offset(x: 7, y: -7)
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
                }
                .padding(.horizontal, 14)
                .padding(.top, 16)
                .padding(.bottom, 18)
            }
        }
    }

    // MARK: Durum kartı

    @ViewBuilder
    private func statusCard(_ snap: StockSnapshot) -> some View {
        let cal = Calendar.current
        if store.batches.isEmpty {
            InfoCard(title: settings.t(.noYogT), subtitle: settings.t(.noYogS), style: .soft)
        } else if snap.remaining == 0 {
            InfoCard(title: settings.t(.outT), subtitle: settings.t(.outS), style: .highlight)
        } else if let last = snap.lastJarDay, cal.isDateInToday(last) {
            InfoCard(title: settings.t(.todayT), subtitle: settings.t(.todayS, ["t": settings.clock(minutes: settings.eatHour * 60)]), style: .highlight)
        } else if let last = snap.lastJarDay {
            InfoCard(title: settings.t(.lastT, ["d": settings.dateLong(last)]),
                     subtitle: settings.reminderOn
                        ? settings.t(.lastS, ["t": settings.clock(minutes: settings.reminderMinutes)])
                        : settings.t(.lastSOff), style: .paper)
        }
    }

    // MARK: Mayalama sayacı (kutusuz, boş alanın ortasında)

    private func hm(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    @ViewBuilder
    private var timerRow: some View {
        if let start = store.fermentStart {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let minutes = max(0, Int(context.date.timeIntervalSince(start) / 60))
                HStack(spacing: 12) {
                    runningText(hm(minutes))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    timerButton(settings.t(.swStop), filled: true) {
                        // Sayaç, form kaydedilince durur. Vazgeçilirse çalışmaya devam eder.
                        addConfig = AddConfig(date: start, fermentMinutes: minutes)
                    }
                }
            }
            .padding(.horizontal, 4)
        } else {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    iconText(settings.t(.swT), size: 21)
                        .font(AppFont.font(18, .black))
                        .foregroundStyle(Theme.ink)
                    Text(store.lastFermentMinutes.map { settings.t(.swLast, ["t": hm($0)]) }
                         ?? settings.t(.swIdle))
                        .font(AppFont.font(14, .bold))
                        .foregroundStyle(Theme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                timerButton(settings.t(.swStart), filled: false) { store.startFerment() }
            }
            .padding(.horizontal, 4)
        }
    }

    /// "08:25'dır yoğurt mayalanıyor": süre büyük, cümle küçük
    private func runningText(_ time: String) -> Text {
        let parts = settings.t(.swRun).components(separatedBy: "{t}")
        let before = parts.first ?? ""
        let after = parts.count > 1 ? parts[1] : ""
        return Text(before).font(AppFont.font(16, .heavy))
            + Text(time).font(AppFont.font(30, .black)).monospacedDigit()
            + Text(after).font(AppFont.font(16, .heavy))
    }

    private func timerButton(_ title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.font(15, .black))
                .foregroundStyle(filled ? Theme.paper : Theme.ink)
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background(filled ? Theme.ink : palette.btn, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.ink, lineWidth: 2))
        }
        .fixedSize()
    }
}

// MARK: - Yeni yoğurt formu

struct AddBatchView: View {
    @EnvironmentObject private var store: YogurtStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss

    let config: AddConfig

    @State private var jars = 4
    @State private var date: Date
    @State private var note = ""
    @State private var endCurrent = false

    init(config: AddConfig) {
        self.config = config
        _date = State(initialValue: config.date)
    }

    private var remaining: Int { store.snapshot().remaining }

    var body: some View {
        NavigationStack {
            ZStack {
                palette.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        iconText(settings.t(.yTitle), size: 34)
                            .font(AppFont.font(31, .black))
                            .foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)

                        counterCard

                        DatePicker(settings.t(.yDate), selection: $date, in: ...Date(),
                                   displayedComponents: [.date, .hourAndMinute])
                            .font(AppFont.font(16, .heavy))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .frame(minHeight: 50)
                            .inputBox()

                        if remaining > 0 { endCurrentButton }

                        VStack(alignment: .leading, spacing: 6) {
                            iconText(settings.t(.yNotes), size: 17)
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
                                        Text(settings.t(.yPh))
                                            .font(AppFont.font(16, .bold))
                                            .foregroundStyle(Theme.ink.opacity(0.45))
                                            .padding(.horizontal, 14).padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: saveBatch) {
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
            }
        }
        .tint(Theme.ink)
    }

    private func saveBatch() {
        store.add(jarCount: jars,
                  date: min(date, Date()),
                  note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                  endCurrent: endCurrent)
        if let minutes = config.fermentMinutes {
            store.finishFerment(minutes: minutes)
        }
        dismiss()
    }

    private var counterCard: some View {
        VStack(spacing: 6) {
            Text(settings.t(.yQ))
                .font(AppFont.font(20, .heavy))
            HStack(spacing: 24) {
                roundButton("−", filled: false, label: settings.t(.dec)) { if jars > 1 { jars -= 1 } }
                Text("\(jars)")
                    .font(AppFont.font(68, .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(minWidth: 90, maxWidth: .infinity)
                    .contentTransition(.numericText())
                roundButton("+", filled: true, label: settings.t(.inc)) { if jars < 99 { jars += 1 } }
            }
            .animation(.spring, value: jars)
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 20).padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(palette.accSoft, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
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

    private var endCurrentButton: some View {
        Button { withAnimation(.spring) { endCurrent.toggle() } } label: {
            HStack(spacing: 12) {
                Image(systemName: endCurrent ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.ink)
                VStack(alignment: .leading, spacing: 2) {
                    Text(settings.t(.endT))
                        .font(AppFont.font(18, .black))
                    Text(endCurrent
                         ? settings.t(.endOn, ["n": "\(remaining)"])
                         : settings.t(.endOff, ["n": "\(remaining)"]))
                        .font(AppFont.font(14, .bold))
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18).padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(endCurrent ? palette.hl : Theme.paper,
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Theme.ink, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }
}
