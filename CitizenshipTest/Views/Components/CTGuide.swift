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
    @EnvironmentObject var dvice: DeviceManager
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8", "Phần 9"]
    var body: some View{
        
        ScrollView{
            if selectedPart.partChosen == "Phần 9"{
                VStack{
                    Text("Phần 9 sẽ không có từ khóa như những phần từ 1-8. Phần 9 sẽ là phần tập hợp của các câu hỏi còn sót lại.")
                        .font(dvice.isTablet ? .title : .body)
                    Text("Sẽ có phần \"Từ Trọng Tâm\" ở mỗi câu hỏi để giúp bạn học và nhận diện câu hỏi dễ hơn.\nVí dụ câu hỏi 2 ở phần 1 là: \"What does the Constitution do\" thì bạn chỉ cần nghe được hai từ là \"What\" và \"Constitution do\" để nhận diện được câu hỏi này")
                        .font(dvice.isTablet ? .title : .body)
                        .padding(.top)
                    Text("Lưu ý: Những câu hỏi có dấu * ở cuối câu là những câu hỏi thường gặp trong bài thi.")
                        .font(dvice.isTablet ? .title : .body)
                        .padding(.top)
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(20)
                
            }else{
                VStack{
                    Text("Để giúp bạn học nhanh và dễ dàng hơn, các câu hỏi trong mỗi phần học đã được sắp xếp theo các từ khóa. Những từ khóa này sẽ xuất hiện trong tất cả câu hỏi ở \(selectedPart.partChosen):")
                        .font(dvice.isTablet ? .title : .body)
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .font(dvice.isTablet ? .title : .body)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    Text("Sẽ có phần \"Từ Trọng Tâm\" ở mỗi câu hỏi để giúp bạn học và nhận diện câu hỏi dễ hơn.\nVí dụ câu hỏi 2 ở phần 1 là: \"What does the Constitution do\" thì bạn chỉ cần nghe được hai từ là \"What\" và \"Constitution do\" để nhận diện được câu hỏi này")
                        .font(dvice.isTablet ? .title : .body)
                        .padding(.top)
                    Text("Lưu ý: Những câu hỏi có dấu * ở cuối câu là những câu hỏi thường gặp trong bài thi.")
                        .font(dvice.isTablet ? .title : .body)
                        .padding(.top)
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
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
                            .font(dvice.isTablet ? .largeTitle : .title3)
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(height: dvice.isTablet ? 20 : 10)
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
            .environmentObject(DeviceManager())
    }
}
