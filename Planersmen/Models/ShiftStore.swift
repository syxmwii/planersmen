import Foundation
import SwiftUI

struct Shift: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var notes: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String = "",
        colorName: String = "blue"
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.colorName = colorName
    }
}

enum ShiftColor: String, CaseIterable, Identifiable {
    case blue, green, orange, purple

    var id: String { rawValue }

    var accentColor: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .orange:
            return .orange
        case .purple:
            return .purple
        }
    }
}

final class ShiftStore: ObservableObject {
    @Published var items: [Shift]

    init() {
        let now = Date()
        let calendar = Calendar.current
        let todayMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        let todayEvening = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: now) ?? now
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let tomorrowNight = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: tomorrow) ?? tomorrow

        self.items = [
            Shift(
                title: "Утренняя смена",
                startDate: todayMorning,
                endDate: todayEvening,
                notes: "Проверить заявки и подготовить отчет",
                colorName: "blue"
            ),
            Shift(
                title: "Вечерняя смена",
                startDate: tomorrowNight,
                endDate: tomorrowNight.addingTimeInterval(4 * 60 * 60),
                notes: "Контроль закрытия смены",
                colorName: "orange"
            )
        ]
    }

    func add(_ shift: Shift) {
        items.append(shift)
    }

    func update(_ shift: Shift) {
        if let index = items.firstIndex(where: { $0.id == shift.id }) {
            items[index] = shift
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
