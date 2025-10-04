//
//  AsyncImageView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Componente reutilizable para cargar imágenes de forma asíncrona
/// Muestra un placeholder mientras carga y maneja errores
struct AsyncImageView: View {
    
    // MARK: - Properties
    
    /// URL de la imagen a cargar
    let url: String
    
    /// Tamaño del placeholder
    let placeholderSize: CGFloat
    
    // MARK: - Initialization
    
    init(url: String, placeholderSize: CGFloat = 50) {
        self.url = url
        self.placeholderSize = placeholderSize
    }
    
    // MARK: - Body
    
    var body: some View {
        // AsyncImage es el componente nativo de SwiftUI para imágenes remotas
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                // Mientras carga, mostramos un indicador de progreso
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .success(let image):
                // Imagen cargada correctamente
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            case .failure:
                // Error al cargar la imagen
                Image(systemName: "photo.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: placeholderSize, height: placeholderSize)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            @unknown default:
                EmptyView()
            }
        }
    }
}
