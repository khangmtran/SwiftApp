//
//  CTDataLoader.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import Foundation

class CTDataLoader{
    func loadQuestions() -> [CTQuestion]{
            guard let url = Bundle.main.url(forResource: "CTQuestionsJSON", withExtension: "json") else{
                return []
            }
            do{
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let questions = try decoder.decode([CTQuestion].self, from:data)
                return questions
            }catch{
                return []
            }
        }
    
    func loadGovAndCapital() -> [CTGovAndCapital]{
        guard let url = Bundle.main.url(forResource: "CTGovAndCapitalJSON", withExtension: "json") else{
            return []
        }
        do{
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let govNCap = try decoder.decode([CTGovAndCapital].self, from:data)
            return govNCap
        }catch{
            return []
        }
    }
    
    func loadWrongAnswers() -> [CTWrongAnswer]{
        guard let url = Bundle.main.url(forResource: "CTWrongAnswerJSON", withExtension: "json") else{
            return []
        }
        do{
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let wrongAns = try decoder.decode([CTWrongAnswer].self, from: data)
            return wrongAns
        }catch{
            return []
        }
    }
    
}
