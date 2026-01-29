//
//  AsyncImageView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Componente reutilizable para cargar imágenes de forma asíncrona con caché persistente
/// Muestra un placeholder mientras carga y maneja errores
/// Las imágenes se guardan en disco y están disponibles sin conexión
struct AsyncImageView: View {
    
    // MARK: - Properties
    
    /// URL de la imagen a cargar
    let url: String
    
    /// Tamaño del placeholder
    let placeholderSize: CGFloat
    
    /// Estado de carga de la imagen
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    // MARK: - Initialization
    
    init(url: String, placeholderSize: CGFloat = 50) {
        self.url = url
        self.placeholderSize = placeholderSize
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if isLoading {
                // Mientras carga, mostramos un indicador de progreso
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let loadedImage {
                // Imagen cargada correctamente (desde caché o internet)
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            } else {
                // Error al cargar la imagen (no hay caché ni internet)
                Image(systemName: "photo.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: placeholderSize, height: placeholderSize)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            // Intentar cargar la imagen desde caché o internet
            loadedImage = await ImageCacheManager.shared.getImage(from: url)
            isLoading = false
        }
    }
}
