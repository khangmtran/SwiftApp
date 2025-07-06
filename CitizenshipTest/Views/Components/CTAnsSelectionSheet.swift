//
//  CTAnsSelectionSheet.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 7/5/25.
//

import SwiftUI
struct AnswerSelectionSheet: View {
    let question: CTQuestion
    let onSelect: (AnswerPair) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if let answers = question.answers {
                    ForEach(answers, id: \.en) { ans in
                        Button(action: {
                            onSelect(ans)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ans.en)
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                Text(ans.vie)
                                    .font(.subheadline)
                                    .foregroundStyle(.black)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    Text("Không có đáp án thay thế cho câu hỏi này.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Chọn Đáp Án Khác")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark").foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

