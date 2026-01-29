//
//  GameDetailStore.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import OSLog

/// Store que gestiona el estado y lógica de los detalles de un juego
/// Conforma ObservableStore para reutilizar funcionalidad común
/// Este store es LOCAL a la vista de detalles
@MainActor
@Observable
final class GameDetailStore: ObservableStore {
    
    // MARK: - ObservableStore Conformance
    
    /// Datos actuales (detalle del juego)
    var data: GameDetail?
    
    /// Indica si se está cargando información
    var isLoading = false
    
    /// Error actual si lo hay
    var error: AppError?
    
    // MARK: - Dependencies
    
    /// Repositorio inyectado desde el Environment
    /// Usamos el PROTOCOLO para desacoplamiento (no la implementación concreta)
    private let repository: GameRepositoryProtocol
    
    // MARK: - Computed Properties
    
    /// Alias para compatibilidad con código existente
    var gameDetail: GameDetail? {
        data
    }
    
    // MARK: - Initialization
    
    /// Inicializa el store con el repositorio compartido
    /// - Parameter repository: Repositorio inyectado desde el Environment (PROTOCOLO)
    init(repository: GameRepositoryProtocol) {
        self.repository = repository
        Logger.store.info("GameDetailStore initialized")
    }
    
    // MARK: - Public Methods (load/refresh no usados directamente para detalles)
    
    // MARK: - Public Methods (load/refresh no usados directamente para detalles)
    
    /// Carga los detalles de un juego específico
    /// - Parameters:
    ///   - id: Identificador del juego
    ///   - forceRefresh: Si es true, ignora el cache
    func loadGameDetail(id: Int, forceRefresh: Bool = false) async {
        guard !isLoading else {
            Logger.store.debug("Already loading game detail, skipping")
            return
        }
        
        Logger.store.info("Loading game detail for id: \(id) (forceRefresh: \(forceRefresh))")
        setLoading(true)
        
        do {
            let detail = try await repository.fetchGameDetail(id: id, forceRefresh: forceRefresh)
            setData(detail)
            Logger.store.info("Successfully loaded game detail for: \(detail.title)")
        } catch {
            setError(error)
        }
    }
    
    /// Refresca los detalles del juego
    /// - Parameter id: Identificador del juego
    func refresh(id: Int) async {
        await loadGameDetail(id: id, forceRefresh: true)
    }
}

