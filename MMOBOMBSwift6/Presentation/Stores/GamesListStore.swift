//
//  GamesListStore.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData
import Observation

/// Store que gestiona el estado y lógica del listado de juegos
/// @Observable hace que SwiftUI detecte automáticamente cambios
/// @MainActor garantiza que todas las operaciones se ejecuten en el hilo principal
/// Este store es LOCAL a la vista y se crea/destruye con ella
@MainActor
@Observable
final class GamesListStore {
    
    // MARK: - Published State
    
    /// Lista de juegos a mostrar
    private(set) var games: [Game] = []
    
    /// Indica si se está cargando información
    private(set) var isLoading = false
    
    /// Error actual si lo hay
    private(set) var errorMessage: String?
    
    /// Texto de búsqueda del usuario
    var searchText = ""
    
    // MARK: - Dependencies
    
    /// Repositorio para obtener los juegos (inyectado desde el Environment)
    /// Usamos la implementación concreta directamente
    private let repository: GameRepositoryImpl
    
    // MARK: - Computed Properties
    
    /// Juegos filtrados según el texto de búsqueda
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return games
        }
        
        // Filtramos por título, género, plataforma o desarrollador
        return games.filter { game in
            game.title.localizedCaseInsensitiveContains(searchText) ||
            game.genre.localizedCaseInsensitiveContains(searchText) ||
            game.platform.localizedCaseInsensitiveContains(searchText) ||
            game.developer.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    /// Indica si hay un error activo
    var hasError: Bool {
        errorMessage != nil
    }
    
    // MARK: - Initialization
    
    /// Inicializa el store con el repositorio compartido
    /// - Parameter repository: Repositorio inyectado desde el Environment
    init(repository: GameRepositoryImpl) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Carga la lista de juegos
    /// - Parameter forceRefresh: Si es true, ignora el cache y obtiene datos frescos
    func loadGames(forceRefresh: Bool = false) async {
        // Si ya estamos cargando, no hacemos nada
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Obtenemos los juegos del repositorio
            games = try await repository.fetchGames(forceRefresh: forceRefresh)
            
            // Si no hay juegos, mostramos un mensaje
            if games.isEmpty {
                errorMessage = "No se encontraron juegos"
            }
        } catch {
            // Si hay error, guardamos el mensaje
            errorMessage = error.localizedDescription
            print("❌ Error cargando juegos: \(error)")
        }
        
        isLoading = false
    }
    
    /// Refresca la lista de juegos desde la API
    func refresh() async {
        await loadGames(forceRefresh: true)
    }
    
    /// Limpia el error actual
    func clearError() {
        errorMessage = nil
    }
}
