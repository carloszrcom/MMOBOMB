//
//  EnvironmentValues+Repository.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 25/01/26.
//

import SwiftUI

// MARK: - Repository Environment

/// EnvironmentKey para inyectar el repositorio como protocolo
/// Permite usar @Environment(\.gameRepository) en las vistas
private struct GameRepositoryKey: EnvironmentKey {
    static let defaultValue: GameRepositoryProtocol? = nil
}

extension EnvironmentValues {
    /// Repositorio de juegos disponible en el Environment
    /// Se inyecta desde el App y se accede con @Environment(\.gameRepository)
    var gameRepository: GameRepositoryProtocol? {
        get { self[GameRepositoryKey.self] }
        set { self[GameRepositoryKey.self] = newValue }
    }
}

extension View {
    /// Inyecta el repositorio en el Environment
    /// - Parameter repository: Repositorio a inyectar (como protocolo)
    /// - Returns: Vista con el repositorio inyectado
    func gameRepository(_ repository: GameRepositoryProtocol) -> some View {
        environment(\.gameRepository, repository)
    }
}
// MARK: - Stores Environment

/// EnvironmentKey para inyectar el store compartido de la lista de juegos
/// Permite usar @Environment(\.gamesListStore) en las vistas
private struct GamesListStoreKey: EnvironmentKey {
    static let defaultValue: GamesListStore? = nil
}

extension EnvironmentValues {
    /// Store compartido de la lista de juegos disponible en el Environment
    /// Se inyecta desde el App para preservar estado entre navegaciones
    var gamesListStore: GamesListStore? {
        get { self[GamesListStoreKey.self] }
        set { self[GamesListStoreKey.self] = newValue }
    }
}

