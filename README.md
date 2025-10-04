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
