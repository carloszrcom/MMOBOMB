//
//  NetworkManager.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Gestor centralizado de las peticiones de red
/// Usa async/await para operaciones asíncronas modernas
final class NetworkManager {
    
    // MARK: - Properties
    
    /// Instancia compartida (Singleton) para usar en toda la app
    static let shared = NetworkManager()
    
    /// URLSession configurada para las peticiones
    private let session: URLSession
    
    /// Decodificador JSON con estrategia de conversión de snake_case a camelCase
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    private init() {
        // Configuramos URLSession con timeouts apropiados
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        // Configuramos el decoder para convertir automáticamente snake_case a camelCase
        // La API devuelve campos como "short_description" y nosotros usamos "shortDescription"
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Configuración para fechas en formato ISO8601
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    /// Realiza una petición GET genérica que devuelve un tipo decodificable
    /// - Parameter endpoint: El endpoint al que hacer la petición
    /// - Returns: El objeto decodificado del tipo especificado
    /// - Throws: NetworkError si algo falla
    func fetch<T: Decodable>(from endpoint: APIEndpoint) async throws -> T {
        // Validamos que la URL sea válida
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        // Realizamos la petición de forma asíncrona
        let (data, response) = try await session.data(from: url)
        
        // Validamos que la respuesta HTTP sea exitosa (200-299)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Intentamos decodificar los datos en el tipo solicitado
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            // Si falla el decode, lanzamos un error específico
            print("❌ Error de decodificación: \(error)")
            throw NetworkError.decodingError
        }
    }
}














// - TODO: 😱 >>>  borrar????
/// Gestor centralizado de las peticiones de red
/// Usa async/await para operaciones asíncronas modernas
/// Actor para garantizar thread-safety en las operaciones de red
//actor NetworkManager {
//    
//    // MARK: - Properties
//    
//    /// Instancia compartida (Singleton) para usar en toda la app
//    static let shared = NetworkManager()
//    
//    /// URLSession configurada para las peticiones
//    private let session: URLSession
//    
//    /// Decodificador JSON con estrategia de conversión de snake_case a camelCase
//    private let decoder: JSONDecoder
//    
//    // MARK: - Initialization
//    
//    private init() {
//        // Configuramos URLSession con timeouts apropiados
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 30
//        configuration.timeoutIntervalForResource = 60
//        self.session = URLSession(configuration: configuration)
//        
//        // Configuramos el decoder para convertir automáticamente snake_case a camelCase
//        // La API devuelve campos como "short_description" y nosotros usamos "shortDescription"
//        self.decoder = JSONDecoder()
//        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
//        
//        // Configuración para fechas en formato ISO8601
//        self.decoder.dateDecodingStrategy = .iso8601
//    }
//    
//    // MARK: - Public Methods
//    
//    /// Realiza una petición GET genérica que devuelve un tipo decodificable
//    /// - Parameter endpoint: El endpoint al que hacer la petición
//    /// - Returns: El objeto decodificado del tipo especificado
//    /// - Throws: NetworkError si algo falla
//    func fetch<T: Decodable>(from endpoint: APIEndpoint) async throws -> T {
//        // Validamos que la URL sea válida
//        guard let url = endpoint.url else {
//            throw NetworkError.invalidURL
//        }
//        
//        // Realizamos la petición de forma asíncrona
//        let (data, response) = try await session.data(from: url)
//        
//        // Validamos que la respuesta HTTP sea exitosa (200-299)
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.unknownError
//        }
//        
//        guard (200...299).contains(httpResponse.statusCode) else {
//            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
//        }
//        
//        // Intentamos decodificar los datos en el tipo solicitado
//        do {
//            let decodedData = try decoder.decode(T.self, from: data)
//            return decodedData
//        } catch {
//            // Si falla el decode, lanzamos un error específico
//            print("❌ Error de decodificación: \(error)")
//            throw NetworkError.decodingError
//        }
//    }
//}
