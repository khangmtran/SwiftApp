//
//  CTTestProgress.swift
//  CitizenshipTest
//
//  Created on 3/24/25.
//

import SwiftUI
import SwiftData

// Enum to distinguish between different test types
enum TestType: String, Codable {
    case practice = "practice"
    case allQuestions = "allQuestions"
    case markedQuestions = "markedQuestions"
}

// SwiftData model to store test progress
@Model
class CTTestProgress {
    var testType: String
    var currentIndex: Int
    var score: Int
    var questionIds: [Int]
    var userAnswers: [Bool]
    var incorrectAnswers: [String]
    
    init(testType: TestType, currentIndex: Int = 0, score: Int = 0, questionIds: [Int] = [], userAnswers: [Bool] = [], incorrectAnswers: [String] = []) {
        self.testType = testType.rawValue
        self.currentIndex = currentIndex
        self.score = score
        self.questionIds = questionIds
        self.userAnswers = userAnswers
        self.incorrectAnswers = incorrectAnswers
    }
    
    func getTestType() -> TestType {
        return TestType(rawValue: testType) ?? .practice
    }
    
}
