import SwiftUI

struct ShiftFormView: View {
    @Environment(\.dismiss) private var dismiss
    private let initialShift: Shift?
    private let onSave: (Shift) -> Void

    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var notes = ""
    @State private var colorName = "blue"

    init(shift: Shift?, onSave: @escaping (Shift) -> Void) {
        self.initialShift = shift
        self.onSave = onSave

        _title = State(initialValue: shift?.title ?? "")
        _startDate = State(initialValue: shift?.startDate ?? Date())
        _endDate = State(initialValue: shift?.endDate ?? Date().addingTimeInterval(3600))
        _notes = State(initialValue: shift?.notes ?? "")
        _colorName = State(initialValue: shift?.colorName ?? "blue")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#312E81"), Color(hex: "#1D4ED8")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Название", text: $title)
                            .foregroundStyle(.white)
                        DatePicker("Начало", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .tint(.cyan)
                        DatePicker("Окончание", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                            .tint(.cyan)
                        TextField("Заметки", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.08))

                    Section("Цвет") {
                        Picker("Оттенок", selection: $colorName) {
                            ForEach(ShiftColor.allCases) { color in
                                Text(color.rawValue.capitalized).tag(color.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                }
                .scrollContentBackground(.hidden)
                .background(.clear)
            }
            .navigationTitle(initialShift == nil ? "Новая смена" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        save()
                    }
                    .bold()
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private func save() {
        let shift = Shift(
            id: initialShift?.id ?? UUID(),
            title: title.isEmpty ? "Новая смена" : title,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            colorName: colorName
        )
        onSave(shift)
        dismiss()
    }
}
