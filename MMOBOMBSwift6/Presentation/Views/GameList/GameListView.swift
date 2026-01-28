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
/// Uses MV-R architecture: obtains the Repository from the Environment and creates its local Store
struct GamesListView: View {
    
    // MARK: - Environment
    
    /// Repositorio PROTOCOLO inyectado globalmente desde el App
    /// MEJORA: Usamos el protocolo en lugar de la implementación concreta
    @Environment(\.gameRepository) private var repository
    
    // MARK: - State
    
    /// Store LOCAL de esta vista
    /// Se crea cuando la vista aparece y se destruye cuando desaparece
    @State private var store: GamesListStore?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if let store = store {
                    contentView(store: store)
                } else {
                    // Mientras se inicializa el store
                    LoadingView(message: "Inicializando...")
                }
            }
            .navigationTitle("Juegos")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            // Inicializamos el store LOCAL con el repositorio del Environment
            // Esto solo ocurre una vez cuando la vista aparece
            if store == nil, let repository = repository {
                Logger.ui.info("Initializing GamesListView store")
                
                // Creamos el store local inyectándole el repositorio (protocolo)
                store = GamesListStore(repository: repository)
                
                // Cargamos los juegos inicialmente
                await store?.loadGames()
            }
        }
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

