---
name: apple-dev
description: Directrices de desarrollo nativo Apple para iOS, iPadOS, macOS, watchOS, tvOS y visionOS. Usar cuando se trabaje con Swift, SwiftUI, UIKit, Xcode o cualquier framework del ecosistema Apple. Garantiza código moderno, nativo, sin dependencias de terceros y siguiendo las mejores prácticas actuales de Apple.
---

# Apple Development Guidelines

Directrices obligatorias para desarrollo en el ecosistema Apple.

## Versiones y Contexto Temporal

- **Fecha actual de referencia**: Enero 2026
- **iOS 26** (y sus equivalentes en otras plataformas) fue lanzado en **septiembre de 2025** y lleva varios meses de vida
- **Lenguaje de diseño actual**: **Liquid Glass** (introducido en iOS 26, sucesor del diseño flat)
- **Swift 6.2** es la versión actual del lenguaje con Approachable Concurrency
- **Xcode 26** es la versión actual del IDE

## Versiones Mínimas de Despliegue

Establecer siempre como deployment target mínimo:

- iOS 18.0 / iPadOS 18.0
- macOS 15.0 (Sequoia)
- watchOS 11.0
- tvOS 18.0
- visionOS 2.0

Justificación: estas versiones tienen parches de seguridad activos y soportan todas las APIs modernas incluyendo Swift 6, concurrencia estricta y las nuevas macros.

## Concurrencia: async/await Obligatorio

**PROHIBIDO usar Grand Central Dispatch (GCD)** para operaciones asíncronas en código nuevo.

### Usar siempre:
- `async/await` para operaciones asíncronas
- `Task {}` para lanzar contextos asíncronos desde código síncrono
- `TaskGroup` para operaciones paralelas
- `AsyncSequence` y `AsyncStream` para flujos de datos
- `@MainActor` para código que debe ejecutarse en el hilo principal
- Actores (`actor`) para estado compartido thread-safe
- `Sendable` para tipos que cruzan boundaries de concurrencia
- Framework `Synchronization` con `Atomic` para operaciones atómicas sin contextos asíncronos

### NO usar:
- `DispatchQueue.main.async {}`
- `DispatchQueue.global().async {}`
- `DispatchGroup`
- `DispatchSemaphore`
- `OperationQueue` (salvo casos muy específicos de cancelación compleja)
- Callbacks con `@escaping` cuando existe alternativa async

#### Ejemplo de migración:
##

```swift
// ❌ INCORRECTO - GCD legacy
DispatchQueue.global().async {
    let data = fetchData()
    DispatchQueue.main.async {
        self.updateUI(with: data)
    }
}

// ✅ CORRECTO - async/await moderno
Task {
    let data = await fetchData()
    await MainActor.run {
        updateUI(with: data)
    }
}
```

## Navegación

**OBLIGATORIO usar NavigationStack** (iOS 16+) para navegación programática y declarativa.
### Principios fundamentales:

1. **NavigationStack con NavigationPath** para navegación jerárquica
2. **Routers con @Observable** para gestión centralizada de navegación
3. **TabView** para navegación horizontal entre secciones principales
4. **fullScreenCover** para presentaciones modales a pantalla completa
5. **Cada flujo de navegación debe tener su propio Router independiente**

### NO usar:
- `NavigationView` (deprecado desde iOS 16)
- `NavigationLink` con destino inline (solo para casos simples)
- Patrones de Coordinator basados en UIKit

### Patrón Router (@Observable)

Cada flujo de navegación debe tener un Router dedicado que gestione su `NavigationPath`:

```swift
@Observable
final class HomeRouter {
    enum Destination: Codable, Hashable {
        case detail
        case settings
        case profile(userId: String)
    }
    
    var navPath = NavigationPath()
    
    func navigate(to destination: Destination) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        guard !navPath.isEmpty else { return }
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
```

**Notas importantes:**
- El enum `Destination` debe conformar `Codable` y `Hashable`
- Usar `@Observable` (Swift 5.9+) en lugar de `ObservableObject`
- Validar que `navPath` no esté vacío antes de `removeLast()`

### Implementación en Vista

```swift
struct HomeView: View {
    @State private var router = HomeRouter()
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            ScrollView {
                Button("Ir a Detalle") {
                    router.navigate(to: .detail)
                }
            }
            .navigationTitle("Inicio")
            .navigationDestination(for: HomeRouter.Destination.self) { destination in
                switch destination {
                case .detail:
                    DetailView()
                case .settings:
                    SettingsView()
                case .profile(let userId):
                    ProfileView(userId: userId)
                }
            }
        }
    }
}
```

