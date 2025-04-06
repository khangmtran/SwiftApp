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
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @State private var showingZipPrompt = false
    @State private var voices: [AVSpeechSynthesisVoice] = []
    
    var body: some View {
        ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text("ZIP Code")
                            .font(deviceManager.isTablet ? .title3 : .body)
                        Text("Mã ZIP")
                            .font(deviceManager.isTablet ? .footnote : .caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(userSetting.zipCode)
                        .font(deviceManager.isTablet ? .title3 : .body)
                    
                    Button(action: {
                        showingZipPrompt = true
                    }) {
                        Image(systemName: "pencil")
                            .imageScale(.medium)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("State")
                            .font(deviceManager.isTablet ? .title3 : .body)
                        Text("Tiểu Bang")
                            .font(deviceManager.isTablet ? .footnote : .caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(userSetting.state)
                        .font(deviceManager.isTablet ? .title3 : .body)
                }
                
                let senators = userSetting.legislators.filter { $0.type == "senator" }
                ForEach(senators) { senator in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Senator")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Thượng Nghị Sĩ")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(senator.firstName) \(senator.lastName)")
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                let representatives = userSetting.legislators.filter { $0.type == "representative" }
                ForEach(representatives) { rep in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Representative")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Hạ Nghị Sĩ")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(rep.firstName) \(rep.lastName)")
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                let stateInfo = govCapManager.govAndCap.filter { $0.state == userSetting.state }
                ForEach(stateInfo) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Governor")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Thống Đốc")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.gov)
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Capital City")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Thủ Phủ")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.capital)
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                }
        
            
            
            Text("Âm Thanh")
                

            VStack{
                Text("Tốc độ đọc")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("0.1")
                        .font(deviceManager.isTablet ? .footnote : .caption)
                        .foregroundColor(.gray)
                    
                    Slider(value: $audioManager.speechRate, in: 0.1...1.0, step: 0.1)
                    
                    Text("1.0")
                        .font(deviceManager.isTablet ? .footnote : .caption)
                        .foregroundColor(.gray)
                }
                
                HStack{
                    Text("Giọng đọc")
                        Spacer()
                        
                        Picker(selection: $audioManager.voiceIdentifier, label: HStack {
                            Text(audioManager.voiceActor)
                                .font(deviceManager.isTablet ? .title3 : .body)
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
                            }
                        }
                }
            }
            
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingZipPrompt) {
                CTZipInput()
                    .environmentObject(userSetting)
                    .environmentObject(deviceManager)
            }
        }
        .padding()
        .onAppear(){
            voices = audioManager.getVoices()
        }
    }
}

#Preview {
    CTSetting()
        .environmentObject(UserSetting())
        .environmentObject(DeviceManager())
        .environmentObject(GovCapManager())
        .environmentObject(AudioManager())
}
