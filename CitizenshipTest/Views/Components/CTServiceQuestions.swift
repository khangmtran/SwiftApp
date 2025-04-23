//
//  CTServiceQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/27/25.
//
import SwiftUI

struct ServiceQuestions: View {
    let questionId: Int
    @Binding var showingZipPrompt: Bool
    let govAndCap: [CTGovAndCapital]
    @EnvironmentObject var userSetting: UserSetting
    
    var body: some View {
        switch questionId {
        case 20:
            senatorView
        case 23:
            representativeView
        case 43:
            governorView
        case 44:
            capitalView
        default:
            Text("")
        }
    }
    
    private var senatorView: some View {
        VStack{
            let senators = userSetting.legislators.filter {$0.type == "senator"}
            ForEach(senators) { sen in
                Text("\(sen.firstName) \(sen.lastName)")
                .font(.headline)
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Tìm Đại Diện")
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, 5)
        }
    }
    
    private var representativeView: some View {
        VStack {
            let representatives = userSetting.legislators.filter {$0.type == "representative"}
            ForEach(representatives) { rep in
                Text("\(rep.firstName) \(rep.lastName)")
                    .font(.headline)
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Tìm Đại Diện")
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, 5)
            
            if !representatives.isEmpty {
                Text(makeAttributedString())
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func makeAttributedString() -> AttributedString {
        var text = AttributedString("Nếu có nhiều hơn một Hạ nghị sĩ, bạn nên truy cập ")
        
        // Create the link part
        var linkText = AttributedString("house.gov")
        linkText.foregroundColor = .blue
        linkText.underlineStyle = .single
        
        if let url = URL(string: "https://www.house.gov/representatives/find-your-representative") {
            linkText.link = url
        }
        
        // Add the rest of the text
        let endText = AttributedString(" để tìm Hạ nghị sĩ chính xác của bạn")
        
        // Combine all parts
        text.append(linkText)
        text.append(endText)
        
        return text
    }
    
    private var governorView: some View {
        VStack {
            let state = userSetting.state
            ForEach(govAndCap) { gnc in
                if gnc.state == state{
                    Text("\(gnc.gov)")
                        .font(.headline)
                }
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Tìm Đại Diện")
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, 5)
        }
    }
    
    private var capitalView: some View {
        VStack {
            let state = userSetting.state
            ForEach(govAndCap) { gnc in
                if gnc.state == state{
                    Text("\(gnc.capital)")
                        .font(.headline)
                }
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Tìm Đại Diện")
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, 5)
        }
    }
}
