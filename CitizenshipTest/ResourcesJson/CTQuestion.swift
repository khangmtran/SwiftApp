//
//  CTQuestion.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI

struct CTQuestion: Codable, Identifiable{
    let id: Int
    let question: String
    let questionVie: String
    var answer: String
    let answerVie: String
    let type: String
    let learn: String
    var star: Bool? = false
}
