# Socio Infonavit iOS

Aplicación iOS para los socios de Infonavit, desarrollada como prueba técnica.

## 📱 Screenshots

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2026-02-16 at 23 40 09" src="https://github.com/user-attachments/assets/a413d1df-49f3-47d8-9796-1c28c24a46cd" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2026-02-16 at 23 27 25" src="https://github.com/user-attachments/assets/ca7ca6b0-d831-4f76-920d-092442b07f53" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2026-02-16 at 23 28 39" src="https://github.com/user-attachments/assets/a4fa3446-b372-47f5-828c-8ac38f84d59d" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2026-02-17 at 00 07 21" src="https://github.com/user-attachments/assets/7869bd7b-2eb3-42a5-9b0a-f5624d635c13" />


## 🏗️ Arquitectura

- **Patrón:** MVVM (Model - View - ViewModel)
- **UI:** SwiftUI
- **Concurrencia:** async/await 
- **Inyección de dependencias** 


## ✨ Funcionalidades

- [x] Splash Screen con animación
- [x] Login con validación de credenciales
- [x] Encriptación RSA de credenciales
- [x] Grid de Benevits (locked/unlocked)
- [x] Búsqueda con debounce
- [x] Menú lateral (Side Menu)
- [x] Logout con confirmación
- [x] Detección de internet real (NetworkReachability)
- [x] Estados de carga (Skeleton View)
- [x] Estados de error con retry
- [x] Localización (Localizable.strings)
- [x] Tests unitarios (ViewModels + Mock)

## 🧪 Testing

El proyecto incluye tests unitarios con un `MockNetworkService` dedicado:

- **LoginViewModelTests** - Validaciones, login exitoso/fallido, estados
- **BenevitsViewModelTests** - Carga, búsqueda, debounce, errores

### Credenciales de Test (modo Mock)

| Usuario | Contraseña | Resultado |
|---------|------------|-----------|
| 61917612998 | Contrasena01 | ✅ Login exitoso |
| 61998018420 | Contrasena02 | ✅ Login exitoso |
| 61900000000 | ServerError | 🔴 Error 500 |
| 61911111111 | SlowNetwork | 🐌 Delay 3.5s |
| 61922222222 | Timeout | ⏱️ Timeout |
| Cualquier otro | Cualquier otra | ❌ Credenciales incorrectas |

## 🛠️ Tecnologías

| Tecnología | Uso |
|------------|-----|
| SwiftUI | UI declarativa |
| async/await | Concurrencia |
| XCTest | Tests unitarios |
| Network.framework | Detección de internet |
| Security.framework | Encriptación RSA |
| NSLocalizedString | Localización |

## 📋 Requisitos

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Instalación

```bash
# Clonar repositorio
https://github.com/luisvicente2021/socio-infonavit-ios.git

# Abrir en Xcode
cd socio-infonavit-ios
open SocioInfonavit.xcodeproj
```

## ⚙️ Configuración

### Modo Mock (desarrollo)
```swift
// NetworkConfiguration.swift
static let useMockData: Bool = true
```

### Modo Real (producción)
```swift
static let useMockData: Bool = false
```

## 👨‍💻 Autor

**[Luis Angel Vicente]**

_Desarrollado como prueba técnica para vacante iOS Developer_

## ⚙️ Configuración

### Cambiar entre Mock y Producción

En `NetworkConfiguration.swift`:

```swift
// Desarrollo (Mock)
static let useMockData: Bool = true

// Producción (API Real)
static let useMockData: Bool = false
```

## 🔑 Credenciales de Testing

> Solo aplican cuando `useMockData = true`

| Escenario | Usuario | Contraseña | Resultado |
|-----------|---------|------------|-----------|
| ✅ Login exitoso | 61917612998 | Contrasena01 | Accede a Home |
| ✅ Login exitoso | 61998018420 | Contrasena02 | Accede a Home |
| ❌ Credenciales incorrectas | cualquiera | cualquiera | Error 401 |
| 🔴 Error de servidor | 61900000000 | ServerError | Error 500 |
| ⏱️ Timeout | 61922222222 | Timeout0000 | Error timeout |
| 📡 Sin internet | — | — | Desactiva WiFi en el dispositivo |

> **Nota:** La detección de internet es **REAL** usando `NWPathMonitor`, no simulada.


