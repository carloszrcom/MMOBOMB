//
//  MMOBOMBSwift6App.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI
import SwiftData

/// Punto de entrada principal de la aplicación
/// Configura SwiftData y el contenedor de la app
@main
struct MMOBOMBSwift6App: App {
    
    // MARK: - Properties
    
    /// Contenedor de SwiftData para la persistencia
    /// Se configura con los modelos que vamos a persistir
    let modelContainer: ModelContainer
    
    // MARK: - Initialization
    
    init() {
        do {
            // Configuramos el contenedor con todos los modelos que queremos persistir
            // SwiftData creará automáticamente el esquema de base de datos
            modelContainer = try ModelContainer(
                for: GameEntity.self,
                     GameDetailEntity.self
            )
        } catch {
            // Si falla la configuración, terminamos la app
            // En producción esto no debería ocurrir
            fatalError("No se pudo configurar SwiftData: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            // Inyectamos el contenedor de SwiftData en toda la jerarquía de vistas
            // Esto permite acceder al contexto desde cualquier vista
            GamesListView()
                .modelContainer(modelContainer)
        }
    }
}
