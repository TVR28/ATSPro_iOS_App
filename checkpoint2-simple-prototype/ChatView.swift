//
//  ChatView.swift
//  ATSPro
//
//  Created by User2 on 29/04/24.
//

import SwiftUI

struct ChatView: View {
    @State private var questionText: String = ""
    @State private var messages: [(text: String, isUser: Bool)] = []

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages, id: \.text) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 300, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 300, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
            }

            HStack {
                TextField("Ask something...", text: $questionText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    sendMessage()
                }
            }
            .padding()
        }
    }

    func sendMessage() {
        guard !questionText.isEmpty else { return }
        messages.append((text: questionText, isUser: true))
        // Simulate a response (In a real app, integrate with a model or backend)
        messages.append((text: "Simulated response for '\(questionText)'", isUser: false))
        questionText = ""
    }
}


#Preview {
    ChatView()
}
