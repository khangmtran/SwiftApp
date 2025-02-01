//
//  CTGuide.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/31/25.
//

import SwiftUI

struct CTGuide: View {
    @EnvironmentObject var selectedPart: SelectedPart
    @Binding var qIndex: Int
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8"]
    var body: some View{
        VStack{
            VStack(spacing: 20){
                Text("Để giúp bạn học nhanh và dễ dàng hơn, các câu hỏi trong mỗi phần học đã được sắp xếp theo các từ khóa. Những từ khóa này sẽ xuất hiện trong tất cả câu hỏi ở \(selectedPart.partChosen).")
                Text(partMessages[selectedPart.partChosen] ?? "")
                    .multilineTextAlignment(.center)
                Text("Lưu ý: Những câu hỏi có dấu * ở cuối câu là những câu hỏi thường gặp trong bài thi.")
                Spacer()
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Menu {
                    ForEach(parts.filter { $0 != selectedPart.partChosen }, id: \.self) { part in
                        Button(part) {
                            selectedPart.partChosen = part
                            qIndex = -1
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedPart.partChosen)
                        Image(systemName: "chevron.down")
                    }
                    .frame(width: 100, height: 35)
                    .border(.gray, width: 3)
                }
            }
        }
    }
    static let p1msg = "Constitution - Hiến Pháp\nConstitutional - Thuộc về hiến pháp\nAmendment - Tu chính án"
    let partMessages = [
        "Phần 1": p1msg,
        "Phần 2": "Ở phần 2, bạn nên lưu ý",
        "Phần 3": "Ở phần 3, bạn nên lưu ý",
        "Phần 4": "Ở phần 4, bạn nên lưu ý",
        "Phần 5": "Ở phần 5, bạn nên lưu ý",
        "Phần 6": "Ở phần 6, bạn nên lưu ý",
        "Phần 7": "Ở phần 7, bạn nên lưu ý",
        "Phần 8": "Ở phần 8, bạn nên lưu ý"
    ]
    
    
}

#Preview {
    NavigationView{
        CTGuide(qIndex: .constant(-1)).environmentObject(SelectedPart())
    }
}
