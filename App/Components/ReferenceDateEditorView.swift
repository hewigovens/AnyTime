import AnyTimeCore
import SwiftUI

struct ReferenceDateEditorView: View {
    @Bindable var store: WorldClockStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Reference zone") {
                if let presentation = store.referencePresentation {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(presentation.title)
                            .font(.headline)
                        Text(presentation.utcOffsetText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Time") {
                DatePicker(
                    "Reference time",
                    selection: $store.referenceDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
        }
        .environment(\.timeZone, store.referenceTimeZone)
        .navigationTitle("Reference Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Now") {
                    store.resetReferenceDate()
                }
            }
        }
    }
}
