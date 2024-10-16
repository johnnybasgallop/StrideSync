import Foundation

// Step data model for individual entries
struct StepEntry: Identifiable {
    let id = UUID()
    let label: String
    let steps: Int
}