**Mejores prácticas:**
- Usar `@State` para el router (no `@StateObject`)
- Declarar `navigationDestination` UNA sola vez por NavigationStack
- El switch debe cubrir todos los casos del enum

### Routers Independientes por Flujo

**IMPORTANTE**: Cada flujo de navegación modal o fullscreen debe tener su propio Router:

```swift
// Router para el flujo principal
@State private var homeRouter = HomeRouter()

// Router INDEPENDIENTE para flujo modal
@State private var chatRouter = ChatRouter()

NavigationStack(path: $homeRouter.navPath) {
    // Contenido principal
}

.fullScreenCover(isPresented: $showChat) {
    NavigationStack(path: $chatRouter.navPath) {
        ChatView()
            .navigationDestination(for: ChatRouter.Destination.self) { destination in
                // Destinos del chat
            }
    }
}
```

### Router para Presentaciones Modales

Para gestionar presentaciones fullScreen de forma centralizada:

```swift
@Observable
final class FullScreenRouter {
    var isPresented: Bool = false
    var activeView: AnyView = AnyView(EmptyView())
    
    func present<V: View>(_ view: V) {
        activeView = AnyView(view)
        isPresented = true
    }
    
    func dismiss() {
        isPresented = false
    }
}

// Uso en ContentView
struct ContentView: View {
    @State private var fullScreenRouter = FullScreenRouter()
    
    var body: some View {
        MainView()
            .fullScreenCover(isPresented: $fullScreenRouter.isPresented) {
                fullScreenRouter.activeView
            }
            .environment(fullScreenRouter)
    }
}

// En cualquier vista hija
struct SomeView: View {
    @Environment(FullScreenRouter.self) var fullScreenRouter
    
    var body: some View {
        Button("Abrir Chat") {
            fullScreenRouter.present(ChatView())
        }
    }
}
```

### Navegación de Estado Global (App-wide)

Para transiciones entre flujos principales (onboarding, autenticación, app principal):

```swift
@Observable
final class NavigationState {
    enum Route: Hashable {
        case loader
        case onboarding
        case tabView
    }
    
    var currentRoute: Route = .loader
    
    @MainActor
    func startNavigation() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.smooth) {
                currentRoute = .tabView
            }
        }
    }
}

// En ContentView
struct ContentView: View {
    @State private var navigationState = NavigationState()
    
    var body: some View {
        Group {
            switch navigationState.currentRoute {
            case .loader:
                LoaderView()
            case .onboarding:
                OnboardingView()
            case .tabView:
                MainTabView()
            }
        }
        .task {
            navigationState.startNavigation()
        }
    }
}
```

### TabView para Navegación Horizontal

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gear")
                }
        }
    }
}
```

**Notas:**
- Usar `Label` en lugar de `Image` + `Text` por separado
- Cada tab puede tener su propio `NavigationStack` con su Router
- Preferir SF Symbols para iconos

### Pasar Router a Vistas Hijas

Cuando una vista hija necesita controlar la navegación:

```swift
struct DetailView: View {
    var router: HomeRouter  // Inyección directa
    
    var body: some View {
        VStack {
            Button("Ir a Perfil") {
                router.navigate(to: .profile(userId: "123"))
            }
            
            Button("Volver a Inicio") {
                router.navigateToRoot()
            }
        }
    }
}
```

**NO** usar `@ObservedObject` ni `@Binding` para pasar routers con `@Observable`.

### Deep Linking y URL Handling

Para manejar URLs externas o enlaces profundos:

```swift
struct ContentView: View {
    @State private var router = HomeRouter()
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            HomeView()
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Parsear URL y navegar
        if url.pathComponents.contains("profile"),
           let userId = url.pathComponents.last {
            router.navigate(to: .profile(userId: userId))
        }
    }
}
```

### Resumen de Arquitectura de Navegación

```
ContentView
├── NavigationState (gestiona flujos principales: loader, onboarding, tabs)
├── FullScreenRouter (presentaciones modales globales)
│
└── MainTabView
    ├── HomeView + HomeRouter (navegación jerárquica)
    ├── ProfileView + ProfileRouter (navegación jerárquica)
    └── SettingsView + SettingsRouter (navegación jerárquica)
