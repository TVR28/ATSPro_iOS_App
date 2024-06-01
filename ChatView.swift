import SwiftUI
import GoogleGenerativeAI

struct ChatView: View {
    @State private var questionText: String = ""
    @State private var messages: [(text: String, isUser: Bool)] = []
    var chatContext: String

    @AppStorage("overviewChatMessages") private var overviewChatMessages: String = ""
    @AppStorage("missingKeywordsChatMessages") private var missingKeywordsChatMessages: String = ""
    @AppStorage("suggestionsChatMessages") private var suggestionsChatMessages: String = ""
    @AppStorage("interviewPrepChatMessages") private var interviewPrepChatMessages: String = ""

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
        .onAppear {
            loadMessages()
        }
        .onDisappear {
            saveMessages()
        }
    }

    func sendMessage() {
            guard !questionText.isEmpty else { return }
            messages.append((text: questionText, isUser: true))
            
            let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.geminiKey)
            let prompt = "\(chatContext) Provide response in under 100 words: \(questionText)" // Contextually generate the prompt

            Task {
                do {
                    let response = try await model.generateContent(prompt)
                    DispatchQueue.main.async {
                        let responseText = response.text?.replacingOccurrences(of: "*", with: "") ?? "Failed to generate a response. Please try again."
                        messages.append((text: responseText, isUser: false))
                    }
                } catch {
                    DispatchQueue.main.async {
                        messages.append((text: "Failed to generate a response. Please try again.", isUser: false))
                    }
                }
            }
            questionText = ""
        }
    
    func loadMessages() {
        let savedMessages: String
        switch chatContext {
        case "overview": savedMessages = overviewChatMessages
        case "missingKeywords": savedMessages = missingKeywordsChatMessages
        case "suggestions": savedMessages = suggestionsChatMessages
        case "interviewPrep": savedMessages = interviewPrepChatMessages
        default: savedMessages = ""
        }
        messages = savedMessages.split(separator: "|").compactMap {
            let components = $0.split(separator: ":")
            guard components.count == 2 else { return nil }
            let isUser = components[0] == "1"
            let text = String(components[1])
            return (text: text, isUser: isUser)
        }
    }

    func saveMessages() {
        let savedMessages = messages.map { "\($0.isUser ? 1 : 0):\($0.text)" }.joined(separator: "|")
        switch chatContext {
        case "overview": overviewChatMessages = savedMessages
        case "missingKeywords": missingKeywordsChatMessages = savedMessages
        case "suggestions": suggestionsChatMessages = savedMessages
        case "interviewPrep": interviewPrepChatMessages = savedMessages
        default: break
        }
    }

    func clearMessages() {
        messages.removeAll()
        saveMessages()
    }
}

#Preview {
    ChatView(chatContext: "overview")
}
