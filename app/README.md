# 🏗️ Construcciones Nexus — App de ejemplo

Landing page corporativa de **Construcciones Nexus**, una empresa ficticia de
construcción e ingeniería civil. Es el contenido de ejemplo de la plantilla
[`angular-aws-static-hosting`](../README.md): una SPA en Angular 100%
estática, sin backend ni llamadas de red en tiempo de ejecución (salvo la
carga de Google Fonts), pensada para ser sustituida por tu propia aplicación
sin tocar la infraestructura de Terraform en [`infrastructure/`](../infrastructure).

---

## ✨ Funcionalidades

- 🧭 **5 rutas** con Angular Router: Inicio, Servicios, Proyectos, Nosotros y Contacto — pensadas para demostrar el fix de SPA routing en CloudFront.
- 📊 **Contador de estadísticas animado**, activado con `IntersectionObserver` al hacer scroll.
- 🎬 **Animaciones de aparición** (fade + slide) al entrar cada sección en el viewport.
- 🗂️ **Filtro de proyectos por categoría**, con estado reactivo basado en Signals.
- 📝 **Formulario de contacto con Reactive Forms**, validación completa (requerido, email, longitud mínima) y estado de éxito simulado — sin backend.
- 📱 **Diseño responsive** mobile-first, con menú de navegación colapsable.

---

## 🧱 Stack

Angular 22 · Componentes **standalone** (sin NgModules) · Signals · Reactive Forms · SCSS con design tokens · Sin frameworks CSS ni librerías de iconos externas.

---

## 📁 Estructura

```
src/app/
├── core/layout/          # 🧩 Header y footer, compartidos por todas las páginas
├── shared/
│   ├── icon/               # 🖼️ Componente de iconos SVG en línea
│   ├── scroll-reveal.directive.ts   # 🎬 Animación de aparición al hacer scroll
│   ├── stat-counter/        # 📊 Contador animado
│   └── data/                # 🗃️ Datos de contenido (servicios, proyectos, equipo)
└── pages/
    ├── home/
    ├── servicios/
    ├── proyectos/
    ├── nosotros/
    └── contacto/
```

---

## 💻 Cómo ejecutar en local

```bash
npm install
npm start        # ng serve → http://localhost:4200
npm run build     # build de producción en dist/app
npm test           # tests unitarios (vitest)
```

---

## 🔁 Sustituir esta app por la tuya

Esta carpeta está pensada para ser reemplazada sin tocar `infrastructure/`:

1. 🗑️ Sustituye el contenido de `app/` por tu propio proyecto Angular (puedes generarlo con `ng new` en esta misma carpeta).
2. 📦 Asegúrate de que tu app compila a una carpeta `dist/<nombre>/browser` (o ajusta la ruta en `.github/workflows/deploy.yml` y en la variable `build_output_path` de `infrastructure/environments/prod`).
3. 🧭 Si tu app usa Angular Router con rutas del lado del cliente, no necesitas cambiar nada en la infraestructura: CloudFront ya redirige los errores 403/404 a `/index.html` con código 200 para que el enrutamiento funcione al recargar o enlazar directamente a una ruta interna.

---

## 📫 Más información

Ver el [README general del repositorio](../README.md) para la arquitectura completa y cómo desplegar la infraestructura en AWS.