```

**Reglas de oro:**
- Un Router por cada flujo de navegación independiente
- NavigationStack + NavigationPath para navegación jerárquica
- @Observable en lugar de ObservableObject
- @State en lugar de @StateObject
- Enum tipado para destinos (con Codable + Hashable)
- .environment() para compartir routers modales


## Imágenes Remotas

**OBLIGATORIO implementar caché persistente** para imágenes que vienen de servicios remotos.

### Principios fundamentales:

1. **NO usar `AsyncImage` directamente** - No cachea entre sesiones
2. **Implementar ImageCacheManager** con caché en disco + memoria
3. **Persistir imágenes en `FileManager.cachesDirectory`**
4. **Estrategia de 3 niveles**: Memoria → Disco → Red

### Arquitectura Requerida

#### ImageCacheManager (Singleton)
```swift
@MainActor
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private var memoryCache: [String: UIImage] = [:]
    private let cacheDirectory: URL
    
    func getImage(from urlString: String) async -> UIImage? {
        // 1. Buscar en memoria (rápido)
        if let cached = memoryCache[urlString] { return cached }
        
        // 2. Buscar en disco (offline-capable)
        if let diskImage = loadFromDisk(urlString: urlString) {
            memoryCache[urlString] = diskImage
            return diskImage
        }
        
        // 3. Descargar y guardar
        guard let downloaded = await downloadImage(from: urlString) else { return nil }
        memoryCache[urlString] = downloaded
        saveToDisk(image: downloaded, urlString: urlString)
        return downloaded
    }
}
```

#### AsyncImageView (Componente Reutilizable)

```swift
struct AsyncImageView: View {
    let url: String
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
            } else {
                Image(systemName: "photo.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            loadedImage = await ImageCacheManager.shared.getImage(from: url)
            isLoading = false
        }
    }
}
```

### Detalles de Implementación

**Directorio de caché:**
```swift
let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
cacheDirectory = paths[0].appendingPathComponent("ImageCache", isDirectory: true)
```

**Nombre de archivo único:**
```swift
private func fileName(for urlString: String) -> String {
    "\(abs(urlString.hashValue)).jpg"
}
```

**Guardar en disco:**
```swift
private func saveToDisk(image: UIImage, urlString: String) {
    let fileURL = cacheDirectory.appendingPathComponent(fileName(for: urlString))
    guard let data = image.jpegData(compressionQuality: 0.8) else { return }
    try? data.write(to: fileURL)
}
```

**Descargar con URLSession:**
```swift
private func downloadImage(from urlString: String) async -> UIImage? {
    guard let url = URL(string: urlString) else { return nil }
    let (data, _) = try? await URLSession.shared.data(from: url)
    return data.flatMap { UIImage(data: $0) }
}
```

### Alternativas Profesionales

Para proyectos grandes considerar librerías especializadas:
- **Kingfisher** (más popular, altamente optimizada)
- **Nuke** (moderna, excelente performance)
- **SDWebImage** (estable, legacy-friendly)

### Ventajas del Caché Persistente

- ✅ **Funciona offline**: Imágenes disponibles sin internet
- ✅ **Mejora UX**: No re-descargas en cada sesión
- ✅ **Ahorra datos**: Reduce consumo de red
- ✅ **Performance**: Caché en memoria = carga instantánea

### Logging Recomendado

```swift
Logger.network.debug("Image loaded from memory cache")
Logger.network.debug("Image loaded from disk cache")
Logger.network.info("Downloading image: \(urlString)")
Logger.network.error("Failed to download image")
```

### NO hacer:

- ❌ Usar `AsyncImage` sin wrapper de caché
- ❌ Guardar imágenes en `Documents` (usar `Caches`)
- ❌ Cachear solo en memoria (se pierde al cerrar app)
- ❌ Descargar imágenes de forma síncrona


## Obtener datos del servidor

**OBLIGATORIO usar patrón Repository** con caché local (SwiftData) para toda comunicación con servicios remotos.

### Principios fundamentales:

1. **Arquitectura en 3 capas**: DTO → Domain Model → Entity
2. **Repository Pattern** con estrategia caché-first
3. **SwiftData** como capa de persistencia (no Core Data)
4. **Mappers** dedicados para conversión entre capas
5. **Typed Throws** para manejo de errores específico
6. **@MainActor** en Repository para thread-safety con SwiftData

### Arquitectura Completa
```
Vista (SwiftUI)
    ↓
Store (@Observable @MainActor)
    ↓
Repository (Protocol + Impl @MainActor)
    ↓ ↙ ↘
Cache      Network
(SwiftData) (URLSession)
    ↓           ↓
Entity      DTO
    ↘       ↙
    Domain Model
