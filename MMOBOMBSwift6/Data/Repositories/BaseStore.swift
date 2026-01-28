//
//  BaseStore.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 25/01/26.
//

import Foundation
import OSLog

/// Store base genérico que encapsula comportamientos comunes
/// Reduce duplicación de código entre diferentes stores
/// @Observable permite a SwiftUI detectar cambios automáticamente
/// @MainActor garantiza que todas las operaciones se ejecuten en el hilo principal
@MainActor
@Observable
class BaseStore<T> {
    
    // MARK: - Published State
    
    /// Datos actuales del store
    private(set) var data: T?
    
    /// Indica si se está cargando información
    private(set) var isLoading = false
    
    /// Error actual si lo hay (tipado)
    private(set) var error: AppError?
    
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
        Logger.store.debug("Error cleared for \(String(describing: T.self))")
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
        Logger.store.error("Error set for \(String(describing: T.self)): \(error.localizedDescription)")
    }
    
    /// Establece los datos
    /// - Parameter data: Datos a establecer
    func setData(_ data: T?) {
        self.data = data
        isLoading = false
        error = nil
    }
    
    // MARK: - Template Methods
    
    /// Template method para cargar datos
    /// Las subclases deben sobreescribir este método
    func load() async {
        fatalError("Subclasses must override load()")
    }
    
    /// Template method para refrescar datos
    /// Las subclases deben sobreescribir este método
    func refresh() async {
        fatalError("Subclasses must override refresh()")
    }
}
