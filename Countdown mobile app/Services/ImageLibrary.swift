import UIKit

class ImageLibrary {
    
    // MARK: - Constants & Singleton
    
    static let shared = ImageLibrary()
    
    private init() { }
    
    // MARK: Methods
    
    func saveImage(image: UIImage, imageName: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else { return false }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(imageName).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func getSavedImage(named: String) -> UIImage? {
        if let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: directory.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func deleteImage(imageName: String) -> Bool {
        let fileManager = FileManager.default
        guard let directory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return false }
        let imageURL = directory.appendingPathComponent("\(imageName).png")
        print(fileManager.fileExists(atPath: imageURL.absoluteString))
        if fileManager.fileExists(atPath: imageURL.absoluteString) {
            do {
                try fileManager.removeItem(at: imageURL)
                return true
            } catch {
                print(error.localizedDescription)
            }
        }
        return false
    }
}
