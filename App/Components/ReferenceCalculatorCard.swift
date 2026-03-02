import AnyTimeCore
import SwiftUI
import UIKit

struct ReferenceCalculatorCard: View {
    @Bindable var store: WorldClockStore
    @State private var pasteFeedback: PasteFeedback?
    @State private var isResolvingPaste = false
    @State private var showingDateEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Timezone Calculator")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Tap or Drag to change reference.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let presentation = store.referencePresentation {
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        showingDateEditor = true
                    } label: {
                        Text(presentation.formattedTime)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit reference time \(presentation.formattedTime)")

                    referenceZoneMenu {
                        HStack(spacing: 6) {
                            Text("\(presentation.title) • \(presentation.utcOffsetText)")
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    }
                }
            }

            DatePicker(
                "Reference time",
                selection: $store.referenceDate,
                displayedComponents: [.hourAndMinute, .date]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .environment(\.timeZone, store.referenceTimeZone)
            .tint(AppTheme.accent)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ForEach(Self.topRowActions) { action in
                        quickActionButton(action)
                    }
                }

                HStack(spacing: 10) {
                    ForEach(Self.bottomRowActions) { action in
                        quickActionButton(action)
                    }
                }
            }

            if let pasteFeedback {
                Text(pasteFeedback.message)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(pasteFeedback.isError ? .secondary : AppTheme.accent)
                    .lineLimit(2)
                    .transition(.opacity)
            }
        }
        .padding(20)
        .background(AppTheme.calculatorSurface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.calculatorStroke, lineWidth: 1)
        }
        .shadow(color: AppTheme.shadow, radius: 12, y: 5)
        .sheet(isPresented: $showingDateEditor) {
            NavigationStack {
                ReferenceDateEditorView(store: store)
            }
            .presentationDetents([.medium])
        }
    }

    private func referenceZoneMenu<Label: View>(
        @ViewBuilder label: () -> Label
    ) -> some View {
        Menu {
            ForEach(store.presentations) { presentation in
                Button(presentation.selectionTitle) {
                    withAnimation(.snappy) {
                        store.setReferenceTimeZone(id: presentation.timeZoneID)
                    }
                }
            }
        } label: {
            label()
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
        }
    }

    @MainActor
    private func pasteReferenceDate() async {
        guard let clipboard = UIPasteboard.general.string else {
            pasteFeedback = PasteFeedback(message: "Clipboard is empty.", isError: true)
            return
        }

        isResolvingPaste = true
        pasteFeedback = PasteFeedback(message: "Analyzing clipboard…", isError: false)

        let result = await ReferencePasteResolver.resolve(from: clipboard)

        isResolvingPaste = false

        switch result {
        case let .success(resolution):
            withAnimation(.snappy) {
                if let timeZoneID = resolution.timeZoneID {
                    store.selectTimeZone(
                        id: timeZoneID,
                        preferredCityName: resolution.preferredCityName
                    )
                    store.setReferenceTimeZone(id: timeZoneID)
                }

                if let date = resolution.date {
                    store.referenceDate = date
                }

                pasteFeedback = PasteFeedback(
                    message: resolution.message,
                    isError: false
                )
            }

        case let .failure(message):
            pasteFeedback = PasteFeedback(message: message, isError: true)
        }
    }

    private static let quickActions = [
        QuickShift(label: "+1h", systemImage: "plus.circle", role: .cool, action: { $0.shiftReference(hours: 1) }),
        QuickShift(label: "-1h", systemImage: "minus.circle", role: .cool, action: { $0.shiftReference(hours: -1) }),
        QuickShift(label: "Now", systemImage: "arrow.clockwise", role: .warm, action: { $0.resetReferenceDate() })
    ]

    private static let bottomRowActions = [
        QuickShift(label: "+1d", systemImage: "forward.end", role: .cool, action: { $0.shiftReference(days: 1) }),
        QuickShift(label: "-1d", systemImage: "backward.end", role: .cool, action: { $0.shiftReference(days: -1) }),
        QuickShift(label: "Paste", systemImage: "wand.and.stars", role: .magic, performsPaste: true, action: { _ in })
    ]

    private static let topRowActions = quickActions

    @ViewBuilder
    private func quickActionButton(_ action: QuickShift) -> some View {
        Button {
            if action.performsPaste {
                Task {
                    await pasteReferenceDate()
                }
            } else {
                action.action(store)
            }
        } label: {
            Label(action.label, systemImage: action.systemImage)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(QuickActionButtonStyle(role: action.role))
        .disabled(action.performsPaste && isResolvingPaste)
    }
}

private struct PasteFeedback {
    let message: String
    let isError: Bool
}
