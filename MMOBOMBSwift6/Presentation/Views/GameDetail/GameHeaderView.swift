//
//  GameHeaderView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Cabecera de la vista de detalles con la imagen principal
/// Muestra el thumbnail en grande con un efecto visual atractivo
struct GameHeaderView: View {
    
    // MARK: - Properties
    
    let thumbnailUrl: String
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Imagen de fondo
            AsyncImageView(url: thumbnailUrl, placeholderSize: 80)
                .frame(height: 250)
                .clipped()
            
            // Gradiente para mejorar la legibilidad del título
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Título del juego sobre el gradiente
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
        }
        .frame(height: 250)
    }
}
