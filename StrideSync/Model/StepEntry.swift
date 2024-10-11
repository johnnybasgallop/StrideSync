//
//  StepEntry.swift
//  StrideSync
//
//  Created by johnny basgallop on 11/10/2024.
//

import Foundation

// Step data model for individual entries
struct StepEntry: Identifiable {
    let id = UUID()
    let label: String
    let steps: Int
}
