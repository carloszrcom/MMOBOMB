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
/// Configura SwiftData y el repositorio compartido usando arquitectura MV-R
@main
struct MMOBOMBSwift6App: App {
    
    // MARK: - Properties
    
    /// Contenedor de SwiftData para la persistencia
    let modelContainer: ModelContainer
    
    /// Repositorio compartido inyectado globalmente via Environment
    /// IMPORTANTE: Usamos el PROTOCOLO (no la implementación concreta)
    /// Esto permite inyectar mocks en tests y cumple con SOLID
    private let gameRepository: GameRepositoryProtocol
    
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
                .onAppear {
                    Logger.ui.info("Main view appeared")
                }
        }
    }
}
