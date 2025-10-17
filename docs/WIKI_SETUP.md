# GitHub Wiki Setup Guide

This guide explains how to integrate UnityKit's documentation with GitHub Wiki.

## Approach 1: Automated Sync (Recommended)

The repository includes a GitHub Actions workflow that automatically syncs documentation to the Wiki.

### Setup Steps

1. **Enable GitHub Wiki for your repository**
   - Go to Settings → Features → Enable Wiki

2. **Initialize the Wiki**
   - Navigate to the Wiki tab
   - Create the first page (it will create the Wiki repository)

3. **Push the workflow**
   ```bash
   git add .github/workflows/sync-wiki.yml
   git commit -m "Add wiki sync workflow"
   git push origin master
   ```

4. **First sync**
   - Go to Actions tab → "Sync Documentation to Wiki"
   - Click "Run workflow"
   - The workflow will create/update these pages:
     - Home (from README.md)
     - API-Reference (from API_REFERENCE.md)
     - Testing-Guide (from TESTING_GUIDE.md)
     - Examples (generated)
     - Contributing (generated)
     - _Sidebar (navigation menu)
     - _Footer (footer links)

### What Gets Synced Automatically

The workflow triggers on pushes to:
- `API_REFERENCE.md`
- `README.md`
- `TESTING_GUIDE.md`
- Any files in `docs/**`

### Customizing the Sync

Edit `.github/workflows/sync-wiki.yml` to:
- Add more pages
- Change the navigation structure
- Customize the sidebar
- Add custom processing

## Approach 2: Manual Wiki Management

If you prefer manual control:

### 1. Clone the Wiki Repository

```bash
# Clone the wiki repository
git clone https://github.com/YOUR_USERNAME/UnityKit.wiki.git

# Copy documentation files
cp API_REFERENCE.md UnityKit.wiki/API-Reference.md
cp README.md UnityKit.wiki/Home.md
cp Tests/TESTING_GUIDE.md UnityKit.wiki/Testing-Guide.md

# Commit and push
cd UnityKit.wiki
git add .
git commit -m "Add documentation"
git push
```

### 2. Create Navigation

Create `_Sidebar.md` in the Wiki repository:

```markdown
## UnityKit Documentation

### Getting Started
- [Home](Home)
- [Installation](Home#installation)
- [Quick Start](Home#quick-start)

### API Documentation
- [API Reference](API-Reference)
- [Component System](API-Reference#component-system)
- [Physics System](API-Reference#physics-system)

### Development
- [Testing Guide](Testing-Guide)
- [Contributing](Contributing)
```

### 3. Add Footer

Create `_Footer.md`:

```markdown
---
**UnityKit** | [GitHub](https://github.com/YOUR_USERNAME/UnityKit) | [Issues](https://github.com/YOUR_USERNAME/UnityKit/issues)
```

## Approach 3: Link to Repository Documentation

Instead of duplicating content, create a Wiki landing page that links to docs in the repository:

**Home.md**:
```markdown
# UnityKit Documentation

Welcome to UnityKit! This wiki provides links to comprehensive documentation.

## 📚 Documentation

- **[API Reference](https://github.com/YOUR_USERNAME/UnityKit/blob/master/API_REFERENCE.md)** - Complete API documentation
- **[README](https://github.com/YOUR_USERNAME/UnityKit/blob/master/README.md)** - Getting started guide
- **[Testing Guide](https://github.com/YOUR_USERNAME/UnityKit/blob/master/Tests/TESTING_GUIDE.md)** - Testing patterns and coverage

## 🚀 Quick Links

- [Installation](#installation)
- [Quick Start Examples](#quick-start)
- [GitHub Repository](https://github.com/YOUR_USERNAME/UnityKit)
- [Issue Tracker](https://github.com/YOUR_USERNAME/UnityKit/issues)

## Installation

\`\`\`swift
// Add to Package.swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/UnityKit.git", from: "1.1.0")
]
\`\`\`

## Quick Start

[See full examples in API Reference](https://github.com/YOUR_USERNAME/UnityKit/blob/master/API_REFERENCE.md#quick-reference)
```

## Approach 4: DocC + GitHub Pages

For a more advanced documentation site:

### 1. Build DocC Documentation

```bash
# Build documentation with DocC
swift package generate-documentation \
    --target UnityKit \
    --output-path ./docs/docc
```

### 2. Deploy to GitHub Pages

Create `.github/workflows/deploy-docs.yml`:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [master, main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build-docs:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Documentation
        run: |
          swift package generate-documentation \
            --target UnityKit \
            --output-path ./docs-output \
            --hosting-base-path UnityKit

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: ./docs-output

  deploy:
    needs: build-docs
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

### 3. Enable GitHub Pages

- Go to Settings → Pages
- Source: GitHub Actions
- Save

Your documentation will be available at: `https://YOUR_USERNAME.github.io/UnityKit/`

## Comparison

| Approach | Pros | Cons |
|----------|------|------|
| **Automated Sync** | Always up-to-date, searchable, GitHub native | Requires setup, limited styling |
| **Manual Wiki** | Full control, simple | Must update manually |
| **Link to Repo** | No duplication, single source of truth | Less discoverable, no wiki features |
| **DocC + Pages** | Beautiful, interactive, searchable | Complex setup, macOS build required |

## Recommended Workflow

For UnityKit, we recommend **Approach 1 (Automated Sync)**:

1. Write documentation in markdown files in the repository
2. Use DocC markup in Swift source files
3. GitHub Actions automatically syncs to Wiki
4. Optionally add DocC generation for interactive docs

This provides:
- ✅ Single source of truth (repository)
- ✅ Automatic updates
- ✅ Searchable Wiki
- ✅ In-code documentation (Xcode Quick Help)
- ✅ Optional interactive documentation site

## Next Steps

1. Enable the Wiki in your repository settings
2. Run the sync workflow
3. Customize the sidebar and pages
4. (Optional) Set up DocC for interactive documentation

## Troubleshooting

**Wiki sync fails:**
- Ensure Wiki is enabled and initialized
- Check repository permissions
- Verify workflow file is in `.github/workflows/`

**Sidebar doesn't appear:**
- File must be named `_Sidebar.md` exactly
- Must be in the root of the Wiki repository
- Try pushing directly to Wiki repo first

**Links broken:**
- Wiki page names use dashes: `API-Reference.md` → `[API Reference](API-Reference)`
- Internal anchors use lowercase: `#component-system`
- Cross-repo links need full URLs

## Resources

- [GitHub Wiki Documentation](https://docs.github.com/en/communities/documenting-your-project-with-wikis)
- [DocC Documentation](https://www.swift.org/documentation/docc/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
