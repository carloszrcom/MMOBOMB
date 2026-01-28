//
//  AppError.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 25/01/26.
//

import Foundation

/// Errores estructurados de la aplicación
/// Proporciona mensajes localizados y sugerencias de recuperación para el usuario
enum AppError: LocalizedError {
    
    // MARK: - Casos de Error
    
    /// Error relacionado con operaciones de red
    case network(NetworkError)
    
    /// Error en operaciones de base de datos
    case database(String)
    
    /// Contenido no encontrado (404)
    case notFound
    
    /// Caché expirado o inválido
    case cacheExpired
    
    /// Datos recibidos inválidos o corruptos
    case invalidData
    
    /// Error desconocido
    case unknown(Error)
    
    // MARK: - LocalizedError Protocol
    
    /// Descripción legible del error para mostrar al usuario
    var errorDescription: String? {
        switch self {
        case .network(let networkError):
            return "Error de conexión: \(networkError.localizedDescription)"
            
        case .database(let detail):
            return "Error en la base de datos: \(detail)"
            
        case .notFound:
            return "Contenido no encontrado"
            
        case .cacheExpired:
            return "Los datos están desactualizados"
            
        case .invalidData:
            return "Los datos recibidos no son válidos"
            
        case .unknown(let error):
            return "Error inesperado: \(error.localizedDescription)"
        }
    }
    
    /// Sugerencia de recuperación para el usuario
    var recoverySuggestion: String? {
        switch self {
        case .network:
            return "Verifica tu conexión a internet e inténtalo de nuevo"
            
        case .cacheExpired:
            return "Desliza hacia abajo para actualizar los datos"
            
        case .notFound:
            return "El contenido solicitado no está disponible"
            
        case .database:
            return "Intenta reiniciar la aplicación"
            
        case .invalidData:
            return "Por favor, reporta este problema al equipo de desarrollo"
            
        case .unknown:
            return "Intenta cerrar y volver a abrir la aplicación"
        }
    }
    
    // MARK: - Helper Methods
    
    /// Convierte un Error genérico a AppError
    /// - Parameter error: Error a convertir
    /// - Returns: AppError apropiado según el tipo de error
    static func from(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(networkError)
        } else if let appError = error as? AppError {
            return appError
        } else {
            return .unknown(error)
        }
    }
}
