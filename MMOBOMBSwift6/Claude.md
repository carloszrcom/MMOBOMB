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






