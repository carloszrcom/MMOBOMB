//
//  ErrorView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista de error reutilizable
/// Muestra un mensaje de error con opción de reintentar
struct ErrorView: View {
    
    // MARK: - Properties
    
    /// Mensaje de error a mostrar
    let message: String
    
    /// Acción a ejecutar al pulsar "Reintentar"
    let retryAction: () -> Void
    
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
