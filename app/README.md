# Iron Fiber Gym - Mobile App

Este directorio contiene la aplicación móvil del proyecto **Iron Fiber Gym**, desarrollada con **Flutter**.

---

## 📂 Estructura del Monorepo

El repositorio del proyecto está configurado como un **Monorepo**. Esto significa que tanto el código de la aplicación móvil como otros servicios (como la API de backend) coexisten en el mismo repositorio Git.

La estructura general del repositorio es la siguiente:

```text
iron_fiber_gym/            # Raíz del repositorio Git
├── .github/
│   └── workflows/
│       └── ios-build.yml  # Flujo de GitHub Actions para construir iOS (ejecutado por Builder)
├── api/                   # API / Backend del proyecto
├── app/                   # <-- ESTA CARPETA (Aplicación Móvil en Flutter)
│   ├── assets/            # Recursos estáticos (Logos, imágenes, etc.)
│   ├── lib/               # Código fuente de Flutter (Dart)
│   ├── ios/               # Proyecto nativo de iOS
│   ├── android/           # Proyecto nativo de Android
│   ├── builder.json       # Configuración local de Builder
│   └── pubspec.yaml       # Dependencias y recursos de la app
├── docker-compose.yml     # Orquestación de contenedores del backend
└── .gitignore             # Exclusiones de Git a nivel de raíz
```

> [!IMPORTANT]
> **Contexto de Rutas en Monorepo:**  
> Dado que la raíz de Git está un nivel arriba (`../`), herramientas como GitHub Actions y Git se ejecutan desde la raíz del monorepo. Por ello, la configuración de compilación remota (`builder.json`) debe apuntar la ruta del proyecto nativo de iOS a `"app/ios"` y no simplemente a `"ios"`.

---

## 🛠️ Configuración de Builder e iOS Remoto (GitHub Actions)

Para compilar la aplicación móvil para iOS sin necesidad de contar con una máquina macOS local, utilizamos la herramienta **Builder** integrada con **GitHub Actions**.

### 1. Ubicación del Workflow de GitHub
Para que GitHub reconozca y pueda registrar el flujo de automatización, el archivo de workflow debe residir obligatoriamente en la raíz del repositorio de Git:
- **Ruta:** `.github/workflows/ios-build.yml` (en la raíz del monorepo).

Este archivo ejecuta en la nube (en un entorno virtual `macos-latest` provisto por GitHub Actions) los pasos necesarios para instalar Flutter, resolver las dependencias de CocoaPods y generar el archivo `.ipa`.

### 2. Archivo de Configuración Local (`builder.json`)
El archivo de configuración de la herramienta reside en la carpeta del subproyecto `/app` y le indica a la CLI de Builder a qué repositorio enviar la solicitud de compilación y qué parámetros pasar:
- **Ruta:** `app/builder.json`

Contenido clave:
```json
{
  "project": "app",
  "platform": "ios",
  "github": {
    "owner": "IgmarLozadaBolivar",
    "repo": "iron_fiber_gym"
  },
  "ios": {
    "path": "app/ios"  // Ruta al proyecto iOS relativa a la raíz del monorepo
  },
  "flutter": {
    "version": "3.44.4",
    "watch": {}
  },
  "reactNative": {},
  "mobai": {}
}
```

### 3. Adaptaciones para el Monorepo en el Workflow
El flujo original de GitHub Actions fue personalizado para soportar la estructura de monorepo:
- **Detección Dinámica de la Raíz del Proyecto:** El workflow analiza la ruta `ios_path` enviada por la CLI (ej. `app/ios`), calcula que la raíz de la app es el directorio superior (`app`) y define una variable `PROJECT_ROOT`.
- **Ejecución Contextual:** Los comandos de dependencias (como `flutter pub get`) y la restauración del caché se ejecutan utilizando el `working-directory` de la app (`app`).
- **Zipeado y Exportación Limpia:** La app compilada (`.app`) se traslada a la carpeta temporal `build/` en la raíz de la máquina virtual del runner para empaquetarse en un archivo `.ipa` y ser descargada automáticamente por la CLI en tu carpeta local `dist/`.

