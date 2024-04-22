import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                FileHandlingView()
                SettingsView()
            }
            .navigationBarTitle("Media and Settings Demo")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
