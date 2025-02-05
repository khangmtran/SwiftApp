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
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8", "Phần 9"]
    var body: some View{
        VStack{
            if selectedPart.partChosen == "Phần 9"{
                VStack(spacing: 20){
                    Text("Phần 9 sẽ không có từ khóa như những phần từ 1-8. Phần 9 sẽ là phần tập hợp của các câu hỏi còn sót lại.")
                        .font(.system(size: 18))
                    Text("Sẽ có phần \"Từ Trọng Tâm\" ở mỗi câu hỏi để giúp bạn học và nhận diện câu hỏi dễ hơn.\nVí dụ câu hỏi 2 ở phần 1 là: \"What does the Constitution do\" thì bạn chỉ cần nghe được hai từ là \"What\" và \"Constitution do\" để nhận diện được câu hỏi này")
                        .font(.system(size: 18))
                    Text("Lưu ý: Những câu hỏi có dấu * ở cuối câu là những câu hỏi thường gặp trong bài thi.")
                        .font(.system(size: 18))
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(20)
                Spacer()
            }else{
                VStack(spacing: 20){
                    Text("Để giúp bạn học nhanh và dễ dàng hơn, các câu hỏi trong mỗi phần học đã được sắp xếp theo các từ khóa. Những từ khóa này sẽ xuất hiện trong tất cả câu hỏi ở \(selectedPart.partChosen):")
                        .font(.system(size: 18))
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Sẽ có phần \"Từ Trọng Tâm\" ở mỗi câu hỏi để giúp bạn học và nhận diện câu hỏi dễ hơn.\nVí dụ câu hỏi 2 ở phần 1 là: \"What does the Constitution do\" thì bạn chỉ cần nghe được hai từ là \"What\" và \"Constitution do\" để nhận diện được câu hỏi này")
                        .font(.system(size: 18))
                    Text("Lưu ý: Những câu hỏi có dấu * ở cuối câu là những câu hỏi thường gặp trong bài thi.")
                        .font(.system(size: 18))
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(20)
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
}

#Preview {
    NavigationView{
        CTGuide(qIndex: .constant(-1)).environmentObject(SelectedPart())
    }
}