---

## 📱 Comandos de Desarrollo (iOS y Android)

Para trabajar localmente en la aplicación móvil, asegúrate de abrir tu terminal y situarte en el subdirectorio `/app` de este monorepo:
```bash
cd app
```

### 1. Instalación de dependencias
Antes de compilar o correr la aplicación por primera vez, instala las dependencias necesarias de Flutter ejecutando:
```bash
flutter pub get
```

### 2. Desarrollo en iOS con MobAI (desde Windows / Linux)
Si estás desarrollando en entornos Windows o Linux, puedes ejecutar, depurar y realizar cambios en tiempo real en un dispositivo iPhone físico siguiendo este procedimiento paso a paso:

#### Paso 1: Preparación del dispositivo y PC
1. **Abrir iTunes:** Inicia iTunes en tu PC con Windows. Esto es indispensable para cargar los controladores USB oficiales de Apple que permiten la comunicación con el dispositivo.
2. **Abrir MobAI:** Inicia la aplicación de MobAI en tu ordenador.
3. **Conectar el iPhone:** Conecta tu iPhone físicamente a la PC usando un cable USB. Realiza el proceso rutinario de desbloquear el dispositivo y seleccionar **"Confiar en este ordenador"** si aparece en pantalla.

#### Paso 2: Generar y firmar el IPA de pruebas
Para ejecutar la app en tu dispositivo, primero necesitas el archivo IPA:
1. **Generar la compilación remota (si no la tienes):**
   ```bash
   builder ios build --unsigned
   ```
   Esto generará el archivo `.ipa` correspondiente en la nube y lo descargará en la carpeta local `dist/`.
2. **Iniciar el modo de desarrollo y firma:**
   ```bash
   builder dev flutter
   ```
3. **Proceso de firma interactivo (Primera vez):**
   - La CLI detectará el archivo `.ipa` en `dist/` y te preguntará si deseas resignarlo para tu dispositivo: selecciona **`Yes`** (Resign: Yes).
   - Introduce tu **Apple ID** (el correo de tu cuenta de Apple).
   - Introduce tu **Contraseña** de Apple (o contraseña específica de aplicación).
   - Espera unos momentos mientras MobAI firma el binario localmente, lo instala en tu iPhone y arranca el depurador.
   - *Nota:* Este proceso generará un nuevo archivo en tu directorio `dist/` que incluye la palabra **`signed`** en su nombre (ej. `dist/app-<build_id>-signed.ipa`).

4. **Ejecuciones posteriores (Optimización de tiempo sin volver a firmar):**
   - Una vez que ya tienes el archivo firmado (`signed`), **no es necesario** repetir los pasos de Apple ID ni reconstruir el IPA remoto si solo estás modificando código Dart (widgets, lógica, etc.).
   - Ejecuta simplemente:
     ```bash
     builder dev flutter
     ```
   - Al listar los archivos, selecciona el IPA que contiene la palabra **`signed`** en su nombre.
   - Cuando te pregunte si deseas resignarlo: selecciona **`No`**.
   - Cuando te pregunte por el **Bundle ID**: presiona simplemente **`Enter`** para utilizar el predeterminado.
   - La app se instalará/abrirá directamente en segundos, manteniendo la sincronización de archivos para el **Hot Reload** y **Hot Restart**. Solo deberás repetir el proceso de firma si cambias código nativo de iOS o expira el perfil de desarrollo personal.

### 3. Desarrollo Estándar (Android / Emuladores)
Para ejecutar la app en un dispositivo Android físico (con depuración USB activa) o en un emulador de Android:
```bash
flutter run
```
Esto compilará la aplicación en modo desarrollo y la desplegará en el emulador o dispositivo Android seleccionado.

