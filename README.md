# ♻️ Sistema de Clasificación de Residuos generados en Empresas de Fabricación de Muebles (Frontend)

---

## 💡 Descripción General del Proyecto

El presente proyecto de tesis busca la **implementación de un sistema inteligente** basado en **visión artificial** y **Deep Learning**. Su objetivo principal es mejorar la **clasificación de residuos sólidos** dentro del entorno productivo de una empresa de fabricación de muebles.

Esta solución está orientada a:
* **Optimizar la gestión de residuos**.
* Fomentar la **reutilización de materiales**, especialmente aquellos con valor productivo, como los residuos madereros.
* Contribuir a la **sostenibilidad y eficiencia** operativa de la empresa.

---

## 💻 Acerca de este Repositorio (Frontend)

Este repositorio contiene exclusivamente el **frontend (interfaz de usuario)** del sistema de clasificación. Será el componente final que implementará y consumirá el modelo de clasificación basado en Deep Learning.

### Tecnología

| Aspecto | Detalle |
| :--- | :--- |
| **Framework UI** | **Flutter** |
| **Lenguaje** | **Dart** |
| **Propósito** | Desarrollo de una solución **multiplataforma** para optimizar el tiempo de desarrollo. |

---

## 🎯 Funcionalidades Principales

### 1. **Autenticación de Usuarios**
- Registro de nuevos usuarios con Firebase Authentication
- Inicio de sesión con email y contraseña
- Gestión de sesión y tokens de autenticación
- Protección de rutas con guard de autenticación

### 2. **Clasificación de Residuos con Cámara**
- Captura de imágenes mediante cámara del dispositivo
- Selección de imágenes desde la galería
- Clasificación en tiempo real mediante API de Deep Learning
- Clasificación en dos capas:
  - **Capa 1**: Reciclable / No Reciclable
  - **Capa 2**: Tipo específico (Retazos, Biomasa, Metales, Plásticos)
- Visualización de confianza de la clasificación
- Almacenamiento automático de predicciones en Firestore

### 3. **Dashboard de Estadísticas**
- Visualización de porcentajes de materiales reciclables vs no reciclables (gráfico circular)
- Distribución de residuos por tipo (gráfico de barras)
- Contadores de estadísticas (total procesado, reciclables, no reciclables)
- Medidor de precisión basado en retroalimentación del usuario
- Datos filtrados por empresa

### 4. **Historial de Clasificaciones**
- Lista completa de todas las clasificaciones realizadas
- Visualización de imágenes clasificadas
- Información detallada de cada predicción (tipo, confianza, fecha)
- Actualización mediante pull-to-refresh
- Filtrado por empresa del usuario

### 5. **Perfil de Usuario**
- Visualización y edición de información del perfil
- Actualización de nombre y email
- Cambio entre modo claro/oscuro
- Cierre de sesión con confirmación

### 6. **Temas (Light/Dark Mode)**
- Soporte completo para modo claro y oscuro
- Persistencia de preferencia de tema
- Interfaz adaptativa según el tema seleccionado

---

## 🏗️ Arquitectura del Proyecto

El proyecto sigue una arquitectura limpia y modular:

```
lib/
├── common/              # Componentes y estilos reutilizables
│   ├── styles/         # Estilos de texto y temas
│   └── widgets/        # Widgets comunes (botones, campos de texto, etc.)
├── data/               # Capa de datos
│   ├── models/        # Modelos de datos
│   ├── providers/      # Providers para gestión de estado (Provider pattern)
│   └── services/       # Servicios de negocio (Auth, User, History, Classification, etc.)
├── presentation/       # Capa de presentación (UI)
│   ├── camera_module/ # Pantalla de clasificación con cámara
│   ├── clasif_history/# Pantalla de historial
│   ├── dashboard/      # Pantalla de dashboard
│   ├── login/          # Pantalla de inicio de sesión
│   ├── profile/        # Pantalla de perfil
│   └── signup/         # Pantalla de registro
└── utils/              # Utilidades y constantes
```

### Gestión de Estado

El proyecto utiliza **Provider** para la gestión de estado:
- `AuthProvider`: Estado de autenticación
- `UserProvider`: Datos del usuario actual
- `SettingsProvider`: Configuraciones (tema, idioma)
- `ClassificationProvider`: Estado de clasificaciones e historial
- `DashboardProvider`: Estadísticas del dashboard

### Servicios

- **AuthService**: Manejo de autenticación con Firebase Auth
- **UserService**: Gestión de datos de usuario (Firestore)
- **HistoryService**: Obtención de historial de clasificaciones (Firestore)
- **PredictionService**: Guardado de predicciones en Firestore
- **StorageService**: Almacenamiento local con SharedPreferences
- **ClassificationService**: Comunicación con API de clasificación de imágenes

---

## 🚀 Inicio Rápido

### Prerequisitos

- **Flutter SDK** 3.7.2 o superior
- **Dart SDK** 3.7.2 o superior
- **Firebase project** configurado
- **Cuenta de Azure** (para almacenamiento de imágenes y API de clasificación)

### Configuración de Firebase

**IMPORTANTE:** Este proyecto usa Firebase Authentication y Cloud Firestore. Antes de ejecutar, debes configurar Firebase:

