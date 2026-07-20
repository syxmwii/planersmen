import SwiftUI

struct ContentView: View {
    @ObservedObject var store: ShiftStore
    @State private var isPresentingEditor = false
    @State private var editingShift: Shift?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Планер смен")
                        .font(.largeTitle.bold())
                    Text("Управляйте сменами, датами и заметками в одном месте")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if store.items.isEmpty {
                    ContentUnavailableView(
                        "Пока нет смен",
                        systemImage: "calendar.badge.plus",
                        description: Text("Добавьте первую смену, чтобы начать планирование")
                    )
                        .padding(.top, 24)
                } else {
                    List {
                        ForEach(store.items) { shift in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(shift.title)
                                        .font(.headline)
                                    Spacer()
                                    Circle()
                                        .fill(color(for: shift.colorName))
                                        .frame(width: 12, height: 12)
                                }

                                Text("\(dateFormatter.string(from: shift.startDate)) — \(dateFormatter.string(from: shift.endDate))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                if !shift.notes.isEmpty {
                                    Text(shift.notes)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    editingShift = shift
                                    isPresentingEditor = true
                                } label: {
                                    Label("Изменить", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete(perform: store.delete(at:))
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingShift = nil
                        isPresentingEditor = true
                    } label: {
                        Label("Добавить", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                ShiftFormView(shift: editingShift) { newShift in
                    if let editing = editingShift {
                        store.update(newShift)
                    } else {
                        store.add(newShift)
                    }
                    editingShift = nil
                }
            }
        }
    }

    private func color(for colorName: String) -> Color {
        ShiftColor(rawValue: colorName)?.accentColor ?? .blue
    }
}

#Preview {
    ContentView(store: ShiftStore())
}
