//
//  NetworkError.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Errores personalizados para las operaciones de red
/// Proporciona información específica sobre qué salió mal
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknownError
    
    /// Descripción localizada del error para mostrar al usuario
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL proporcionada no es válida"
        case .noData:
            return "No se recibieron datos del servidor"
        case .decodingError:
            return "Error al procesar los datos recibidos"
        case .serverError(let statusCode):
            return "Error del servidor (código \(statusCode))"
        case .unknownError:
            return "Ocurrió un error desconocido"
        }
    }
}
