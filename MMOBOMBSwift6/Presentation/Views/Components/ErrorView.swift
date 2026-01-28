//
//  ErrorView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista de error reutilizable
/// Muestra un mensaje de error con opción de reintentar y sugerencia de recuperación
struct ErrorView: View {
    
    // MARK: - Properties
    
    /// Mensaje de error a mostrar
    let message: String
    
    /// Sugerencia de recuperación (opcional)
    let recovery: String?
    
    /// Acción a ejecutar al pulsar "Reintentar"
    let retryAction: () -> Void
    
    // MARK: - Initialization
    
    /// Inicializador con sugerencia de recuperación opcional
    init(
        message: String,
        recovery: String? = nil,
        retryAction: @escaping () -> Void
    ) {
        self.message = message
        self.recovery = recovery
        self.retryAction = retryAction
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Icono de error
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            // Mensaje de error
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Sugerencia de recuperación si existe
            if let recovery = recovery {
                Text(recovery)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, -10)
            }
            
            // Botón de reintentar
            Button(action: retryAction) {
                Label("Reintentar", systemImage: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
// MARK: - Preview

#Preview("Error simple") {
    ErrorView(message: "No se pudo conectar al servidor") {
        print("Retry tapped")
    }
}

#Preview("Error con sugerencia") {
    ErrorView(
        message: "Error de conexión",
        recovery: "Verifica tu conexión a internet e inténtalo de nuevo"
    ) {
        print("Retry tapped")
    }
}


