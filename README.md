# Recipe App

A native iOS app built with SwiftUI as a hands-on exploration of Apple's modern declarative UI framework. Manages recipes, meal planning, and shopping lists with AI-powered features via the Claude API.

## Tech Stack

- SwiftUI, Swift
- SwiftData (local persistence)
- Claude API (recipe suggestions, generation, meal planning)
- BGTaskScheduler (background processing)
- XCTest (unit and UI tests)

## Features

- Recipe CRUD with rich content (ingredients, steps, notes)
- AI-powered recipe suggestions and generation
- Weekly meal plan generation with calendar interface
- Shopping list
- Full-screen cooking mode with step-by-step navigation
- Share Sheet extension for importing recipes from the web
- Adaptive layouts for iPhone and iPad (TabView / NavigationSplitView)
- Atomic design system with reusable component library

## Architecture

- Strict MVVM with @Observable macro for reactive state
- Three-layer separation: Views (presentation only), ViewModels (business logic), Services (data/API)
- Dependency injection via SwiftUI @Environment
- TDD throughout
