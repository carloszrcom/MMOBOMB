//
//  GameListView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI
import SwiftData

/// Vista principal que muestra el listado de juegos
/// Incluye búsqueda, pull-to-refresh y navegación a detalles
struct GamesListView: View {
    
    // MARK: - Environment
    
    /// Contexto de SwiftData para pasarlo al repositorio
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    /// Store que gestiona el estado del listado
    /// Se inicializa con el repositorio que tiene acceso a SwiftData
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
            // Inicializamos el store con el contexto de SwiftData
            // Esto solo ocurre una vez cuando la vista aparece
            if store == nil {
                let repository = GameRepositoryImpl(modelContext: modelContext)
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
                GameDetailView(gameId: gameId)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GamesListView()
        .modelContainer(for: [GameEntity.self, GameDetailEntity.self])
}
