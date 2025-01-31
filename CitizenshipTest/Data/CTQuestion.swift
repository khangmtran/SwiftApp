//
//  CTQuestion.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import Foundation

struct CTQuestion: Codable, Identifiable{
    let id: Int
    let question: String
    let answer: String
    let type: String
}
