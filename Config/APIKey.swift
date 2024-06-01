
import Foundation

enum APIKey {
    static var geminiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Gemini-api", ofType: "plist")
        else {
            fatalError("Couldn't find file 'Gemini-api.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'Gemini-api.plist'.")
        }
        if value.starts(with: "_") || value.isEmpty {
            fatalError(
                "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
            )
        }
        return value
    }
}
