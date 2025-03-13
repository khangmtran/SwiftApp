//
//  CTIncorrectAnswer.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/12/25.
//

struct CTWrongAnswer: Codable, Identifiable{
    let id: Int
    let firstIncorrect: String
    let secondIncorrect: String
    let thirdIncorrect: String
}