```

---

## 1. Domain Model (Modelo de Negocio)

El modelo limpio que se usa en TODA la app:

```swift
struct Game: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let thumbnail: String
    let shortDescription: String
    let gameUrl: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let releaseDate: Date
    let profileUrl: String
}
```

**Características:**
- `struct` inmutable (value type)
- Nombres en `camelCase` (Swift style)
- `Identifiable` para SwiftUI
- `Codable` para serialización si es necesario
- `Hashable` para NavigationPath
- Sin dependencias de frameworks externos

---

## 2. DTO (Data Transfer Object)

Representa la estructura EXACTA del JSON del servidor:

```swift
struct GameDTO: Codable {
    let id: Int
    let title: String
    let thumbnail: String
    let short_description: String      // ← snake_case del servidor
    let game_url: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let release_date: String           // ← String, se convierte después
    let freetogame_profile_url: String
}
```

**Características:**
- Solo `Codable` (para decodificación automática)
- Nombres EXACTOS del JSON (snake_case)
- Tipos primitivos (String, Int, etc.)
- Solo se usa en NetworkManager
- Vida útil: < 1 segundo

**CodingKeys cuando los nombres no coinciden:**
```swift
struct GameDTO: Codable {
    let id: Int
    let profileUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case profileUrl = "freetogame_profile_url"
    }
}
```

---

## 3. Entity (Modelo de Persistencia)

Representa el dato guardado en SwiftData:

```swift
import SwiftData

@Model
final class GameEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var thumbnail: String
    var shortDescription: String
    var gameUrl: String
    var genre: String
    var platform: String
    var publisher: String
    var developer: String
    var releaseDate: Date
    var profileUrl: String
    var cachedAt: Date  // ← Metadata para control de caché
    
    init(id: Int, title: String, /* ... */, cachedAt: Date = Date()) {
        self.id = id
        self.title = title
        // ...
        self.cachedAt = cachedAt
    }
}
```

**Características:**
- `@Model` macro de SwiftData
- `class` (requirement de SwiftData)
- `@Attribute(.unique)` para clave primaria
- Metadata adicional (`cachedAt` para TTL)
- Nombres en `camelCase`
- Inicializador explícito

---

## 4. Mappers (Conversores)

Funciones dedicadas para convertir entre capas:

```swift
enum GameMapper {
    
    // DTO → Domain Model
    static func toModel(from dto: GameDTO) -> Game {
        Game(
            id: dto.id,
            title: dto.title,
            thumbnail: dto.thumbnail,
            shortDescription: dto.short_description,
            gameUrl: dto.game_url,
            genre: dto.genre,
            platform: dto.platform,
            publisher: dto.publisher,
            developer: dto.developer,
            releaseDate: ISO8601DateFormatter().date(from: dto.release_date) ?? Date(),
            profileUrl: dto.freetogame_profile_url
        )
    }
    
    // Domain Model → Entity
    static func toEntity(from model: Game) -> GameEntity {
        GameEntity(
            id: model.id,
            title: model.title,
            thumbnail: model.thumbnail,
            shortDescription: model.shortDescription,
            gameUrl: model.gameUrl,
            genre: model.genre,
            platform: model.platform,
            publisher: model.publisher,
            developer: model.developer,
            releaseDate: model.releaseDate,
            profileUrl: model.profileUrl,
            cachedAt: Date()
        )
    }
    
    // Entity → Domain Model
    static func toModel(from entity: GameEntity) -> Game {
        Game(
            id: entity.id,
            title: entity.title,
            thumbnail: entity.thumbnail,
            shortDescription: entity.shortDescription,
            gameUrl: entity.gameUrl,
            genre: entity.genre,
            platform: entity.platform,
            publisher: entity.publisher,
            developer: entity.developer,
            releaseDate: entity.releaseDate,
            profileUrl: entity.profileUrl
        )
    }
}
```

**Ventajas:**
- Conversión centralizada (un solo lugar)
- Lógica de transformación explícita (fechas, formateo)
- Fácil de testear
- Desacopla capas completamente

---

## 5. NetworkManager

Gestiona peticiones HTTP y decodificación:

```swift
import Foundation
import OSLog

final class NetworkManager: Sendable {
    static let shared = NetworkManager()
    
    private init() {}
    