1. **Crea un proyecto Firebase:**
   - Ve a [Firebase Console](https://console.firebase.google.com/)
   - Crea un nuevo proyecto o selecciona uno existente

2. **Configura Firebase para tu plataforma:**
   - **Android:** Descarga `google-services.json` y colócalo en `android/app/`
   - **iOS:** Descarga `GoogleService-Info.plist` y colócalo en `ios/Runner/`
   
3. **Habilita servicios en Firebase:**
   - **Authentication** → Habilitar Email/Password
   - **Cloud Firestore Database** → Crear base de datos en modo de producción o prueba
   - Configura las reglas de seguridad según tus necesidades

4. **Estructura de Firestore:**
   - Colección `users`: Datos de perfil de usuarios
   - Colección `predictions`: Historial de clasificaciones con estructura:
     ```json
     {
       "company": "string",
       "created_at": "timestamp",
       "image_url": "string",
       "model_response": {
         "layer1_result": {...},
         "layer2_result": {...},
         "metadata": {...}
       },
       "user_feedback": {...}
     }
     ```

### Configuración de Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# API de Clasificación de Imágenes (WasteNet)
WFWASTENET_API_BASE_URL=https://tu-api-url.com/api/classify
WFWASTENET_API_BEARER_TOKEN=tu-bearer-token

# Azure Storage (opcional, para imágenes)
AZURE_CONTAINER_SAS_TOKEN=tu-sas-token
```

**Nota:** El archivo `.env` debe estar en `.gitignore` para no exponer credenciales.

### Instalación

1. **Clona el repositorio:**
   ```bash
   git clone <url-del-repositorio>
   cd scrm-frontend
   ```

2. **Instala las dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configura Firebase:**
   - Sigue los pasos de configuración de Firebase mencionados arriba
   - Asegúrate de tener los archivos de configuración en su lugar

4. **Configura variables de entorno:**
   - Crea el archivo `.env` con las variables necesarias

### Ejecutar el Proyecto

```bash
# Ejecutar en dispositivo/emulador
flutter run

# Ejecutar en modo release
flutter run --release

# Ejecutar en dispositivo específico
flutter devices  # Lista dispositivos disponibles
flutter run -d <device-id>
```

---

## 📦 Dependencias Principales

### Core
- **flutter** - Framework UI multiplataforma
- **dart** - Lenguaje de programación

### Firebase
- **firebase_core** (^3.6.0) - Core de Firebase
- **firebase_auth** (^5.3.1) - Autenticación de usuarios
- **cloud_firestore** (^5.4.4) - Base de datos NoSQL en la nube

### Gestión de Estado
- **provider** (^6.1.5+1) - Gestión de estado reactiva

### UI y Gráficos
- **fl_chart** (^1.1.0) - Librería de gráficos (pie charts, bar charts)
- **syncfusion_flutter_gauges** (^31.1.19) - Medidores y gauges

### Cámara e Imágenes
- **camera** (^0.11.2) - Acceso a la cámara del dispositivo
- **image_picker** (^1.2.0) - Selección de imágenes desde galería
- **gal** (^2.3.2) - Acceso a la galería de fotos

### Utilidades
- **shared_preferences** (^2.2.2) - Almacenamiento local persistente
- **http** (^1.6.0) - Cliente HTTP para comunicación con APIs
- **flutter_dotenv** (^6.0.0) - Manejo de variables de entorno

### Desarrollo
- **flutter_lints** (^5.0.0) - Linter para código Dart/Flutter

---

## 🔐 Seguridad

- Las credenciales y tokens se almacenan de forma segura usando `SharedPreferences`
- Las variables de entorno sensibles están en `.env` (excluido de git)
- Firebase Auth maneja la autenticación de forma segura
- Las reglas de Firestore deben configurarse apropiadamente para producción

---

## 📱 Plataformas Soportadas

- ✅ **Android** (completamente soportado)
- ✅ **iOS** (completamente soportado)
- ⚠️ **Web** (configuración básica presente, puede requerir ajustes)

---

## 🧪 Testing

Para ejecutar los tests:

```bash
flutter test
```

---

## 📝 Notas de Desarrollo

### Estructura de Datos

- **Usuario**: Almacenado en Firestore (`users` collection) y Firebase Auth
- **Predicciones**: Almacenadas en Firestore (`predictions` collection) con metadatos completos
- **Configuración**: Almacenada localmente con SharedPreferences

### Flujo de Clasificación

1. Usuario captura/selecciona imagen
2. Imagen se convierte a base64
3. Se envía a API de clasificación (WasteNet)
4. Se recibe resultado con capas de clasificación
5. Resultado se guarda en Firestore
6. Dashboard se actualiza automáticamente

### Temas

El proyecto soporta modo claro y oscuro:
- La preferencia se guarda en SharedPreferences
- Los colores se adaptan automáticamente según el tema
- Los textos y widgets son theme-aware

---

## 🤝 Contribución

Este es un proyecto de tesis. Para contribuciones o preguntas, contactar al autor del proyecto.

---

## 📄 Licencia

Este proyecto es parte de una tesis universitaria. Todos los derechos reservados.

---

## 📧 Contacto

Para más información sobre el proyecto, consultar la documentación de la tesis o contactar al autor.

---

**Última actualización:** 16/11/2025
