//
//  GameRowView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista de una celda individual en el listado de juegos
/// Muestra la información básica del juego de forma atractiva
struct GameRowView: View {
    
    // MARK: - Properties
    
    /// El juego a mostrar
    let game: Game
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail del juego
            AsyncImageView(url: game.thumbnail, placeholderSize: 40)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            
            // Información del juego
            VStack(alignment: .leading, spacing: 6) {
                // Título del juego
                Text(game.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Descripción corta
                Text(game.shortDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // Badges de género y plataforma
                HStack(spacing: 8) {
                    Badge(text: game.genre, icon: "tag.fill")
                    Badge(text: game.platform, icon: "laptopcomputer")
                }
            }
            
            Spacer(minLength: 0)
            
            // Indicador de navegación
//            Image(systemName: "chevron.right")
//                .font(.caption)
//                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Badge Component

/// Componente pequeño para mostrar etiquetas de información
private struct Badge: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    List {
        GameRowView(
            game: Game(
                id: 1,
                title: "Call of Duty: Warzone",
                thumbnail: "https://www.mmobomb.com/g/452/thumbnail.jpg",
                shortDescription: "Popular battle royale shooter",
                gameUrl: "https://www.mmobomb.com",
                genre: "Shooter",
                platform: "PC (Windows)",
                publisher: "Activision",
                developer: "Infinity Ward",
                releaseDate: Date(),
                profileUrl: "https://www.mmobomb.com"
            )
        )
    }
}