    // Fetch genérico con retry automático
    func fetchWithRetry<T: Codable>(
        from endpoint: APIEndpoint,
        maxRetries: Int = 3
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                let url = endpoint.url
                Logger.network.info("Fetching from: \(url.absoluteString)")
                
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                
                let decoded = try JSONDecoder().decode(T.self, from: data)
                Logger.network.info("Successfully decoded response")
                return decoded
                
            } catch {
                lastError = error
                Logger.network.warning("Attempt \(attempt)/\(maxRetries) failed: \(error)")
                
                if attempt < maxRetries {
                    try await Task.sleep(for: .seconds(1))
                }
            }
        }
        
        throw lastError ?? NetworkError.unknown
    }
}
```

**Características clave:**
- `Sendable` para concurrencia segura
- Retry automático con backoff
- Logging detallado
- Genérico (`<T: Codable>`)
- Validación de status code HTTP

---

## 6. APIEndpoint

Define endpoints de forma tipo-segura:

```swift
enum APIEndpoint {
    case gamesList
    case gameDetail(id: Int)
    
    var url: URL {
        let baseURL = "https://www.mmobomb.com/api1"
        
        switch self {
        case .gamesList:
            return URL(string: "\(baseURL)/games")!
        case .gameDetail(let id):
            return URL(string: "\(baseURL)/game?id=\(id)")!
        }
    }
}
```

**Uso:**
```swift
let games: [GameDTO] = try await networkManager.fetchWithRetry(from: .gamesList)
let detail: GameDetailDTO = try await networkManager.fetchWithRetry(from: .gameDetail(id: 452))
```

---

## 7. Repository Protocol

Define el contrato de acceso a datos:

```swift
import Foundation

protocol GameRepositoryProtocol: Sendable {
    
    /// Obtiene el listado completo de juegos
    /// - Parameter forceRefresh: Si es true, ignora cache y obtiene de API
    /// - Returns: Array de modelos Game
    /// - Throws: AppError tipado
    func fetchGames(forceRefresh: Bool) async throws(AppError) -> [Game]
    
    /// Obtiene detalles de un juego específico
    /// - Parameters:
    ///   - id: Identificador del juego
    ///   - forceRefresh: Si es true, ignora cache
    /// - Returns: GameDetail completo
    /// - Throws: AppError tipado
    func fetchGameDetail(id: Int, forceRefresh: Bool) async throws(AppError) -> GameDetail
}
```

**Ventajas del protocolo:**
- Permite inyección de mocks en tests
- Desacopla implementación de interfaz
- `Sendable` para uso seguro en concurrencia
- `throws(AppError)` para typed throws (Swift 6)

---

## 8. Repository Implementation

Implementa la lógica caché-first:

```swift
import SwiftData
import OSLog

@Observable
@MainActor
final class GameRepositoryImpl: GameRepositoryProtocol {
    
    private let modelContext: ModelContext
    private let networkManager: NetworkManager
    
    init(modelContext: ModelContext, networkManager: NetworkManager = .shared) {
        self.modelContext = modelContext
        self.networkManager = networkManager
    }
    
    func fetchGames(forceRefresh: Bool = false) async throws(AppError) -> [Game] {
        Logger.store.info("Fetching games (forceRefresh: \(forceRefresh))")
        
        // 1. Si no forzamos refresh, intentar desde cache
        if !forceRefresh {
            let cachedGames = try fetchGamesFromCache()
            
            if !cachedGames.isEmpty && !isCacheExpired(cachedGames.first?.cachedAt) {
                Logger.database.info("Returning \(cachedGames.count) games from cache")
                return cachedGames.map { GameMapper.toModel(from: $0) }
            }
        }
        
        // 2. Obtener de la API
        do {
            let gamesDTO: [GameDTO] = try await networkManager.fetchWithRetry(from: .gamesList)
            let games = gamesDTO.map { GameMapper.toModel(from: $0) }
            
            Logger.store.info("Successfully fetched \(games.count) games from API")
            
            // 3. Guardar en cache (estrategia upsert)
            saveGamesToCache(games)
            
            return games
            
        } catch {
            Logger.network.error("Failed to fetch games: \(error)")
            throw AppError.from(error)
        }
    }
    
    // MARK: - Cache Methods
    
    private func fetchGamesFromCache() throws(AppError) -> [GameEntity] {
        let descriptor = FetchDescriptor<GameEntity>(
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Logger.database.error("Failed to fetch from cache: \(error)")
            throw AppError.database("Error al obtener datos del cache")
        }
    }
    
