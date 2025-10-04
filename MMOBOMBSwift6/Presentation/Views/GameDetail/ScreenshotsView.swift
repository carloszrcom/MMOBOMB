//
//  ScreenshotsView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista que muestra una galería de capturas de pantalla
/// Permite hacer scroll horizontal para ver todas las imágenes
struct ScreenshotsView: View {
    
    // MARK: - Properties
    
    let screenshots: [Screenshot]
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título de la sección
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(.blue)
                
                Text("Capturas de pantalla")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Scroll horizontal de screenshots
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(screenshots) { screenshot in
                        ScreenshotCard(imageUrl: screenshot.imageUrl)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Screenshot Card

/// Tarjeta individual de una captura de pantalla
private struct ScreenshotCard: View {
    let imageUrl: String
    
    var body: some View {
        AsyncImageView(url: imageUrl, placeholderSize: 60)
            .frame(width: 300, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
