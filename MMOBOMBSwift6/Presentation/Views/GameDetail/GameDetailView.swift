//
//  GameDetailView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI
import SwiftData

/// Vista de detalles completos de un juego
/// Muestra toda la información disponible incluyendo screenshots y requisitos
/// Usa arquitectura MV-R: obtiene el Repository del Environment y crea su Store local
struct GameDetailView: View {
    
    // MARK: - Environment
    
    /// Repositorio concreto inyectado globalmente desde el App
    @Environment(GameRepositoryImpl.self) private var repository
    
    // MARK: - Properties
    
    /// ID del juego a mostrar
    let gameId: Int
    
    // MARK: - State
    
    /// Store LOCAL de esta vista
    /// Se crea cuando la vista aparece y se destruye cuando desaparece
    @State private var store: GameDetailStore?
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let store = store {
                contentView(store: store)
            } else {
                LoadingView(message: "Inicializando...")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Inicializamos el store LOCAL si no existe
            if store == nil {
                // Creamos el store local inyectándole el repositorio compartido
                let newStore = GameDetailStore(repository: repository)
                store = newStore
                
                // Cargamos los detalles del juego
                await newStore.loadGameDetail(id: gameId)
            }
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private func contentView(store: GameDetailStore) -> some View {
        if store.isLoading {
            // Mostramos loading mientras carga
            LoadingView(message: "Cargando detalles...")
            
        } else if let error = store.errorMessage {
            // Mostramos error si falla la carga
            ErrorView(message: error) {
                Task {
                    await store.refresh(id: gameId)
                }
            }
            
        } else if let gameDetail = store.gameDetail {
            // Mostramos los detalles del juego
            gameDetailContent(gameDetail, store: store)
            
        } else {
            // Estado inesperado
            ContentUnavailableView(
                "No disponible",
                systemImage: "exclamationmark.triangle",
                description: Text("No se pudieron cargar los detalles del juego")
            )
        }
    }
    
    // MARK: - Game Detail Content
    
    @ViewBuilder
    private func gameDetailContent(_ gameDetail: GameDetail, store: GameDetailStore) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Cabecera con imagen principal
                GameHeaderView(
                    thumbnailUrl: gameDetail.thumbnail,
                    title: gameDetail.title
                )
                
                // Información del juego
                GameInfoView(gameDetail: gameDetail)
                
                // Screenshots si existen
                if !gameDetail.screenshots.isEmpty {
                    ScreenshotsView(screenshots: gameDetail.screenshots)
                        .padding(.vertical)
                }
                
                // Requisitos del sistema si existen
                if let requirements = gameDetail.minimumSystemRequirements {
                    RequirementsView(requirements: requirements)
                }
                
                // Espaciado final
                Spacer(minLength: 20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .refreshable {
            // Pull to refresh
            await store.refresh(id: gameId)
        }
    }
}

//// MARK: - Preview
//
//#Preview {
//    let container = PersistenceManager.preview
//    let repository = GameRepositoryImpl(modelContext: container.mainContext)
//    
//    return NavigationStack {
//        GameDetailView(gameId: 452)
//            .environment(repository)
//    }
//}
