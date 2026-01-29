//
//  ImageCacheManager.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 28/01/26.
//

import SwiftUI
import OSLog

/// Manager para cachear imágenes en el sistema de archivos
/// Permite que las imágenes persistan entre sesiones y funcionen sin internet
@MainActor
final class ImageCacheManager {
    
    // MARK: - Singleton
    
    static let shared = ImageCacheManager()
    
    // MARK: - Properties
    
    /// Caché en memoria para acceso rápido (se pierde al cerrar la app)
    private var memoryCache: [String: UIImage] = [:]
    
    /// Directory donde se guardan las imágenes
    private let cacheDirectory: URL
    
    /// Tiempo máximo que una imagen puede estar en caché (1 semana)
    private let cacheExpirationInterval: TimeInterval = 7 * 24 * 60 * 60 // 7 días en segundos
    
    // MARK: - Initialization
    
    private init() {
        // Obtenemos el directorio de caché de la app
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache", isDirectory: true)
        
        // Creamos el directorio si no existe
        createCacheDirectoryIfNeeded()
        
        // Limpiamos imágenes expiradas al iniciar
        Task {
            await cleanExpiredImages()
        }
    }
    
    // MARK: - Public Methods
    
    /// Obtiene una imagen desde caché (memoria o disco) o la descarga si no existe
    /// - Parameter urlString: URL de la imagen a obtener
    /// - Returns: UIImage si se pudo obtener, nil en caso contrario
    func getImage(from urlString: String) async -> UIImage? {
        // 1. Intentar desde memoria (más rápido)
        if let cachedImage = memoryCache[urlString] {
            Logger.network.debug("Image loaded from memory cache: \(urlString)")
            return cachedImage
        }
        
        // 2. Intentar desde disco
        if let diskImage = loadFromDisk(urlString: urlString) {
            Logger.network.debug("Image loaded from disk cache: \(urlString)")
            memoryCache[urlString] = diskImage // Guardar en memoria para próxima vez
            return diskImage
        }
        
        // 3. Descargar de internet
        Logger.network.info("Downloading image: \(urlString)")
        guard let downloadedImage = await downloadImage(from: urlString) else {
            Logger.network.error("Failed to download image: \(urlString)")
            return nil
        }
        
        // 4. Guardar en ambas cachés
        memoryCache[urlString] = downloadedImage
        saveToDisk(image: downloadedImage, urlString: urlString)
        
        return downloadedImage
    }
    
    /// Limpia toda la caché (memoria y disco)
    func clearCache() {
        memoryCache.removeAll()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: nil
            )
            
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            Logger.network.info("Image cache cleared successfully")
        } catch {
            Logger.network.error("Failed to clear cache: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Crea el directorio de caché si no existe
    private func createCacheDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            do {
                try FileManager.default.createDirectory(
                    at: cacheDirectory,
                    withIntermediateDirectories: true
                )
                Logger.network.info("Cache directory created at: \(self.cacheDirectory.path)")
            } catch {
                Logger.network.error("Failed to create cache directory: \(error.localizedDescription)")
            }
        }
    }
    
    /// Genera un nombre de archivo único basado en la URL
    private func fileName(for urlString: String) -> String {
        // Usamos MD5 o simplemente un hash del string para crear un nombre único
        let hash = abs(urlString.hashValue)
        return "\(hash).jpg"
    }
    
    /// Carga una imagen desde el disco
    private func loadFromDisk(urlString: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(fileName(for: urlString))
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Verificar si la imagen ha expirado (más de 1 semana)
        if isImageExpired(fileURL: fileURL) {
            Logger.network.info("Image expired, deleting from cache: \(urlString)")
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
        
        // Cargar imagen si no ha expirado
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    /// Guarda una imagen en el disco
    private func saveToDisk(image: UIImage, urlString: String) {
        let fileURL = cacheDirectory.appendingPathComponent(fileName(for: urlString))
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            Logger.network.error("Failed to convert image to JPEG data")
            return
        }
        
        do {
            try data.write(to: fileURL)
            Logger.network.debug("Image saved to disk: \(fileURL.lastPathComponent)")
        } catch {
            Logger.network.error("Failed to save image to disk: \(error.localizedDescription)")
        }
    }
    
    /// Descarga una imagen desde internet
    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            Logger.network.error("Invalid URL: \(urlString)")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                Logger.network.error("Failed to create image from data")
                return nil
            }
            return image
        } catch {
            Logger.network.error("Failed to download image: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Verifica si una imagen en disco ha expirado (más de 1 semana)
    private func isImageExpired(fileURL: URL) -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return true // Si no podemos leer la fecha, consideramos expirada
        }
        
        let now = Date()
        let timeSinceModification = now.timeIntervalSince(modificationDate)
        
        return timeSinceModification > cacheExpirationInterval
    }
    
    /// Limpia todas las imágenes expiradas del disco
    private func cleanExpiredImages() async {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey]
            )
            
            var deletedCount = 0
            
            for fileURL in fileURLs {
                if isImageExpired(fileURL: fileURL) {
                    try? FileManager.default.removeItem(at: fileURL)
                    deletedCount += 1
                }
            }
            
            if deletedCount > 0 {
                Logger.network.info("Cleaned \(deletedCount) expired images from cache")
            }
            
        } catch {
            Logger.network.error("Failed to clean expired images: \(error.localizedDescription)")
        }
    }
}
