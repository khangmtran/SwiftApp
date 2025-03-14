//
//  CTResultView.swift
//  CitizenshipTest
//

import SwiftUI
import SwiftData
import AVFoundation

//struct CTResultView: View {
//    let score: Int
//    let questions: [CTQuestion]
//    @State private var synthesizer = AVSpeechSynthesizer()
//    @Environment(\.modelContext) private var context
//    @Query private var markedQuestions: [MarkedQuestion]
//    @EnvironmentObject var deviceManager: DeviceManager
//    @Environment(\.presentationMode) var presentationMode
//    
//    // Add navigation state to control going back to home
//    @State private var navigateToHome = false
//    
//    var body: some View {
//        GeometryReader{geo in
//            VStack {
//                // Score circle
//                ZStack {
//                    Circle()
//                        .fill(.blue.opacity(0.7))
//                        .shadow(radius: 5)
//                        .frame(width: geo.size.width/3)
//                    
//                    VStack {
//                        Text("Score")
//                            .font(deviceManager.isTablet ? .title : .headline)
//                            .foregroundStyle(.white)
//                        
//                        Text("\(score) / 10")
//                            .font(deviceManager.isTablet ? .largeTitle : .title)
//                            .fontWeight(.bold)
//                            .foregroundStyle(.white)
//                        
//                        if score >= 6 {
//                            Text("Passed!")
//                                .font(deviceManager.isTablet ? .title : .headline)
//                                .foregroundStyle(.white)
//                        } else {
//                            Text("Try again!")
//                                .font(deviceManager.isTablet ? .title : .headline)
//                                .foregroundStyle(.white)
//                        }
//                    }
//                }
//                .frame(height: geo.size.height/5)
//                
//                // Question list
//                ScrollView {
//                    VStack(spacing: 15) {
//                        ForEach(questions) { question in
//                            HStack(alignment: .top) {
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text("Q\(question.id): \(question.question)")
//                                        .font(deviceManager.isTablet ? .title3 : .body)
//                                        .fontWeight(.medium)
//                                        .multilineTextAlignment(.leading)
//                                    
//                                    Text("A: \(question.answer)")
//                                        .font(deviceManager.isTablet ? .body : .subheadline)
//                                        .fontWeight(.regular)
//                                }
//                                .padding(.trailing, 8)
//                                
//                                Spacer()
//                                
//                                VStack(spacing: 10) {
//                                    Button(action: {
//                                        synthesizer.stopSpeaking(at: .immediate)
//                                        let utterance = AVSpeechUtterance(string: question.question)
//                                        utterance.voice = AVSpeechSynthesisVoice()
//                                        utterance.rate = 0.3
//                                        synthesizer.speak(utterance)
//                                    }) {
//                                        Image(systemName: "speaker.wave.3")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(height: deviceManager.isTablet ? 25 : 18)
//                                    }
//                                    
//                                    Button(action: {
//                                        if let existingMark = markedQuestions.first(where: {$0.id == question.id}) {
//                                            context.delete(existingMark)
//                                        } else {
//                                            let newMark = MarkedQuestion(id: question.id)
//                                            context.insert(newMark)
//                                        }
//                                    }) {
//                                        Image(systemName: markedQuestions.contains(where: {$0.id == question.id}) ? "bookmark.fill" : "bookmark")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(height: deviceManager.isTablet ? 25 : 18)
//                                    }
//                                }
//                                .padding(.leading, 5)
//                            }
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.blue.opacity(0.1))
//                            )
//                            .padding(.horizontal)
//                        }
//                    }
//                    .padding(.bottom, 100) // Add extra padding at bottom for buttons
//                }
//                
//                // Navigation buttons
//                HStack(spacing: deviceManager.isTablet ? 40 : 20) {
//                    Button(action: {
//                        // Handle "Try Again" - dismiss this view to restart the practice test
//                        self.presentationMode.wrappedValue.dismiss()
//                    }) {
//                        HStack {
//                            Image(systemName: "arrow.counterclockwise")
//                            Text("Try Again")
//                                .font(deviceManager.isTablet ? .title3 : .body)
//                        }
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                    }
//                    
//                    Button(action: {
//                        // Set navigateToHome to true to trigger navigation
//                        navigateToHome = true
//                    }) {
//                        HStack {
//                            Image(systemName: "house")
//                            Text("Home")
//                                .font(deviceManager.isTablet ? .title3 : .body)
//                        }
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .shadow(radius: 2)
//                .frame(maxWidth: .infinity)
//                .padding(.bottom, deviceManager.isTablet ? 20 : 10)
//                
//                // Hidden navigation link that will be triggered when navigateToHome is true
//                NavigationLink(destination: CTHomeMenu(), isActive: $navigateToHome) {
//                    EmptyView()
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
