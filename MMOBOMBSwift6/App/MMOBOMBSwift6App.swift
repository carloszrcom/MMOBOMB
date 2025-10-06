//
//  MMOBOMBSwift6App.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI
import SwiftData

/// Punto de entrada principal de la aplicación
/// Configura SwiftData y el repositorio compartido usando arquitectura MV-R
@main
struct MMOBOMBSwift6App: App {
    
    // MARK: - Properties
    
    /// Contenedor de SwiftData para la persistencia
    let modelContainer: ModelContainer
    
    /// Repositorio compartido inyectado globalmente via Environment
    /// Usamos la clase concreta directamente (recomendación de Apple)
    private let gameRepository: GameRepositoryImpl
    
    // MARK: - Initialization
    
    init() {
        do {
            // Configuramos el contenedor con todos los modelos que queremos persistir
            modelContainer = try ModelContainer(
                for: GameEntity.self,
                     GameDetailEntity.self
            )
            
            // Creamos el repositorio UNA SOLA VEZ con el contexto de SwiftData
            // Este repositorio será compartido por toda la aplicación
            gameRepository = GameRepositoryImpl(modelContext: modelContainer.mainContext)
            
        } catch {
            // Si falla la configuración, terminamos la app
            fatalError("No se pudo configurar SwiftData: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            // Inyectamos el repositorio concreto en el environment
            // Todas las vistas hijas podrán acceder a él
            GamesListView()
                .modelContainer(modelContainer)
                .environment(gameRepository)
        }
    }
}
