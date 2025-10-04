//
//  GameDetailStore.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import Observation

/// Store que gestiona el estado y lógica de los detalles de un juego
@MainActor
@Observable
final class GameDetailStore {
    
    // MARK: - Published State
    
    /// Detalles del juego actual
    private(set) var gameDetail: GameDetail?
    
    /// Indica si se está cargando
    private(set) var isLoading = false
    
    /// Mensaje de error si lo hay
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let repository: GameRepository
    
    // MARK: - Computed Properties
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    // MARK: - Initialization
    
    init(repository: GameRepository) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Carga los detalles de un juego específico
    /// - Parameters:
    ///   - id: Identificador del juego
    ///   - forceRefresh: Si es true, ignora el cache
    func loadGameDetail(id: Int, forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            gameDetail = try await repository.fetchGameDetail(id: id, forceRefresh: forceRefresh)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error cargando detalles del juego: \(error)")
        }
        
        isLoading = false
    }
    
    /// Refresca los detalles del juego
    func refresh(id: Int) async {
        await loadGameDetail(id: id, forceRefresh: true)
    }
    
    /// Limpia el error actual
    func clearError() {
        errorMessage = nil
    }
}