    private func saveGamesToCache(_ games: [Game]) {
        Logger.database.info("Saving \(games.count) games to cache")
        
        for game in games {
            let gameId = game.id
            let predicate = #Predicate<GameEntity> { $0.id == gameId }
            let descriptor = FetchDescriptor<GameEntity>(predicate: predicate)
            
            do {
                if let existing = try modelContext.fetch(descriptor).first {
                    // Actualizar (upsert)
                    existing.title = game.title
                    existing.thumbnail = game.thumbnail
                    // ... actualizar todos los campos
                    existing.cachedAt = Date()
                    Logger.database.debug("Updated game: \(game.title)")
                } else {
                    // Insertar nuevo
                    let entity = GameMapper.toEntity(from: game)
                    modelContext.insert(entity)
                    Logger.database.debug("Inserted game: \(game.title)")
                }
            } catch {
                Logger.database.error("Error upserting game \(game.id): \(error)")
            }
        }
        
        // Persistir cambios
        do {
            try modelContext.save()
            Logger.database.info("Successfully saved games to cache")
        } catch {
            Logger.database.error("Failed to save cache: \(error)")
        }
    }
    
    private func isCacheExpired(_ cachedDate: Date?) -> Bool {
        guard let cachedDate else { return true }
        
        let timeInterval = Date().timeIntervalSince(cachedDate)
        let expirationTime: TimeInterval = 86400 // 24 horas
        
        return timeInterval > expirationTime
    }
}
```

**Estrategia caché-first:**
1. Buscar en SwiftData (instantáneo)
2. Validar TTL (Time To Live)
3. Si válido → Retornar (sin red)
4. Si expirado → Fetch de API
5. Guardar en cache (upsert, no borrar todo)
6. Retornar datos frescos

**Ventajas:**
- `@MainActor` garantiza thread-safety con ModelContext
- Estrategia upsert preserva datos no modificados
- TTL configurable (24h por defecto)
- Funciona offline si cache válido

---

## 9. Store (ViewModel con @Observable)

Gestiona estado de UI y coordina con Repository:

```swift
import Foundation
import OSLog

@MainActor
@Observable
final class GamesListStore: ObservableStore {
    
    // Conformance al protocolo ObservableStore
    var data: [Game]?
    var isLoading = false
    var error: AppError?
    
    // Propiedades específicas
    var searchText = ""
    
    private let repository: GameRepositoryProtocol
    
    // Computed
    var games: [Game] { data ?? [] }
    
    var filteredGames: [Game] {
        guard let games = data else { return [] }
        
        if searchText.isEmpty { return games }
        
        return games.filter { game in
            game.title.localizedCaseInsensitiveContains(searchText) ||
            game.genre.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(repository: GameRepositoryProtocol) {
        self.repository = repository
        Logger.store.info("GamesListStore initialized")
    }
    
    func loadGames(forceRefresh: Bool = false) async {
        guard !isLoading else {
            Logger.store.debug("Already loading, skipping")
            return
        }
        
        Logger.store.info("Loading games (forceRefresh: \(forceRefresh))")
        setLoading(true)
        
        do {
            let fetchedGames = try await repository.fetchGames(forceRefresh: forceRefresh)
            
            if fetchedGames.isEmpty {
                setError(AppError.notFound)
            } else {
                setData(fetchedGames)
                Logger.store.info("Successfully loaded \(fetchedGames.count) games")
            }
        } catch {
            setError(error)
        }
    }
    
    func refresh() async {
        await loadGames(forceRefresh: true)
    }
}
```

**Características:**
- `@Observable` (iOS 17+, no `ObservableObject`)
- `@MainActor` para actualizaciones de UI
- Conforma protocolo `ObservableStore` (reutilizable)
- Lógica de búsqueda en computed property
- Guard contra carga simultánea

---

## 10. ObservableStore Protocol (Base Reutilizable)

Define comportamiento común para todos los stores:

```swift
import Foundation
import OSLog

protocol ObservableStore: AnyObject {
    associatedtype DataType
    
    var data: DataType? { get set }
    var isLoading: Bool { get set }
    var error: AppError? { get set }
}

extension ObservableStore {
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String? {
        error?.errorDescription
    }
    
    var recoverySuggestion: String? {
        error?.recoverySuggestion
    }
    
    func clearError() {
        error = nil
        Logger.store.debug("Error cleared")
    }
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading { error = nil }
    }
    
    func setError(_ error: Error) {
        self.error = AppError.from(error)
        isLoading = false
        Logger.store.error("Error set: \(error)")
    }
    
    func setData(_ data: DataType?) {
        self.data = data
        isLoading = false
        error = nil
    }
}
```

**Ventajas:**
- `AnyObject` restringe a clases (compatible con @Observable)
- Default implementations (no duplicar código)
- Sin `mutating` (no son structs)
- Composición sobre herencia

---

## 11. AppError (Errores Tipados)

Errores específicos de dominio:

```swift
import Foundation

enum AppError: Error, LocalizedError {
    case network(String)
    case database(String)
    case notFound
    case parsing(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Error de red: \(message)"
        case .database(let message):
            return "Error de base de datos: \(message)"
        case .notFound:
            return "No se encontraron datos"
        case .parsing(let message):
            return "Error al procesar datos: \(message)"
        case .unknown:
            return "Error desconocido"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network:
            return "Verifica tu conexión a internet e intenta de nuevo"
        case .database:
            return "Intenta reiniciar la aplicación"
        case .notFound:
            return "Intenta refrescar la lista"
        case .parsing:
            return "Contacta con soporte si el problema persiste"
        case .unknown:
            return "Intenta de nuevo más tarde"
        }
    }
    
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .network("No hay conexión a internet")
            case .timedOut:
                return .network("Tiempo de espera agotado")
            default:
                return .network(urlError.localizedDescription)
            }
        }
        
        if error is DecodingError {
            return .parsing("Error al decodificar respuesta del servidor")
        }
        
        return .unknown
    }
}
```

**Características:**
- Mensajes amigables al usuario
- Sugerencias de recuperación
- Conversión desde errores del sistema
- `LocalizedError` para integración con SwiftUI

---

## 12. Vista (SwiftUI)

Consume el Store:

```swift
import SwiftUI

