import SwiftUI

enum Features: String, CaseIterable {
    case 📄 = "📄"
    case 🔎 = "🔎"
    case 💡 = "💡"
    case 👨🏻‍💻 = "👨🏻‍💻"
}

struct ContentView: View {
    @State private var selection: Features = .📄
    @State private var isDarkTheme = false  // State to toggle theme

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Emoji Display
                Text(selection.rawValue)
                    .font(.system(size: 150))
                    .foregroundColor(isDarkTheme ? .white : .black)
                
                // Feature Description
                Text(featureDescription(for: selection))
                    .font(.system(size: 30, weight: .bold))
                    .padding()
                    .foregroundColor(isDarkTheme ? .white : .black)
                
                Spacer()
                
                // Feature Selection Picker
                Picker("Select Feature", selection: $selection) {
                    ForEach(Features.allCases, id: \.self) { emoji in
                        Text(emoji.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Spacer()
            }
            .padding()
            .background(isDarkTheme ? Color.black : Color.white)
            .navigationTitle("ATSPro")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $isDarkTheme) {
                        Image(systemName: "moon.fill")// Icon for the toggle
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue)) // Custom styling for the toggle
                }
            }
        }
        .preferredColorScheme(isDarkTheme ? .dark : .light)  // Apply overall dark/light theme
    }
    
    // Function to return the feature description based on the emoji
    private func featureDescription(for feature: Features) -> String {
        switch feature {
        case .📄:
            return "Resume Match %"
        case .🔎:
            return "Missing Keywords"
        case .💡:
            return "Suggestions"
        case .👨🏻‍💻:
            return "Interview Prep"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


