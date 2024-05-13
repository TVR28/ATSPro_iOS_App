import SwiftUI

struct TabItem {
    var icon: String
    var text: String
}

struct ResultsView: View {
    @State private var selectedTabIndex = 0
    @State private var resetChat = false
    @State private var geminiResponseText: String = "Loading response..."

    let responses = [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    ]

    var body: some View {
        NavigationView {
            VStack {
                // Custom Tab Bar
                HStack {
                    ForEach(0..<tabItems.count, id: \.self) { index in
                        Button(action: {
                            selectedTabIndex = index
                            resetChat = false
                            loadGeminiResponse(for: index)
                        }) {
                            VStack {
                                Image(systemName: tabItems[index].icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedTabIndex == index ? .blue : .gray)
                                Text(tabItems[index].text)
                                    .font(.caption)
                                    .foregroundColor(selectedTabIndex == index ? .blue : .gray)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .background(Color.white.edgesIgnoringSafeArea(.top))

                // Google Gemini Response Text
                Text("Google Gemini Response")
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    Text(geminiResponseText)
                        .padding()
                }
                .frame(height: 150)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding([.leading, .trailing, .bottom])

                // Content Area Depending on Tab Selection
                Group {
                    let context = tabItems[selectedTabIndex].text.replacingOccurrences(of: " ", with: "").lowercased()
                    ChatView(chatContext: context)
                        .onAppear {
                            if resetChat {
                                resetChat = false
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Spacer()
            }
            .navigationTitle("Generated Responses")
            .navigationBarItems(trailing: Button(action: {
                // Download action
            }) {
                Image(systemName: "arrow.down.circle")
                Text("Download")
            })
        }
        .onAppear {
            clearAllChatsAndResponses()
            resetChat = true
            loadGeminiResponse(for: selectedTabIndex)
        }
    }

    func loadGeminiResponse(for index: Int) {
        geminiResponseText = responses[index]
    }

    func clearAllChatsAndResponses() {
        UserDefaults.standard.setValue("", forKey: "overviewChatMessages")
        UserDefaults.standard.setValue("", forKey: "missingKeywordsChatMessages")
        UserDefaults.standard.setValue("", forKey: "suggestionsChatMessages")
        UserDefaults.standard.setValue("", forKey: "interviewPrepChatMessages")
    }
}

let tabItems: [TabItem] = [
    TabItem(icon: "doc.text.image", text: "Overview"),
    TabItem(icon: "key.fill", text: "Missing Keywords"),
    TabItem(icon: "lightbulb.fill", text: "Suggestions"),
    TabItem(icon: "person.fill.questionmark", text: "Interview Prep")
]

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
