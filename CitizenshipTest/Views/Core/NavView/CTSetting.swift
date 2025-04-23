//
//  CTSetting.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/19/25.
//

import SwiftUI
import AVFoundation

struct CTSetting: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @State private var showingZipPrompt = false
    @State private var voices: [AVSpeechSynthesisVoice] = []
    @State private var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ScrollView {
            Text("Đại Diện Của Bạn")
                .font(.title3)
                .fontWeight(.semibold)
            VStack{
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading) {
                        Text("ZIP Code")
                            .font(.callout)
                        Text("Mã ZIP")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(userSetting.zipCode).font(.callout)
                    
                    Button(action: {
                        showingZipPrompt = true
                    }) {
                        Image(systemName: "pencil")
                            .imageScale(.medium)
                    }
                }
                
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading) {
                        Text("State")
                            .font(.callout)
                        Text("Tiểu Bang")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(userSetting.state).font(.callout)
                }
                
                let stateInfo = govCapManager.govAndCap.filter { $0.state == userSetting.state }
                ForEach(stateInfo) { item in
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text("Capital City")
                                .font(.callout)
                            Text("Thủ Phủ")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.capital).font(.callout)
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text("Governor")
                                .font(.callout)
                            Text("Thống Đốc")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.gov).font(.callout)
                    }
                    
                }
                
                let representatives = userSetting.legislators.filter { $0.type == "representative" }
                ForEach(representatives) { rep in
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text("Representative")
                                .font(.callout)
                            Text("Hạ Nghị Sĩ")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(rep.firstName) \(rep.lastName)").font(.callout)
                    }
                }
                
                let senators = userSetting.legislators.filter { $0.type == "senator" }
                ForEach(senators) { senator in
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text("Senator")
                                .font(.callout)
                            Text("Thượng Nghị Sĩ")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(senator.firstName) \(senator.lastName)").font(.callout)
                    }
                }
                                
            }
            .padding()
            .background(.blue.opacity(0.1))
            .cornerRadius(10)
            
            Text("Âm Thanh")
                .font(.title3)
                .fontWeight(.semibold)
                

            VStack{
                Text("Tốc độ đọc")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("1")
                        .foregroundColor(.gray)
                    
                    Slider(value: $audioManager.speechRate, in: 0.1...0.5, step: 0.1)
                        .onChange(of: audioManager.speechRate){
                            synthesizer.stopSpeaking(at: .immediate)
                            let sampleText = "This is the voice of \(audioManager.voiceActor)."
                            let utterance = AVSpeechUtterance(string: sampleText)
                            utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                            utterance.rate = audioManager.speechRate
                            synthesizer.speak(utterance)
                        }
                    
                    Text("5")
                        .foregroundColor(.gray)
                }
                
                HStack{
                    Text("Giọng đọc")
                        Spacer()
                        
                        Picker(selection: $audioManager.voiceIdentifier, label: HStack {
                            Text(audioManager.voiceActor.isEmpty ? "Chọn Người Đọc" : audioManager.voiceActor)
                            Image(systemName: "chevron.down")
                        }) {
                            ForEach(voices, id: \.self) { voice in
                                Text(voice.name).tag(voice.identifier)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: audioManager.voiceIdentifier) {
                            if let voice = voices.first(where: { $0.identifier == audioManager.voiceIdentifier }) {
                                audioManager.voiceActor = voice.name
                                synthesizer.stopSpeaking(at: .immediate)
                                let sampleText = "This is the voice of \(audioManager.voiceActor)"
                                let utterance = AVSpeechUtterance(string: sampleText)
                                utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                utterance.rate = audioManager.speechRate
                                synthesizer.speak(utterance)
                            }
                        }
                }
            }
            .padding()
            .background(.blue.opacity(0.1))
            .cornerRadius(10)
            
        }
        .padding()
        .onAppear(){
            voices = audioManager.getVoices()
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
        }
        .navigationTitle("Cài Đặt")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
        }
    }
}

#Preview {
    CTSetting()
        .environmentObject(UserSetting())
        .environmentObject(GovCapManager())
        .environmentObject(AudioManager())
}
