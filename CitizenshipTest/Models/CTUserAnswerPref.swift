//
//  CTUserAnswerPref.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 7/5/25.
//

import SwiftUI
import SwiftData

@Model
class UserAnswerPref {
    @Attribute(.unique) var questionId: Int
    var answerEn: String
    var answerVie: String

    init(questionId: Int, answerEn: String, answerVie: String) {
        self.questionId = questionId
        self.answerEn = answerEn
        self.answerVie = answerVie
    }
}
