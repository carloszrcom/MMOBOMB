//
//  LoadingView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista de carga reutilizable
/// Muestra un spinner con un mensaje opcional
struct LoadingView: View {
    
    // MARK: - Properties
    
    /// Mensaje a mostrar debajo del spinner
    let message: String
    
    // MARK: - Initialization
    
    init(message: String = "Cargando...") {
        self.message = message
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
