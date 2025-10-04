# MMOBOMB iOS App - Educational Project

<img width="400" height="600" alt="swiftui-architecture" src="https://github.com/user-attachments/assets/f238375b-b683-4b7b-88c2-36f2da49b099" />

A modern iOS application built with SwiftUI and Swift 6, showcasing best practices for iOS development. This project demonstrates a scalable architecture for building production-ready apps while serving as an educational resource for iOS developers.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Requirements](#requirements)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Learning Resources](#learning-resources)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This educational project demonstrates how to build a complete iOS application that fetches and displays a list of free-to-play games from the [MMOBomb API](https://www.mmobomb.com/api). The app showcases modern iOS development practices including:

- SwiftUI declarative UI framework
- Swift 6 concurrency with async/await
- SwiftData for local persistence
- Clean architecture principles
- Separation of concerns (DTOs, Models, Entities)
- MVVM-like pattern with Stores
- RESTful API integration

**⚠️ Note:** This architecture is subject to change as the project evolves and incorporates new learning concepts and best practices.

## ✨ Features

- 📱 **Game List**: Browse a comprehensive list of free-to-play games
- 🔍 **Search**: Real-time search by title, genre, platform, or developer
- 📖 **Game Details**: View detailed information including:
  - Game description
  - Screenshots gallery
  - System requirements
  - Publisher and developer info
  - Release date
- 💾 **Offline Mode**: Local caching with SwiftData (24-hour expiration)
- ↻ **Pull to Refresh**: Update data from the API
- 🎨 **Modern UI**: Clean, native iOS design following Apple's HIG
- ⚡ **Performance**: Efficient image loading and data management

## 🏗️ Architecture

The project follows a **layered architecture** pattern with clear separation of concerns:

┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (Views, Stores, Components)      │
├─────────────────────────────────────┤
│          Domain Layer               │
│      (Models, Entities)             │
├─────────────────────────────────────┤
│           Data Layer                │
│  (DTOs, Mappers, Repositories)      │
├─────────────────────────────────────┤
│           Core Layer                │
│  (Network, Persistence, Utils)      │
└─────────────────────────────────────┘

### Current Architecture Pattern: MV with Stores

The app uses a **Model-View pattern with Stores** (similar to MVVM but leveraging SwiftUI's native capabilities):

- **Models**: Immutable structs representing business logic
- **Views**: SwiftUI views that render the UI
- **Stores**: `@Observable` objects managing state and presentation logic
- **Repositories**: Handle data fetching from API and local cache

**Why this pattern?**
- SwiftUI's declarative nature reduces the need for traditional ViewModels
- `@Observable` macro (Swift 6) provides automatic change tracking
- Stores are easily testable and maintainable
- Scalable for growing applications

> **Note:** As the project evolves, the architecture may transition to other patterns (e.g., The Composable Architecture, Redux-like, etc.) for educational purposes.

## 🛠️ Technologies

- **Language**: Swift 6.2
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: 18.0
- **Persistence**: SwiftData
- **Networking**: URLSession with async/await
- **Concurrency**: Swift Concurrency (async/await, actors, @MainActor)
- **Architecture**: MV with Stores (subject to change)

## 📱 Requirements

- Xcode 16.0 or later
- iOS 18.0 or later
- macOS Sequoia 15.0 or later (for development)
- Swift 6.2

## 📂 Project Structure (Initially)

GameListApp/
│
├── App/
│   ├── GameListApp.swift              # App entry point
│   └── AppConfiguration.swift         # Global configuration
│
├── Core/
│   ├── Network/
│   │   ├── NetworkManager.swift       # HTTP client
│   │   ├── APIEndpoint.swift          # API endpoints
│   │   └── NetworkError.swift         # Custom errors
│   │
│   ├── Persistence/
│   │   └── PersistenceManager.swift   # SwiftData setup
│   │
│   └── Extensions/
│       ├── String+Extensions.swift
│       └── Date+Extensions.swift
│
├── Domain/
│   ├── Entities/                      # SwiftData models
│   │   ├── GameEntity.swift
│   │   └── GameDetailEntity.swift
│   │
│   └── Models/                        # Business logic models
│       ├── Game.swift
│       ├── GameDetail.swift
│       ├── SystemRequirements.swift
│       └── Screenshot.swift
│
├── Data/
│   ├── DTOs/                          # API response models
│   │   ├── GameDTO.swift
│   │   ├── GameDetailDTO.swift
│   │   ├── SystemRequirementsDTO.swift
│   │   └── ScreenshotDTO.swift
│   │
│   ├── Mappers/                       # Data transformers
│   │   ├── GameMapper.swift
│   │   └── GameDetailMapper.swift
│   │
│   └── Repositories/                  # Data access layer
│       ├── GameRepository.swift
│       └── GameRepositoryImpl.swift
│
└── Presentation/
    ├── Stores/                        # State management
    │   ├── GamesListStore.swift
    │   └── GameDetailStore.swift
    │
    └── Views/
        ├── GamesList/
        │   ├── GamesListView.swift
        │   ├── GameRowView.swift
        │   └── EmptyStateView.swift
        │
        ├── GameDetail/
        │   ├── GameDetailView.swift
        │   ├── GameHeaderView.swift
        │   ├── GameInfoView.swift
        │   ├── ScreenshotsView.swift
        │   └── RequirementsView.swift
        │
        └── Components/
            ├── AsyncImageView.swift
            ├── LoadingView.swift
            └── ErrorView.swift


## 📚 Learning Resources
This project demonstrates the following iOS development concepts:
SwiftUI Fundamentals

Declarative UI with SwiftUI
State management (@State, @Environment, @Observable)
Navigation with NavigationStack
Lists and custom rows
Async image loading
Pull-to-refresh
Search functionality

## Swift 6 Concurrency

async/await for asynchronous operations
Task and task groups
@MainActor for UI updates
Actor isolation and thread safety
Structured concurrency

## Data Management

SwiftData for persistence
@Model macro for entities
FetchDescriptor and Predicate
Repository pattern
DTO to Model mapping
Cache expiration strategies

## Networking

URLSession with modern Swift
Codable for JSON parsing
Custom error handling
API endpoint management

## Architecture Patterns

Separation of concerns
Dependency injection
Protocol-oriented programming
Unidirectional data flow

## Contribution Guidelines

Follow Apple's Swift API Design Guidelines
Add comments explaining complex logic
Keep commits atomic and well-described
Update documentation as needed

📄 License
This project is licensed under the Educational Use License.
You are free to:

✅ Download and study the code
✅ Use it for learning iOS development
✅ Fork and modify for educational purposes
✅ Share with other learners

## Conditions:

📚 This project is for educational purposes only
🚫 Not for commercial use
📝 Maintain attribution to the original project
🤝 Share knowledge with the community

## Copyright (c) 2025 Carlos ZR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to use
the Software for educational and learning purposes only, including without
limitation the rights to use, copy, modify, merge, publish, and distribute
copies of the Software, subject to the following conditions:

1. The Software shall not be used for commercial purposes.
2. The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.
3. Any modifications or derivatives must maintain the educational nature and
   attribution to the original work.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## 🙏 Acknowledgments

MMOBomb API for providing the free-to-play games data
Apple's SwiftUI and Swift documentation
The iOS development community

## 📧 Contact
For questions, suggestions, or educational discussions:

Create an issue in this repository
Reach out via iosdeveloperhp@gmail.com

## Happy Learning! 🚀
Made with ❤️ for iOS learners worldwide
