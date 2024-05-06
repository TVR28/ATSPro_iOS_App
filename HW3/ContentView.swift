//
//  ContentView.swift
//  ATSPro
//
//  Created by User2 on 29/04/24.
//
// ContentView.swift
import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var isUnlocked = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isUnlocked {
                    HomeView() // Your content for when the app is unlocked
                } else {
                    VStack {
                        Text("LOCKED")
                            .bold()
                            .padding()
                        
                        Button("Authenticate") {
                            authenticate()
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Authentication Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometrics is available on the device.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // It's available, so use it.
            let reason = "Identify yourself to unlock your account."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                success, authenticationError in
                
                // Ensure we're running on the main thread
                DispatchQueue.main.async {
                    if success {
                        // Authenticated successfully
                        self.isUnlocked = true
                    } else {
                        // There was a problem
                        self.alertMessage = authenticationError?.localizedDescription ?? "Unknown error"
                        self.showingAlert = true
                    }
                }
            }
        } else {
            // No biometrics
            self.alertMessage = error?.localizedDescription ?? "Biometrics not available"
            self.showingAlert = true
        }
    }
}

struct AuthenticatedView: View {
    var body: some View {
        Text("UNLOCKED: Welcome to the app!")
        // Your content for the unlocked state
    }
}


#Preview {
    ContentView()
}
