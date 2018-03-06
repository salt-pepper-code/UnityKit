import Foundation

internal func searchPathForResource(forResource filename: String, withExtension: String? = nil, bundle: Bundle = Bundle.main) -> URL? {
    
    let enumerator = FileManager.default.enumerator(atPath: bundle.bundlePath)
    
    while let filePath = enumerator?.nextObject() as? String {
        
        let fullPath = bundle.bundlePath + "/" + filePath
        
        let url = URL(fileURLWithPath: fullPath)
        
        if url.lastPathComponent == filename {
            
            return url
        }
    }
    
    return nil
}
