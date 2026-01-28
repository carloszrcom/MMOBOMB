//
//  EnvironmentValues+Repository.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 25/01/26.
//

import SwiftUI

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
