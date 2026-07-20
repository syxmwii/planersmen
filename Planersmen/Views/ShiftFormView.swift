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
            Form {
                Section("Смена") {
                    TextField("Название", text: $title)
                    DatePicker("Начало", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Окончание", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Заметки", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Цвет") {
                    Picker("Оттенок", selection: $colorName) {
                        ForEach(ShiftColor.allCases) { color in
                            Text(color.rawValue.capitalized).tag(color.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(initialShift == nil ? "Новая смена" : "Редактировать")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        save()
                    }
                    .bold()
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
