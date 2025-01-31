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
                print("Could not find CTQuestionsJSON.json file")
                return []
            }
            do{
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let questions = try decoder.decode([CTQuestion].self, from:data)
                return questions
            }catch{
                print("Error decoding JSON: \(error)")
                return []
            }
        }
}
