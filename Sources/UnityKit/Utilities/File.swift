import Foundation

internal func searchPathForResource(
    for filename: String,
    extension ext: String? = nil,
    bundle: Bundle = Bundle.main
) -> URL? {
    guard let enumerator = FileManager.default.enumerator(atPath: bundle.bundlePath)
    else { return nil }
    
    for item in enumerator {
        guard let filePath = item as? String,
              !filePath.starts(with: "Frameworks"),
              !filePath.starts(with: "Base.lproj"),
              !filePath.starts(with: "_CodeSignature"),
              !filePath.starts(with: "META-INF"),
              !filePath.starts(with: "Info.plist")
        else { continue }

        let fullPath = bundle.bundlePath + "/" + filePath
        let url = URL(fileURLWithPath: fullPath)

        if let ext = ext {
            if url.lastPathComponent == filename + "." + ext {
                return url
            }
        } else {
            let bundleFile = splitFilename(url.lastPathComponent)
            let file = splitFilename(filename)

            if let ext1 = file.extension,
               let ext2 = bundleFile.extension {
                if bundleFile.name == file.name,
                   ext1 == ext2 {
                    return url
                }
            } else if bundleFile.name == file.name {
                return url
            }
        }
    }

    return nil
}

internal func splitFilename(_ name: String) -> (name: String, extension: String?) {
    let filename = { () -> String in
        let arr = name.split { $0 == "." }
        return arr.count > 0 ? String(describing: arr.first!) : ""
    }()

    let ext = { () -> String? in
        let arr = name.split { $0 == "." }
        return arr.count > 1 ? String(describing: arr.last!) : nil
    }()

    return (filename, ext)
}
