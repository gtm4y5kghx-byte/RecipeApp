# RecipeApp

A personal recipe collection app that preserves family cooking traditions and captures your original recipes.

## Vision

**"Every recipe, captured your way"**

RecipeApp provides three equal methods to capture recipes the way they actually exist in real life:

- **Voice Capture**: Record recipes while cooking or preserve oral family traditions
- **Photo Capture**: Digitize handwritten recipe cards and cookbook pages
- **Web Parsing**: Save recipes from any website with AI-powered extraction

AI enhances vague or incomplete recipes while preserving the original source, making family recipes usable for generations to come.

## Tech Stack

- **Platform**: iOS 17+ native
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Backend**: Supabase (planned)
- **AI**: Claude API (planned)
- **Voice**: iOS Speech Framework (planned)
- **OCR**: iOS Vision Framework (planned)

## Current Status

**Phase 1: Core Foundation** (In Progress)
- Setting up project structure
- Building basic recipe data models
- Creating list and detail views

See [Project Plan](../Project%20Plan.md) for detailed development roadmap.

## Getting Started

### Requirements
- Xcode 16+
- iOS 17+ deployment target
- macOS for development

### Running the Project
1. Clone this repository
2. Open `RecipeApp.xcodeproj` in Xcode
3. Select a simulator or device
4. Press `Cmd + R` to build and run

## Project Structure

```
RecipeApp/
├── Models/          # SwiftData models (Recipe, Ingredient, Step)
├── Views/           # SwiftUI views and components
├── Services/        # Business logic (API clients, parsers)
├── Assets.xcassets  # Images, colors, app icon
└── RecipeAppApp.swift  # App entry point
```

## Core Principles

1. **Preservation first** - Capture recipes before they're lost
2. **Creation matters** - Your original recipes deserve to be remembered
3. **Enhancement without replacement** - AI improves recipes but keeps originals sacred
4. **Universal capture** - Every input method is first-class
5. **In-the-moment utility** - Capture while cooking, not after the fact
6. **Original artifacts are sacred** - Never lose the source

## Development Philosophy

This is a solo indie project focused on:
- Quality over features
- Sustainable scope for one developer
- Meaningful utility over growth metrics
- Fair pricing and genuine value

## License

TBD

## Contact

TBD
