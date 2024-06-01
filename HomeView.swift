import SwiftUI
import UIKit
import PDFKit

struct HomeView: View {
    @State private var jobRole: String = ""
    @State private var jobDescription: String = ""
    @State private var isShowingDocumentPicker = false
    @State private var extractedText: String?
    @State private var navigateToResults = false  // State to control navigation

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Job Role")) {
                        TextField("Enter Job Role", text: $jobRole)
                    }
                    
                    Section(header: Text("Job Description")) {
                        TextField("Enter Job Description", text: $jobDescription)
                    }
                    
                    Section {
                        Button(action: {
                            isShowingDocumentPicker = true
                        }) {
                            HStack {
                                Image(systemName: "cloud.upload.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                                Text("Upload Your Resume")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(10)
                        }
                    }.textCase(nil)

                    if let text = extractedText {
                        Section(header: Text("Extracted Text")) {
                            Text(text).foregroundColor(.gray)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            self.navigateToResults = true  // Trigger navigation
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                                Text("Generate")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                    }.textCase(nil)
                }
                
                Spacer() // Creates space at the bottom
                NavigationLink(destination: ResultsView(jobRole: jobRole, jobDescription: jobDescription, resumeText: extractedText ?? ""), isActive: $navigateToResults) {
                    EmptyView()
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
//            .toolbar {
//                Button(action: {
//                    // Code for menu action
//                }) {
//                    Image(systemName: "line.horizontal.3")
//                }
//            }
            .sheet(isPresented: $isShowingDocumentPicker) {
                DocumentPicker { url in
                    handlePickedDocument(url: url)
                }
            }
        }
    }
    
    func handlePickedDocument(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let localURL = documentDirectory.appendingPathComponent(url.lastPathComponent)
            
            if fileManager.fileExists(atPath: localURL.path) {
                try fileManager.removeItem(at: localURL)
            }
            
            try fileManager.copyItem(at: url, to: localURL)
            
            // After storing the PDF, extract text from it
            if let text = extractText(from: localURL) {
                extractedText = text
            } else {
                print("Failed to extract text.")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func extractText(from url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else { return nil }
        let pageCount = pdfDocument.pageCount
        let documentContent = NSMutableString()
        
        for i in 0..<pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            guard let pageContent = page.string else { continue }
            documentContent.append(pageContent)
        }
        
        return documentContent as String
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ documentPicker: DocumentPicker) {
            self.parent = documentPicker
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
        }
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
