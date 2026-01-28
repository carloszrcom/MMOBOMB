//
//  Logger+Extensions.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 25/01/26.
//

import OSLog

/// Extensión centralizada de loggers para toda la aplicación
/// Proporciona categorías específicas para diferentes áreas del código
extension Logger {
    
    /// Identificador del subsistema de la app
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.app.mmobomb"
    
    // MARK: - Loggers por Categoría
    
    /// Logger para operaciones de red (peticiones HTTP, respuestas, errores de conectividad)
    static let network = Logger(subsystem: subsystem, category: "network")
    
    /// Logger para operaciones de base de datos (SwiftData, cache, persistencia)
    static let database = Logger(subsystem: subsystem, category: "database")
    
    /// Logger para eventos de UI (navegación, ciclo de vida de vistas, interacciones)
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Logger para lógica de negocio (Stores, transformaciones de datos)
    static let store = Logger(subsystem: subsystem, category: "store")
}
