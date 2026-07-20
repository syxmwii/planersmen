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
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#312E81")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Планер смен")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Светлый и мощный взгляд на ваши смены")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    GlassPanel {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundStyle(.white)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Сегодня в работе")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("\(store.items.count) смены в расписании")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Spacer()
                            Circle()
                                .fill(Color(hex: "#8B5CF6"))
                                .frame(width: 10, height: 10)
                        }
                        .padding()
                    }
                    .padding(.horizontal)

                    if store.items.isEmpty {
                        GlassPanel {
                            ContentUnavailableView(
                                "Пока нет смен",
                                systemImage: "calendar.badge.plus",
                                description: Text("Добавьте первую смену, чтобы начать планирование")
                            )
                            .background(.clear)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    } else {
                        List {
                            ForEach(store.items) { shift in
                                GlassRow(shift: shift, dateFormatter: dateFormatter) {
                                    editingShift = shift
                                    isPresentingEditor = true
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: store.delete(at:))
                        }
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .listStyle(.plain)
                    }
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
                    .foregroundStyle(.white)
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

private struct GlassPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 12)
            )
    }
}

private struct GlassRow: View {
    let shift: Shift
    let dateFormatter: DateFormatter
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(shift.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Circle()
                    .fill(color(for: shift.colorName))
                    .frame(width: 12, height: 12)
            }

            Text("\(dateFormatter.string(from: shift.startDate)) — \(dateFormatter.string(from: shift.endDate))")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            if !shift.notes.isEmpty {
                Text(shift.notes)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.22), lineWidth: 1)
                )
        )
        .swipeActions(edge: .trailing) {
            Button {
                onEdit()
            } label: {
                Label("Изменить", systemImage: "pencil")
            }
            .tint(.indigo)
        }
    }

    private func color(for colorName: String) -> Color {
        ShiftColor(rawValue: colorName)?.accentColor ?? .blue
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&hexValue)
        let mask = 0x000000FF
        let r = Double((hexValue >> 16) & mask) / 255
        let g = Double((hexValue >> 8) & mask) / 255
        let b = Double(hexValue & mask) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView(store: ShiftStore())
}
