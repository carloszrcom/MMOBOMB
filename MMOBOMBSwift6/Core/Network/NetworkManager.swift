//
//  NetworkManager.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import OSLog

/// Gestor centralizado de las peticiones de red
/// Usa async/await para operaciones asíncronas modernas
/// Actor para garantizar thread-safety en las operaciones de red
actor NetworkManager {
    
    // MARK: - Properties
    
    /// Instancia compartida (Singleton) para usar en toda la app
    static let shared = NetworkManager()
    
    /// Logger para operaciones de red (nonisolated para usar dentro del actor)
    private nonisolated let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MMOBOMBSwift6", category: "Network")
    
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
        guard let url = await endpoint.url else {
            logger.error("Invalid URL for endpoint")
            throw NetworkError.invalidURL
        }
        
        logger.debug("Fetching from: \(url.absoluteString)")
        
        // Realizamos la petición de forma asíncrona
        let (data, response) = try await session.data(from: url)
        
        // Validamos que la respuesta HTTP sea exitosa (200-299)
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid HTTP response")
            throw NetworkError.unknownError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error("Server error with status code: \(httpResponse.statusCode)")
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        logger.info("Successfully fetched data from \(url.absoluteString)")
        
        // Intentamos decodificar los datos en el tipo solicitado
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            // Si falla el decode, lanzamos un error específico
            logger.error("Decoding error: \(error.localizedDescription)")
            throw NetworkError.decodingError
        }
    }
    
    /// Realiza una petición con reintentos automáticos y backoff exponencial
    /// - Parameters:
    ///   - endpoint: El endpoint al que hacer la petición
    ///   - maxRetries: Número máximo de reintentos (por defecto 3)
    /// - Returns: El objeto decodificado del tipo especificado
    /// - Throws: NetworkError si todos los reintentos fallan
    func fetchWithRetry<T: Decodable>(
        from endpoint: APIEndpoint,
        maxRetries: Int = 3
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await fetch(from: endpoint)
            } catch {
                lastError = error
                
                // No reintentar errores 4xx (errores del cliente)
                if let networkError = error as? NetworkError,
                   case .serverError(let code) = networkError,
                   (400..<500).contains(code) {
                    logger.warning("Client error \(code), not retrying")
                    throw error
                }
                
                // Backoff exponencial: 1s, 2s, 4s
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt))
                    logger.info("Retry attempt \(attempt + 1)/\(maxRetries) after \(delay)s")
                    try? await Task.sleep(for: .seconds(delay))
                }
            }
        }
        
        logger.error("All retry attempts failed")
        throw lastError ?? NetworkError.unknownError
    }
}

