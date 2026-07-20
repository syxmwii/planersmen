import SwiftUI

@main
struct PlanersmenApp: App {
    @StateObject private var store = ShiftStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
