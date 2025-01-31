//
//  CTAllQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI

struct CTAllQuestions: View {
    @State private var questions:[CTQuestion] = []
    var body: some View {
        List(questions){question in
            VStack{
                Text(question.question)
            }
        }
        .onAppear{
            questions = CTDataLoader().loadQuestions()
        }
    }
}

#Preview {
    CTAllQuestions()
}
