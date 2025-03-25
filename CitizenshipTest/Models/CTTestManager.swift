//
//  CTTestProgressManager.swift
//  CitizenshipTest
//
//  Created on 3/24/25.
//

import SwiftUI
import SwiftData

class TestProgressManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Get existing progress for a test type, or nil if none exists
    func getProgress(for testType: TestType) throws -> CTTestProgress? {
        let descriptor = FetchDescriptor<CTTestProgress>(
            predicate: #Predicate<CTTestProgress> { progress in
                progress.testType == testType.rawValue
            }
        )
        
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
    
    // Save or update progress for a test
    func saveProgress(testType: TestType,
                     currentIndex: Int,
                     score: Int,
                     questionIds: [Int],
                     userAnswers: [Bool],
                     incorrectAnswers: [String]) throws {
        // Check if progress already exists for this test type
        if let existingProgress = try getProgress(for: testType) {
            // Update existing progress
            existingProgress.currentIndex = currentIndex
            existingProgress.score = score
            existingProgress.questionIds = questionIds
            existingProgress.userAnswers = userAnswers
            existingProgress.incorrectAnswers = incorrectAnswers
        } else {
            // Create new progress
            let newProgress = CTTestProgress(
                testType: testType,
                currentIndex: currentIndex,
                score: score,
                questionIds: questionIds,
                userAnswers: userAnswers,
                incorrectAnswers: incorrectAnswers
            )
            modelContext.insert(newProgress)
        }
    }
    
    // Clear progress for a specific test type
    func clearProgress(for testType: TestType) throws {
        if let existingProgress = try getProgress(for: testType) {
            modelContext.delete(existingProgress)
        }
    }
    
}
