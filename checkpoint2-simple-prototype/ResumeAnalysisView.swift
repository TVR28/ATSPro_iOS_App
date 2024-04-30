import SwiftUI

// Define the TabItem struct here
struct TabItem {
    var icon: String
    var text: String
}

struct ResultsView: View {
    @State private var selectedTabIndex = 0
    

    var body: some View {
        NavigationView {
            VStack {
                // Custom Tab Bar
                HStack {
                    ForEach(0..<tabItems.count, id: \.self) { index in
                        Button(action: {
                            selectedTabIndex = index
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

                // Content Area Depending on Tab Selection
                Group {
                    switch selectedTabIndex {
                    case 0:
                        ChatView()
                    case 1:
                        ChatView()
                    case 2:
                        ChatView()
                    case 3:
                        ChatView()
                    default:
                        Text("Content not available")
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
