//
//  BaseStore.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 25/01/26.
//

import Foundation
import OSLog

// MARK: - ObservableStore Protocol

/// Protocolo que define el comportamiento común de todos los stores
/// Usa composición en lugar de herencia para mayor flexibilidad
/// Los stores que conforman este protocolo deben ser @Observable y @MainActor
/// AnyObject restringe el protocolo a clases (necesario para @Observable)
protocol ObservableStore: AnyObject {
    
    /// Tipo de dato que gestiona el store
    associatedtype DataType
    
    // MARK: - Required Properties
    
    /// Datos actuales del store
    var data: DataType? { get set }
    
    /// Indica si se está cargando información
    var isLoading: Bool { get set }
    
    /// Error actual si lo hay (tipado)
    var error: AppError? { get set }
}

// MARK: - Default Implementations

extension ObservableStore {
    
    // MARK: - Computed Properties
    
    /// Indica si hay un error activo
    var hasError: Bool {
        error != nil
    }
    
    /// Mensaje de error legible para mostrar al usuario
    var errorMessage: String? {
        error?.errorDescription
    }
    
    /// Sugerencia de recuperación del error
    var recoverySuggestion: String? {
        error?.recoverySuggestion
    }
    
    // MARK: - Public Methods
    
    /// Limpia el error actual
    func clearError() {
        error = nil
        Logger.store.debug("Error cleared for \(String(describing: DataType.self))")
    }
    
    /// Establece el estado de loading
    /// - Parameter loading: true si está cargando, false si no
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            error = nil
        }
    }
    
    /// Establece un error
    /// - Parameter error: Error a establecer
    func setError(_ error: Error) {
        self.error = AppError.from(error)
        isLoading = false
        Logger.store.error("Error set for \(String(describing: DataType.self)): \(error.localizedDescription)")
    }
    
    /// Establece los datos
    /// - Parameter data: Datos a establecer
    func setData(_ data: DataType?) {
        self.data = data
        isLoading = false
        error = nil
    }
}
