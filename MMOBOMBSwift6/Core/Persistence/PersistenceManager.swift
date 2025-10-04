//
//  PersistenceManager.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData

/// Gestor centralizado de persistencia con SwiftData
/// Proporciona configuración y acceso al contenedor de modelos
enum PersistenceManager {
    
    // MARK: - Shared Container
    
    /// Contenedor compartido de SwiftData para toda la aplicación
    /// Se utiliza principalmente para previews y tests
    static var shared: ModelContainer = {
        do {
            // Configuramos el esquema con todos los modelos
            let schema = Schema([
                GameEntity.self,
                GameDetailEntity.self
            ])
            
            // Configuración del contenedor
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false // Persistencia en disco
            )
            
            // Creamos el contenedor con la configuración
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            return container
            
        } catch {
            // Si falla la configuración, terminamos la app
            // En producción esto no debería ocurrir nunca
            fatalError("No se pudo crear el ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    // MARK: - Preview Container
    
    /// Contenedor temporal para previews de SwiftUI
    /// Usa almacenamiento en memoria para no afectar la base de datos real
    static var preview: ModelContainer = {
        do {
            let schema = Schema([
                GameEntity.self,
                GameDetailEntity.self
            ])
            
            // Configuración para almacenamiento en memoria (solo para previews)
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            // Insertamos datos de prueba para los previews
            insertSampleData(in: container)
            
            return container
            
        } catch {
            fatalError("No se pudo crear el preview container: \(error.localizedDescription)")
        }
    }()
    
    // MARK: - Test Container
    
    /// Contenedor para tests unitarios
    /// Usa almacenamiento en memoria y no afecta la base de datos de producción
    static func createTestContainer() throws -> ModelContainer {
        let schema = Schema([
            GameEntity.self,
            GameDetailEntity.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
    
    // MARK: - Sample Data
    
    /// Inserta datos de ejemplo en el contenedor
    /// Útil para previews y desarrollo
    private static func insertSampleData(in container: ModelContainer) {
        let context = container.mainContext
        
        // Creamos un juego de ejemplo
        let sampleGame = GameEntity(
            id: 452,
            title: "Call of Duty: Warzone",
            thumbnail: "https://www.mmobomb.com/g/452/thumbnail.jpg",
            shortDescription: "One of the most popular FPSes in the world is now a free-to-play battle royale.",
            gameUrl: "https://www.mmobomb.com/open/call-of-duty-warzone",
            genre: "Shooter",
            platform: "Windows",
            publisher: "Activision",
            developer: "Infinity Ward",
            releaseDate: Date(),
            profileUrl: "https://www.mmobomb.com/call-of-duty-warzone"
        )
        
        // Insertamos el juego de ejemplo
        context.insert(sampleGame)
        
        // Creamos un detalle de ejemplo
        let sampleDetail = GameDetailEntity(
            id: 452,
            title: "Call of Duty: Warzone",
            thumbnail: "https://www.mmobomb.com/g/452/thumbnail.jpg",
            status: "Live",
            shortDescription: "One of the most popular FPSes in the world is now a free-to-play battle royale.",
            gameDescription: "One of the most popular FPSes in the world is now a free-to-play battle royale: Call of Duty: Warzone. Strive to become the last squad standing in Battle Royale mode.",
            gameUrl: "https://www.mmobomb.com/open/call-of-duty-warzone",
            genre: "Shooter",
            platform: "Windows",
            publisher: "Activision",
            developer: "Infinity Ward",
            releaseDate: Date(),
            profileUrl: "https://www.mmobomb.com/call-of-duty-warzone",
            requirementsOS: "Windows 10 64-Bit",
            requirementsProcessor: "Intel Core i3-4340 or AMD FX-6300",
            requirementsMemory: "8GB RAM",
            requirementsGraphics: "NVIDIA GeForce GTX 670",
            requirementsStorage: "175GB HD space",
            screenshotsJSON: """
            [
                {"id": 1124, "imageUrl": "https://www.mmobomb.com/g/452/Call-of-Duty-Warzone-1.jpg"},
                {"id": 1125, "imageUrl": "https://www.mmobomb.com/g/452/Call-of-Duty-Warzone-2.jpg"}
            ]
            """
        )
        
        // Insertamos el detalle de ejemplo
        context.insert(sampleDetail)
        
        // Guardamos los cambios
        do {
            try context.save()
        } catch {
            print("❌ Error guardando datos de ejemplo: \(error)")
        }
    }
}