---

## 🏗️ Proceso de Compilación (Builds)

Cuando estés listo para generar una versión empaquetada para pruebas (no desarrollo), sigue los flujos correspondientes a cada plataforma.

### 1. Compilación para iOS
Dado que el desarrollo se hace en entornos Windows/Linux, la compilación de iOS se delega al runner de GitHub Actions configurado en la raíz del monorepo.

#### Compilación sin firmar (Unsigned IPA)
Excelente para empaquetar de forma rápida la aplicación para pruebas personales e instalarla mediante cargadores alternativos (como AltStore, Sideloadly o mediante el propio MobAI):
```bash
builder ios build --unsigned
```
- **Resultado:** El binario compilado se descargará de forma automática en tu máquina en `dist/app-<build_id>.ipa`.

---

### 2. Compilación para Android
La compilación para la plataforma de Android se realiza de manera 100% local en tu propia máquina de desarrollo.

#### Compilar un APK de Liberación (Release)
Para empaquetar un archivo instalable en cualquier dispositivo Android físico:
```bash
flutter build apk --release
```
- **Resultado:** El APK se generará en `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🎨 Detalles de UI Recientes (Cambios y Explicación)

Durante las últimas sesiones, implementamos mejoras visuales para crear un diseño más limpio, moderno y adaptado al tema oscuro. A continuación se detallan los componentes clave:

### 1. Integración de Recursos Gráficos y Tipografías
- **Visualización de SVGs (`flutter_svg`):** Incorporamos el paquete `flutter_svg` para renderizar el logotipo vectorial de Iron Fiber Gym (`Logo.svg`). Los gráficos vectoriales mantienen una nitidez perfecta sin importar la densidad de píxeles o la resolución del dispositivo.
- **Tipografía Sora (`google_fonts`):** Se integró la fuente **Sora** para dar una apariencia moderna, robusta y con excelente legibilidad en etiquetas y títulos.

### 2. Estructuración del Tema en `lib/main.dart`
En el archivo principal se aplicaron los siguientes ajustes a la configuración de la app:
- `themeMode: ThemeMode.dark`: Establece que la aplicación use el modo oscuro por defecto.
- `darkTheme` / `theme`: Configura el tema aplicando `GoogleFonts.soraTextTheme` de forma global, asegurando que todos los textos usen la tipografía **Sora** sin tener que especificarla manualmente en cada widget.
- `debugShowCheckedModeBanner: false`: Desactiva el banner rojo de "DEBUG" de la esquina superior derecha para ver la interfaz libre de obstrucciones visuales.

### 3. Barra de Navegación Personalizada en `lib/widgets/app_bar.dart`
El widget `CustomAppBar` fue rediseñado para optimizar el espacio y la composición visual:
- **Cambio de `leading` a `title`:** La propiedad `leading` del `AppBar` está restringida a un ancho máximo por defecto de **56.0 px**. Colocar un `Row` allí con el logo y el texto generaba un error de desbordamiento de diseño. Al migrar esta fila al `title`, se utiliza de manera dinámica el ancho completo disponible.
- **Grupo Logo y Badge:** Se dispusieron juntos mediante un `Row` y un separador `SizedBox(width: 14)`.
- **Badge "ALUMNO":** Diseñamos un indicador de tipo de usuario con fuente **Sora** (tamaño `14`, grosor `w800`), dentro de un contenedor oscuro (`#343B49`) con bordes redondeados y un contorno sutil (`Colors.white12`) para simular relieve y profundidad sobre el fondo negro.
- **Avatar Circular en `actions`:** El avatar se integró en la lista de `actions` y se envolvió en un widget `ClipRRect` con un radio de `18` para volver circular la imagen cuadrada original. Asimismo, se alineó usando un `Padding` lateral de `16` para evitar que la imagen choque con el borde de la pantalla.