struct GamesListView: View {
    @Environment(\.gamesListStore) private var store
    
    var body: some View {
        NavigationStack {
            Group {
                if let store = store {
                    contentView(store: store)
                } else {
                    LoadingView(message: "Inicializando...")
                }
            }
            .navigationTitle("Juegos")
        }
    }
    
    @ViewBuilder
    private func contentView(store: GamesListStore) -> some View {
        if store.isLoading && store.games.isEmpty {
            LoadingView(message: "Cargando juegos...")
            
        } else if store.games.isEmpty && !store.isLoading {
            ContentUnavailableView(
                "No hay juegos",
                systemImage: "gamecontroller",
                description: Text("Intenta refrescar la lista")
            )
            
        } else {
            List(store.filteredGames) { game in
                GameRowView(game: game)
            }
            .searchable(
                text: Binding(
                    get: { store.searchText },
                    set: { store.searchText = $0 }
                )
            )
            .refreshable {
                await store.refresh()
            }
        }
    }
}
```

**Características:**
- Store inyectado via `@Environment`
- Estados claros (loading, empty, success, error)
- `.searchable()` integrado
- `.refreshable()` para pull-to-refresh
- SwiftUI nativo (sin wrappers)

---

## 13. Configuración en App

Crear e inyectar dependencias:

```swift
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    
    let modelContainer: ModelContainer
    private let gameRepository: GameRepositoryProtocol
    @State private var gamesListStore: GamesListStore?
    
    init() {
        do {
            // 1. SwiftData container
            modelContainer = try ModelContainer(
                for: GameEntity.self,
                     GameDetailEntity.self
            )
            
            // 2. Repository con ModelContext
            gameRepository = GameRepositoryImpl(
                modelContext: modelContainer.mainContext
            )
            
        } catch {
            fatalError("Failed to configure SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(\.gameRepository, gameRepository)
                .environment(\.gamesListStore, gamesListStore)
                .task {
                    // 3. Crear store compartido
                    if gamesListStore == nil {
                        let store = GamesListStore(repository: gameRepository)
                        gamesListStore = store
                        await store.loadGames()
                    }
                }
        }
    }
}
```

**Patrón de inyección:**
- ModelContainer: Singleton para toda la app
- Repository: Singleton (protocolo inyectado)
- GamesListStore: Shared (para preservar estado)
- GameDetailStore: Local (creado en vista)

---

## 14. Environment Keys

Para inyección de dependencias:

```swift
import SwiftUI

// Repository
private struct GameRepositoryKey: EnvironmentKey {
    static let defaultValue: GameRepositoryProtocol? = nil
}

extension EnvironmentValues {
    var gameRepository: GameRepositoryProtocol? {
        get { self[GameRepositoryKey.self] }
        set { self[GameRepositoryKey.self] = newValue }
    }
}

// Store compartido
private struct GamesListStoreKey: EnvironmentKey {
    static let defaultValue: GamesListStore? = nil
}

