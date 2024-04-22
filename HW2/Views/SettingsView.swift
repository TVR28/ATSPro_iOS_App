import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("appName") private var appName = "MediaApp"
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var tempAppName: String = ""
    @State private var isEditingAppName: Bool = false
    @State private var showingFilePicker = false
    @State private var resumeURL: URL?

    var body: some View {
        Form {
            Section(header: Text("User Settings")) {
                            HStack {
                                if isEditingAppName {
                                    TextField("App Name", text: $tempAppName, prompt: Text("Enter app name"))
                                } else {
                                    Text("App Name")
                                    Spacer()
                                    Text(appName)
                                        .foregroundColor(.gray)
                                }
                            }
                            if isEditingAppName {
                                Button("Save") {
                                    appName = tempAppName
                                    isEditingAppName = false
                                }
                            } else {
                                Button("Edit") {
                                    tempAppName = appName // Pre-fill the temporary name
                                    isEditingAppName = true
                                }
                            }
                
                Toggle("Enable Dark Mode", isOn: $darkModeEnabled)
                
                if let resumeURL = resumeURL {
                    Text("Default Resume: \(resumeURL.lastPathComponent)")
                }
                
                Button("Select Default Resume") {
                    showingFilePicker = true
                }
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            FilePickerView(onPick: handlePickedResume)
        }
        .navigationTitle("Settings")
        .navigationBarItems(trailing: EditButton())
        .onAppear {
            tempAppName = appName // Load the current app name from UserDefaults
        }
        .onChange(of: darkModeEnabled) { _ in
            // Apply the dark mode setting throughout the app
            UIApplication.shared.windows.first?.rootViewController?.view.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
        }
    }
    
    private func handlePickedResume(_ url: URL, _ type: UTType) {
        if type == UTType.pdf {
            resumeURL = url
            // Handle saving the resume file URL here
            // ...
        }
    }
}
