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
        
        ScrollView{
            if selectedPart.partChosen == "Phần 8"{
                VStack{
                    Text("Phần 8 sẽ không có từ khóa như những phần khác. Phần 8 sẽ là phần tập hợp của các câu hỏi còn lại.")
                        .padding(.bottom)
                    Text("Lưu ý: Những câu hỏi có dấu * là những câu hỏi thường gặp trong bài thi.")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
                
            }else{
                VStack{
                    Text("Để giúp bạn học dễ dàng hơn, các câu hỏi trong mỗi phần học đã được sắp xếp theo các từ khóa. Những từ khóa này sẽ xuất hiện trong tất cả câu hỏi ở \(selectedPart.partChosen):")
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    Text("Lưu ý: Những câu hỏi có dấu * là những câu hỏi thường gặp trong bài thi.")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
                
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
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        CTGuide(qIndex: .constant(-1))
            .environmentObject(SelectedPart())
    }
}
