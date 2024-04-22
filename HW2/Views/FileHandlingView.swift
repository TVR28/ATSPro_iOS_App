import SwiftUI
import UniformTypeIdentifiers

struct FileHandlingView: View {
    @State private var showFilePicker = false
    @State private var fileURL: URL?
    @State private var pickedFileType: UTType?

    var body: some View {
        VStack {
            Button("Select File") {
                showFilePicker = true
            }
            
            if let fileURL = fileURL, let fileType = pickedFileType {
                Text("Picked \(fileType.description): \(fileURL.lastPathComponent)")
                    .padding()
                
                // If the file is an image, display it
                if fileType == UTType.image {
                    Image(uiImage: loadImageFromAppDirectory(url: fileURL))
                        .resizable()
                        .scaledToFit()
                }
                // Add views here for PDF and audio if needed
            }
        }
        .sheet(isPresented: $showFilePicker) {
            FilePickerView(onPick: handlePickedFile)
        }
    }
    
    func handlePickedFile(_ url: URL, _ type: UTType) {
        self.fileURL = saveFileToAppDirectory(fileURL: url)
        self.pickedFileType = type
    }

    func saveFileToAppDirectory(fileURL: URL) -> URL? {
        let fileManager = FileManager.default
        let appDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = appDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: localURL.path) {
                try fileManager.removeItem(at: localURL)
            }
            try fileManager.copyItem(at: fileURL, to: localURL)
            print("File saved to App directory: \(localURL)")
            return localURL
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImageFromAppDirectory(url: URL) -> UIImage {
        if let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            return image
        }
        return UIImage() // Return a default image if none is found
    }
}

struct FilePickerView: UIViewControllerRepresentable {
    var onPick: (URL, UTType) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.pdf, .image, .audio]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePickerView
        
        init(_ parent: FilePickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let fileUrl = urls.first,
                  let fileType = UTType(filenameExtension: fileUrl.pathExtension) else { return }
            parent.onPick(fileUrl, fileType)
        }
    }
}
