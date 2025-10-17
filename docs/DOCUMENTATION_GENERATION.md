# UnityKit Documentation Generation Guide

This guide explains how to generate and view UnityKit's comprehensive API documentation.

---

## Option 1: Using Xcode (Easiest)

### Build Documentation in Xcode

1. **Open the project in Xcode:**
   ```bash
   open Package.swift
   ```

2. **Build Documentation:**
   - Select **Product → Build Documentation** (⌃⇧⌘D)
   - Or right-click on "UnityKit" in the Project Navigator → **Build Documentation**

3. **View Documentation:**
   - Xcode will automatically open the Documentation Viewer
   - Browse all documented APIs with full formatting, examples, and navigation

4. **Export Documentation:**
   - In Documentation Viewer: **Product → Export Documentation**
   - Choose a location to save the `.doccarchive`
   - Share the archive or host it

### Quick Help in Xcode

- **⌥ + Click** on any symbol to see inline documentation
- Works immediately without building documentation

---

## Option 2: Using Swift-DocC Plugin (Command Line)

### Step 1: Add DocC Plugin to Package.swift

Update your `Package.swift`:

```swift
// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "UnityKit",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "UnityKit", targets: ["UnityKit"]),
    ],
    dependencies: [
        // Add DocC plugin
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "UnityKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "UnityKitTests",
            dependencies: ["UnityKit"],
            path: "Tests",
            exclude: ["TESTING_GUIDE.md"]
        ),
    ]
)
```

### Step 2: Generate Documentation

```bash
# Preview documentation locally (auto-refreshes)
swift package --disable-sandbox preview-documentation --target UnityKit

# Build documentation archive
swift package generate-documentation \
    --target UnityKit \
    --output-path ./docs/UnityKit.doccarchive

# Build for hosting on web
swift package generate-documentation \
    --target UnityKit \
    --hosting-base-path UnityKit \
    --output-path ./docs/web
```

### Step 3: View Documentation

The preview command will output a URL like:
```
Preview server running at http://localhost:8000/documentation/unitykit
```

Open that URL in your browser.

---

## Option 3: Using xcodebuild (No Plugin Required)

This works without modifying Package.swift:

### Generate Documentation Archive

```bash
# Build for iOS Simulator
xcodebuild docbuild \
    -scheme UnityKit \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -derivedDataPath ./build

# Find the .doccarchive
find ./build -name "*.doccarchive"
```

### Preview Documentation

```bash
# Install docc command-line tool (if not already installed)
brew install swift-docc

# Preview the archive
docc preview ./build/.../UnityKit.doccarchive
```

---

## Option 4: GitHub Pages (Web Hosting)

### Step 1: Generate Static HTML

Create `.github/workflows/documentation.yml`:

```yaml
name: Build Documentation

on:
  push:
    branches: [main, master]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: macos-13
    steps:
      - uses: actions/checkout@v4

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable

      - name: Build Documentation
        run: |
          xcodebuild docbuild \
            -scheme UnityKit \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -derivedDataPath ./build

          # Find and process doccarchive
          DOCC_ARCHIVE=$(find ./build -name "*.doccarchive")

          # Convert to static HTML
          $(xcrun --find docc) process-archive \
            transform-for-static-hosting "$DOCC_ARCHIVE" \
            --hosting-base-path UnityKit \
            --output-path ./docs

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: ./docs

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

### Step 2: Enable GitHub Pages

1. Go to **Settings → Pages**
2. Source: **GitHub Actions**
3. Save

Your documentation will be available at:
```
https://YOUR_USERNAME.github.io/UnityKit/documentation/unitykit/
```

---

## Quick Reference

### Which Option Should I Use?

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| **Xcode** | Development & Testing | Easy, integrated, no setup | Xcode required |
| **Swift-DocC Plugin** | CI/CD & Automation | Command-line friendly | Requires Package.swift change |
| **xcodebuild** | Build Scripts | No Package.swift changes | More complex commands |
| **GitHub Pages** | Public Hosting | Free hosting, always updated | Requires GitHub Actions setup |

### Recommended Workflow

1. **During Development**: Use Xcode (⌃⇧⌘D)
2. **For Sharing**: Use GitHub Pages
3. **For CI/CD**: Use Swift-DocC Plugin or xcodebuild

---

## Viewing Generated Documentation

### .doccarchive Files

Double-click `.doccarchive` files to open in Xcode's Documentation Viewer.

Or preview from command line:
```bash
xcrun docc preview UnityKit.doccarchive
```

### Static HTML

Serve locally:
```bash
cd docs
python3 -m http.server 8080
# Open http://localhost:8080
```

---

## Troubleshooting

### "Unknown subcommand generate-documentation"

**Solution**: Add the Swift-DocC plugin to Package.swift (see Option 2)

### "No such module 'UnityKit'"

**Solution**: Build the package first:
```bash
swift build
swift package generate-documentation --target UnityKit
```

### "Documentation not showing in Xcode"

**Solution**:
1. Clean build folder: ⌘⇧K
2. Rebuild documentation: ⌃⇧⌘D

### Documentation symbols not linking

**Solution**: Use proper DocC syntax:
- Single backticks for code: `myFunction()`
- Double backticks for symbol links: ``GameObject``

### Missing examples in generated docs

**Solution**: Ensure code blocks use triple-backtick syntax:
````markdown
```swift
let example = GameObject()
```
````

---

## Documentation Features

All UnityKit documentation includes:

- ✅ **Quick Help** - ⌥+Click any symbol in Xcode
- ✅ **Symbol Links** - Navigate between related types
- ✅ **Code Examples** - 200+ practical examples
- ✅ **Topics** - Organized API groupings
- ✅ **Search** - Full-text search in Documentation Viewer
- ✅ **Export** - Share as .doccarchive
- ✅ **Web Hosting** - Deploy to GitHub Pages

---

## Additional Resources

- [Swift-DocC Documentation](https://www.swift.org/documentation/docc/)
- [Apple DocC Tutorial](https://developer.apple.com/documentation/docc)
- [DocC Syntax Guide](https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/)
- [UnityKit API Reference](../API_REFERENCE.md)
- [UnityKit Wiki Setup](WIKI_SETUP.md)

---

**Next Steps:**
1. Choose your preferred documentation generation method
2. Generate the documentation
3. Browse the comprehensive API reference
4. Share with your team or community!
