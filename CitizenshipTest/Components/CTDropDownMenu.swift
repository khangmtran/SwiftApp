//
//  CTDropDownMenu.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI

struct CTDropDownMenu: View{
    @Binding var qIndex: Int
    @State private var isExpanded = false
    @EnvironmentObject var selectedPart : SelectedPart
    
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8"]
    var body: some View{
        ZStack{
            Button(action:{
                withAnimation{
                    isExpanded.toggle()
                }
            }){
                HStack{
                    Text(selectedPart.partChosen)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .frame(width: 100, height: 50)
                .border(.gray, width: 3)
            }
            if isExpanded{
                VStack{
                    ForEach(parts.filter{ $0 != selectedPart.partChosen }, id: \.self){ part in
                        Text(part)
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                selectedPart.partChosen = part
                                isExpanded.toggle()
                                qIndex = -1
                            }
                    }
                }
                .padding(.vertical, 10)
                .frame(width: 100)
                .background(.white)
                .border(.gray, width: 3)
                .offset(y: 110)
                .zIndex(1)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    CTDropDownMenu(qIndex: .constant(-1))
        .environmentObject(SelectedPart())
}
