//
//  GameListView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI
import SwiftData
import OSLog

/// Main view showing the list of games
/// Includes search, pull-to-refresh, and navigation to details
/// MEJORA: Usa store COMPARTIDO del Environment para preservar estado entre navegaciones
struct GamesListView: View {
    
    // MARK: - Environment
    
    /// Store COMPARTIDO inyectado desde el App
    /// MEJORA: Preserva scroll position, búsqueda y datos entre navegaciones
    @Environment(\.gamesListStore) private var store
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if let store = store {
                    contentView(store: store)
                } else {
                    // Mientras se inicializa el store compartido en App
                    LoadingView(message: "Inicializando...")
                }
            }
            .navigationTitle("Juegos")
            .navigationBarTitleDisplayMode(.large)
        }
        // Ya no necesitamos .task para crear el store
        // El store se crea e inicializa en MMOBOMBSwift6App
    }
    
    // MARK: - Content View
    
    /// Vista de contenido que depende del estado del store
    @ViewBuilder
    private func contentView(store: GamesListStore) -> some View {
        ZStack {
            // Lista de juegos
            gamesList(store: store)
            
            // Overlay de carga cuando se está refrescando
            if store.isLoading && !store.games.isEmpty {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                
                LoadingView()
            }
        }
        .searchable(
            text: Binding(
                get: { store.searchText },
                set: { store.searchText = $0 }
            ),
            prompt: "Buscar juegos..."
        )
        .alert("Error", isPresented: Binding(
            get: { store.hasError },
            set: { if !$0 { store.clearError() } }
        )) {
            Button("Aceptar", role: .cancel) {
                store.clearError()
            }
            Button("Reintentar") {
                Task {
                    await store.loadGames(forceRefresh: true)
                }
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
            if let recovery = store.recoverySuggestion {
                Text(recovery)
            }
        }
    }
    
    // MARK: - Games List
    
    /// Lista de juegos con diferentes estados
    @ViewBuilder
    private func gamesList(store: GamesListStore) -> some View {
        if store.isLoading && store.games.isEmpty {
            // Primera carga
            LoadingView(message: "Cargando juegos...")
            
        } else if store.games.isEmpty && !store.isLoading {
            // No hay juegos disponibles
            EmptyStateView()
            
        } else {
            // Lista de juegos
            List(store.filteredGames) { game in
                NavigationLink(value: game.id) {
                    GameRowView(game: game)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .refreshable {
                // Pull to refresh
                await store.refresh()
            }
            .navigationDestination(for: Int.self) { gameId in
                // Navegación a la vista de detalles
                // GameDetailView creará su PROPIO store local
                GameDetailView(gameId: gameId)
            }
        }
    }
}

// MARK: - Preview

//#Preview {
//    @Previewable @State var container = PersistenceManager.preview
//    @Previewable @State var repository: GameRepositoryProtocol = GameRepositoryImpl(
//        modelContext: container.mainContext
//    )
//    
//    GamesListView()
//        .modelContainer(container)
//        .gameRepository(repository)
//}

