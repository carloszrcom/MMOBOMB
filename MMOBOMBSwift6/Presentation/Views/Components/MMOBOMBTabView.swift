//
//  MMOBOMBTabView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 22/10/25.
//

import SwiftUI

enum TabSelection: String, CaseIterable {
    case home = "home"
    case premium = "premium"
    case settings = "settings"
}

struct MMOBOMBTabView: View {
    // MARK: - Properties
    
    @State private var selectedTab: TabSelection = .home
    
    init() {
        // Configuramos la apariencia del TabBar antes de que se renderice la vista
        //        TabBarAppearance.configure()
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Inicio", systemImage: AppIcons.homeFill.name, value: TabSelection.home) {
                GamesListView()
            }
            // We explicitly apply the color tint to each Tab
            // This ensures that SwiftUI does not overwrite our custom colors
            .badge(selectedTab == .home ? nil : nil) // Workaround para forzar el redibujado
            
            Tab("Premium", systemImage: AppIcons.personFill.name, value: TabSelection.premium) {
                TestView()
            }
            .badge(selectedTab == .premium ? nil : nil)
            
            Tab("Ajustes", systemImage: AppIcons.gearShape.name, value: TabSelection.settings) {
                TestView()
            }
            .badge(selectedTab == .settings ? nil : nil)
        }
    }
}

// MARK: - Preview

#Preview {
    MMOBOMBTabView()
}

