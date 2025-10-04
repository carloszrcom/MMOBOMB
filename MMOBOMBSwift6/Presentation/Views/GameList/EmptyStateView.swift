//
//  EmptyStateView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista que se muestra cuando no hay juegos disponibles
struct EmptyStateView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            // Icono de estado vacío
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No hay juegos disponibles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Intenta recargar la lista")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
