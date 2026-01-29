//
//  MMOBOMBSwift6App.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI
import SwiftData
import OSLog

/// Punto de entrada principal de la aplicación
/// Configura SwiftData, el repositorio compartido y stores globales usando arquitectura MV-R
@main
struct MMOBOMBSwift6App: App {
    
    // MARK: - Properties
    
    /// Contenedor de SwiftData para la persistencia
    let modelContainer: ModelContainer
    
    /// Repositorio compartido inyectado globalmente via Environment
    /// IMPORTANTE: Usamos el PROTOCOLO (no la implementación concreta)
    /// Esto permite inyectar mocks en tests y cumple con SOLID
    private let gameRepository: GameRepositoryProtocol
    
    /// Store compartido para la lista de juegos (NUEVO)
    /// Preserva estado entre navegaciones (scroll, búsqueda, datos cargados)
    /// Se inicializa una vez y vive durante toda la sesión de la app
    @State private var gamesListStore: GamesListStore?
    
    // MARK: - Initialization
    
    init() {
        Logger.ui.info("Initializing MMOBOMBSwift6 App")
        
        do {
            // Configuramos el contenedor con todos los modelos que queremos persistir
            modelContainer = try ModelContainer(
                for: GameEntity.self,
                     GameDetailEntity.self
            )
            
            // Creamos la implementación concreta del repositorio
            let repositoryImpl = GameRepositoryImpl(modelContext: modelContainer.mainContext)
            
            // Asignamos al protocolo para inyección de dependencias
            gameRepository = repositoryImpl
            
            Logger.ui.info("App initialized successfully")
            
        } catch {
            // Si falla la configuración, terminamos la app
            Logger.ui.fault("SwiftData could not be configured: \(error.localizedDescription)")
            fatalError(">> Error. SwiftData could not be configured: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            // Inyectamos el repositorio como PROTOCOLO usando el modificador personalizado
            // Todas las vistas hijas podrán acceder a él con @Environment(\.gameRepository)
            MMOBOMBTabView()
                .modelContainer(modelContainer)
                .gameRepository(gameRepository)
                .environment(\.gamesListStore, gamesListStore)  // NUEVO: Store compartido
                .task {
                    // Inicializamos el store compartido una sola vez
                    if gamesListStore == nil {
                        Logger.ui.info("Initializing shared GamesListStore")
                        let store = GamesListStore(repository: gameRepository)
                        gamesListStore = store
                        
                        // Cargamos los juegos inicialmente
                        await store.loadGames()
                    }
                }
                .onAppear {
                    Logger.ui.info("Main view appeared")
                }
        }
    }
}