extension EnvironmentValues {
    var gamesListStore: GamesListStore? {
        get { self[GamesListStoreKey.self] }
        set { self[GamesListStoreKey.self] = newValue }
    }
}
```

---

## Resumen de Flujo Completo

### Primer lanzamiento (con internet):
```
1. Usuario abre app
2. GamesListStore.loadGames()
3. Repository.fetchGames(forceRefresh: false)
4. Repository busca en SwiftData → Vacío
5. Repository llama NetworkManager
6. NetworkManager descarga JSON
7. JSON → [GameDTO]
8. Mapper: [GameDTO] → [Game]
9. Repository guarda [Game] en SwiftData (como [GameEntity])
10. Repository retorna [Game] al Store
11. Store actualiza data → SwiftUI re-renderiza
```

### Segundo lanzamiento (cache válido):
```
1. Usuario abre app
2. GamesListStore.loadGames()
3. Repository.fetchGames(forceRefresh: false)
4. Repository busca en SwiftData → Encuentra datos
5. Repository verifica TTL → Válido (< 24h)
6. Mapper: [GameEntity] → [Game]
7. Repository retorna [Game] al Store (sin red)
8. Store actualiza data → SwiftUI re-renderiza
⚡ Total: < 100ms
```

### Pull-to-refresh:
```
1. Usuario arrastra lista hacia abajo
2. GamesListStore.refresh()
3. Repository.fetchGames(forceRefresh: true)
4. Repository IGNORA cache
5. Repository llama NetworkManager
6. Descarga datos frescos
7. Actualiza cache (upsert)
8. Retorna datos al Store
```

---

## Checklist de Implementación

### ✅ Modelos:
- [ ] Domain Model (struct, Codable, Identifiable)
- [ ] DTO (struct, Codable, snake_case)
- [ ] Entity (@Model, class, metadata)

### ✅ Conversión:
- [ ] Mapper con métodos estáticos
- [ ] DTO → Model
- [ ] Model → Entity
- [ ] Entity → Model

### ✅ Networking:
- [ ] NetworkManager con retry
- [ ] APIEndpoint enum
- [ ] Logging de red

### ✅ Repository:
- [ ] Protocol (Sendable, typed throws)
- [ ] Implementation (@MainActor)
- [ ] fetchFromCache()
- [ ] saveToCache() con upsert
- [ ] isCacheExpired()

### ✅ Store:
- [ ] @Observable @MainActor
- [ ] Conforma ObservableStore
- [ ] loadData(), refresh()
- [ ] Computed properties (filtros, etc.)

### ✅ SwiftData:
- [ ] ModelContainer en App
- [ ] Entities con @Model
- [ ] FetchDescriptor para queries
- [ ] #Predicate para filtros

### ✅ Vista:
- [ ] @Environment para Store/Repository
- [ ] Estados UI (loading, empty, error, success)
- [ ] .refreshable()
- [ ] .searchable() si aplica

### ✅ Errores:
- [ ] AppError enum
- [ ] LocalizedError
- [ ] from() converter
- [ ] Recovery suggestions

---

## Ventajas de esta Arquitectura

### ✅ Thread-Safety
- `@MainActor` en Repository y Stores
- No race conditions con ModelContext

### ✅ Offline-First
- Cache persistente en SwiftData
- TTL configurable
- Funciona sin internet si cache válido

### ✅ Performance
- Carga instantánea desde cache (< 100ms)
- Solo fetches cuando es necesario
- Upsert eficiente (no borra todo)

### ✅ Testabilidad
- Repository como protocolo → Mocks fáciles
- Mappers puros → Unit tests simples
- Stores independientes → Aislables

### ✅ Escalabilidad
- Añadir endpoints → Solo crear DTO + caso en APIEndpoint
- Añadir stores → Reutilizar ObservableStore
- Cambiar BD → Solo cambiar Entities/Repository

### ✅ Mantenibilidad
- Separación clara de responsabilidades
- Código predecible y consistente
- Fácil onboarding de nuevos devs

---

## NO hacer:

- ❌ Usar `@unchecked Sendable` en Repository
- ❌ Acceder a SwiftData desde múltiples threads
- ❌ Borrar todo el cache en cada actualización (usar upsert)
- ❌ Usar `ObservableObject` (usar `@Observable`)
- ❌ Mezclar Domain Models con DTOs o Entities
- ❌ Poner lógica de negocio en las vistas
- ❌ Crear stores en cada vista (usar compartidos cuando tenga sentido)
- ❌ Ignorar errores (siempre manejarlos con AppError)





