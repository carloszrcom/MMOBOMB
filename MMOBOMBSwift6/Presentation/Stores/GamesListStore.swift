//
//  GamesListStore.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData
import OSLog

/// Store que gestiona el estado y lógica del listado de juegos
/// Hereda de BaseStore para reutilizar funcionalidad común
/// @Observable hace que SwiftUI detecte automáticamente cambios
/// @MainActor garantiza que todas las operaciones se ejecuten en el hilo principal
@MainActor
@Observable
final class GamesListStore: BaseStore<[Game]> {
    
    // MARK: - Properties
    
    /// Texto de búsqueda del usuario
    var searchText = ""
    
    // MARK: - Dependencies
    
    /// Repositorio para obtener los juegos (inyectado desde el Environment)
    /// Usamos el PROTOCOLO para desacoplamiento (no la implementación concreta)
    private let repository: GameRepositoryProtocol
    
    // MARK: - Computed Properties
    
    /// Juegos filtrados según el texto de búsqueda
    var filteredGames: [Game] {
        guard let games = data else { return [] }
        
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
    
    /// Alias para compatibilidad con código existente
    var games: [Game] {
        data ?? []
    }
    
    // MARK: - Initialization
    
    /// Inicializa el store con el repositorio compartido
    /// - Parameter repository: Repositorio inyectado desde el Environment (PROTOCOLO)
    init(repository: GameRepositoryProtocol) {
        self.repository = repository
        super.init()
        Logger.store.info("GamesListStore initialized")
    }
    
    // MARK: - Override Methods
    
    /// Carga la lista de juegos
    override func load() async {
        await loadGames(forceRefresh: false)
    }
    
    /// Refresca la lista de juegos
    override func refresh() async {
        await loadGames(forceRefresh: true)
    }
    
    // MARK: - Public Methods
    
    /// Carga la lista de juegos
    /// - Parameter forceRefresh: Si es true, ignora el cache y obtiene datos frescos
    func loadGames(forceRefresh: Bool = false) async {
        // Si ya estamos cargando, no hacemos nada
        guard !isLoading else {
            Logger.store.debug("Already loading games, skipping")
            return
        }
        
        Logger.store.info("Loading games (forceRefresh: \(forceRefresh))")
        setLoading(true)
        
        do {
            // Obtenemos los juegos del repositorio
            let fetchedGames = try await repository.fetchGames(forceRefresh: forceRefresh)
            
            // Si no hay juegos, establecemos un error
            if fetchedGames.isEmpty {
                setError(AppError.notFound)
                Logger.store.warning("No games found")
            } else {
                setData(fetchedGames)
                Logger.store.info("Successfully loaded \(fetchedGames.count) games")
            }
        } catch {
            // Si hay error, lo establecemos
            setError(error)
        }
    }
}

