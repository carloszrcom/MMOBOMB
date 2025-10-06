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
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    // Sección para la imagen sticky
                    Section {
                        // Contenido principal con márgenes laterales
                        VStack(spacing: 0) {
                            // Información del juego
                            GameInfoView(gameDetail: gameDetail)
                                .padding(.horizontal)
                            
                            // Screenshots si existen
                            if !gameDetail.screenshots.isEmpty {
                                ScreenshotsView(screenshots: gameDetail.screenshots)
                                    .padding(.vertical)
                                    .padding(.horizontal)
                            }
                            
                            // Requisitos del sistema si existen
                            if let requirements = gameDetail.minimumSystemRequirements {
                                RequirementsView(requirements: requirements)
                                    .padding(.horizontal)
                            }
                            
                            // Espaciado final
                            Spacer(minLength: 20)
                        }
                        .background(Color(.systemBackground))
                    } header: {
                        // Header sticky con imagen
                        stretchyHeaderView(
                            gameDetail: gameDetail,
                            geometry: geometry
                        )
                    }
                }
            }
            .coordinateSpace(name: "scroll")
        }
        .ignoresSafeArea(edges: .top)
        .refreshable {
            // Pull to refresh
            await store.refresh(id: gameId)
        }
    }
    
    
    // MARK: - Stretchy Header
    
    @ViewBuilder
    private func stretchyHeaderView(gameDetail: GameDetail, geometry: GeometryProxy) -> some View {
        GeometryReader { headerGeometry in
            let minY = headerGeometry.frame(in: .named("scroll")).minY
            let baseHeight: CGFloat = 250
            
            // Calculamos la altura ajustada para el efecto stretchy
            let (adjustedHeight, yOffset): (CGFloat, CGFloat) = {
                if minY > 0 {
                    // Si arrastramos hacia abajo (minY positivo), estiramos la imagen
                    return (baseHeight + minY, -minY)
                } else {
                    // Si hacemos scroll hacia arriba (minY negativo), mantenemos altura base
                    return (baseHeight, 0)
                }
            }()
            
            ZStack(alignment: .bottomLeading) {
                // Imagen de fondo con efecto stretchy
                AsyncImageView(url: gameDetail.thumbnail, placeholderSize: 80)
                    .aspectRatio(contentMode: .fill) // Importante: fill para que se estire correctamente
                    .frame(
                        width: geometry.size.width,
                        height: adjustedHeight
                    )
                    .clipped()
                    .offset(y: yOffset)
                
                // Gradiente para mejorar la legibilidad del título
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geometry.size.width, height: adjustedHeight)
                .offset(y: yOffset)
                
                // Título del juego sobre el gradiente
                Text(gameDetail.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: min(yOffset, 0)) // El título se mantiene visible
            }
        }
        .frame(height: 250)
    }
}

// MARK: - Preview

#Preview {
    let container = PersistenceManager.preview
    let repository = GameRepositoryImpl(modelContext: container.mainContext)
    
    return NavigationStack {
        GameDetailView(gameId: 452)
            .environment(repository)
    }
}
