# 🏥 Frontend — Sistema de Alertas Clínicas

Guía técnica para el equipo de desarrollo frontend. Léela completa antes de escribir una sola línea de código.

---

## Índice

1. [Stack y herramientas](#1-stack-y-herramientas)
2. [Reglas que no se negocian](#2-reglas-que-no-se-negocian)
3. [Cómo arrancar el proyecto](#3-cómo-arrancar-el-proyecto)
4. [Sistema de login simulado](#4-sistema-de-login-simulado)
5. [Comunicación con la API](#5-comunicación-con-la-api)
6. [WebSockets — sincronización en tiempo real](#6-websockets--sincronización-en-tiempo-real)
7. [Manejo de errores y alertas del Trigger](#7-manejo-de-errores-y-alertas-del-trigger)
8. [Pantallas requeridas](#8-pantallas-requeridas)
9. [Estilos y diseño](#9-estilos-y-diseño)

---

## 1. Stack y herramientas

| Tecnología | Uso |
|---|---|
| HTML + JavaScript (vanilla) | Estructura y lógica de la UI |
| Tailwind CSS v4 | Estilos |
| Live Server (VS Code) | Servidor de desarrollo local |
| nginx (Docker) | Servidor en producción / Docker Compose |
| `fetch` nativo | Peticiones HTTP a la API |
| `WebSocket` nativo | Escuchar cambios en tiempo real |

> No se instala ninguna librería externa de JS. Todo lo que necesitas ya está en el navegador.

---

## 2. Reglas que no se negocian

### ❌ El frontend NO guarda estado permanente
Toda la información que se muestra en pantalla debe venir de un `GET` a la API. No inventes datos, no los hardcodees, no los guardes en variables globales entre sesiones.

### ✅ Sincronización vía WebSocket
Cuando el backend emita un mensaje `"refresh_data"` por el WebSocket, el frontend debe volver a llamar a los endpoints `GET` correspondientes y actualizar la vista **sin recargar la página** (`location.reload()` está prohibido salvo en reconexión).

### ✅ Mostrar el mensaje exacto del servidor en errores 400
Los errores `400 Bad Request` son alertas generadas por Triggers de la base de datos. El mensaje que viene en `result.detail` debe mostrarse tal cual al usuario, sin modificarlo.

---

## 3. Cómo arrancar el proyecto

```bash
# 1. Clonar el repositorio (si aplica)
git clone <url-del-repo>

# 2. Levantar todos los servicios con Docker
docker compose up --build

# 3. Abrir el frontend
# El frontend estará disponible en: http://localhost:3000
# La API estará en:                 http://localhost:8000
```

Para desarrollo con **Live Server** (sin Docker):
1. Abre la carpeta `/frontend` en VS Code.
2. Click derecho sobre `index.html` → **Open with Live Server**.
3. Asegúrate de que la API esté corriendo en `http://localhost:8000`.

---

## 4. Sistema de login simulado

El login **no tiene autenticación real**. Es un selector de médico que guarda el ID en `localStorage`.

### Flujo completo

```
Usuario abre la app
        │
        ▼
¿Existe localStorage['medicoId']?
   │                    │
  SÍ                   NO
   │                    │
   ▼                    ▼
Ir al Dashboard    Mostrar pantalla de Login
                        │
                        ▼
                Usuario selecciona su nombre
                y presiona "Entrar"
                        │
                        ▼
                localStorage.setItem('medicoId', id)
                        │
                        ▼
                Redirigir al Dashboard
```

### Implementación del login

```js
// login.js

const medicos = [
  { id: 1, nombre: "Dra. García" },
  { id: 2, nombre: "Dr. Martínez" },
  { id: 3, nombre: "Dra. López" },
  // Agregar los que defina el backend
];

function iniciarSesion() {
  const select = document.getElementById('select-medico');
  const medicoId = select.value;

  if (!medicoId) {
    alert("Selecciona un médico para continuar.");
    return;
  }

  localStorage.setItem('medicoId', medicoId);
  window.location.href = 'dashboard.html';
}

function cerrarSesion() {
  localStorage.clear();
  window.location.href = 'index.html';
}
```

### Proteger páginas privadas

Agrega esto al inicio de `dashboard.js` e `historial.js`:

```js
// Verificar sesión activa
if (!localStorage.getItem('medicoId')) {
  window.location.href = 'index.html';
}
```

---

## 5. Comunicación con la API

Usa estas dos funciones genéricas para **todas** las peticiones. No escribas `fetch` directamente en otro lugar.

```js
// api.js — importar en todas las páginas

const API_URL = "http://localhost:8000";

/**
 * GET — Obtener datos del servidor
 * @param {string} endpoint - Ej: '/pacientes' o '/pacientes/5/historial'
 * @returns {Promise<any>} Los datos JSON de la respuesta
 */
async function fetchData(endpoint) {
  const response = await fetch(`${API_URL}${endpoint}`);

  if (!response.ok) {
    throw new Error(`Error ${response.status} al obtener ${endpoint}`);
  }

  return await response.json();
}

/**
 * POST — Enviar datos al servidor
 * @param {string} endpoint - Ej: '/consultas'
 * @param {object} data - Objeto con los datos a enviar
 * @returns {Promise<any|null>} Los datos de la respuesta, o null si hubo alerta médica
 */
async function postData(endpoint, data) {
  const response = await fetch(`${API_URL}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });

  const result = await response.json();

  if (response.status === 400) {
    // Alerta generada por un Trigger de la DB — mostrar mensaje exacto
    mostrarAlertaMedica(result.detail);
    return null;
  }

  if (!response.ok) {
    throw new Error(`Error inesperado ${response.status}`);
  }

  return result;
}
```

### Ejemplo de uso en el dashboard

```js
// Cargar lista de pacientes al iniciar
async function cargarPacientes() {
  try {
    const pacientes = await fetchData('/pacientes');
    renderizarTablaPacientes(pacientes);
  } catch (error) {
    console.error("No se pudo cargar la lista de pacientes:", error);
  }
}

// Registrar un tratamiento nuevo
async function registrarTratamiento(event) {
  event.preventDefault();

  const medicoId = localStorage.getItem('medicoId');
  const datos = {
    paciente_id: obtenerIdPacienteActual(),
    medico_id: Number(medicoId),
    medicamento: document.getElementById('medicamento').value,
    dosis: document.getElementById('dosis').value,
    duracion_dias: Number(document.getElementById('duracion').value),
  };

  const resultado = await postData('/consultas', datos);

  if (resultado) {
    // Éxito — limpiar formulario (el WebSocket actualizará la lista)
    event.target.reset();
  }
  // Si resultado es null, postData ya mostró la alerta médica
}
```

---

## 6. WebSockets — sincronización en tiempo real

El WebSocket escucha cambios en la base de datos y ordena al frontend que recargue los datos sin refrescar la página. Inicialízalo **una sola vez** por página.

```js
// websocket.js

let socket;

/**
 * Iniciar conexión WebSocket
 * @param {Function} onRefresh - Función a ejecutar cuando llegue "refresh_data"
 */
function iniciarWebSocket(onRefresh) {
  socket = new WebSocket('ws://localhost:8000/ws');

  socket.onopen = () => {
    console.log("WebSocket conectado ✅");
  };

  socket.onmessage = (event) => {
    if (event.data === "refresh_data") {
      console.log("Cambio en la DB detectado — actualizando vista...");
      onRefresh(); // Llama a la función que recarga los datos de la página
    }
  };

  socket.onclose = () => {
    console.warn("WebSocket cerrado. Reintentando en 5s...");
    setTimeout(() => iniciarWebSocket(onRefresh), 5000); // Reconexión automática
  };

  socket.onerror = (error) => {
    console.error("Error en WebSocket:", error);
  };
}
```

### Cómo usarlo en cada página

```js
// Al final de dashboard.js
iniciarWebSocket(() => {
  cargarPacientes(); // Se vuelve a pedir la lista actualizada
});

// Al final de historial.js
iniciarWebSocket(() => {
  cargarHistorial(pacienteId); // Se recarga el historial del paciente actual
});
```

---

## 7. Manejo de errores y alertas del Trigger

Cuando el backend responde con `400`, significa que un **Trigger de la base de datos** bloqueó la operación (por ejemplo: medicamento contraindicado, dosis peligrosa, etc.).

El mensaje debe mostrarse de forma **prominente y clara**.

```js
/**
 * Mostrar alerta médica crítica
 * Reemplaza el alert() nativo por un modal visible
 */
function mostrarAlertaMedica(mensaje) {
  const modal = document.getElementById('modal-alerta');
  const texto = document.getElementById('modal-alerta-texto');

  texto.textContent = mensaje;
  modal.classList.remove('hidden'); // Tailwind: quitar 'hidden' para mostrar
}

function cerrarAlerta() {
  document.getElementById('modal-alerta').classList.add('hidden');
}
```

### HTML del modal (agregar en todas las páginas que usen POST)

```html
<!-- Modal de alerta médica — va antes del </body> -->
<div id="modal-alerta" class="hidden fixed inset-0 bg-black/50 flex items-center justify-center z-50">
  <div class="bg-white border-2 border-red-500 rounded-xl p-6 max-w-md w-full shadow-2xl">
    <div class="flex items-center gap-3 mb-4">
      <span class="text-3xl">⚠️</span>
      <h2 class="text-red-600 font-bold text-lg">Alerta Médica</h2>
    </div>
    <p id="modal-alerta-texto" class="text-gray-800 mb-6"></p>
    <button
      onclick="cerrarAlerta()"
      class="w-full bg-red-600 text-white font-semibold py-2 rounded-lg hover:bg-red-700 transition">
      Entendido
    </button>
  </div>
</div>
```

---

## 8. Pantallas requeridas

### Pantalla 1 — Login (`index.html`)

- `<select>` con la lista de médicos
- Botón **Entrar**
- Al hacer clic: guardar `medicoId` en `localStorage` y redirigir al dashboard

### Pantalla 2 — Dashboard de pacientes (`dashboard.html`)

- Tabla con todos los pacientes obtenidos desde `GET /pacientes`
- Buscador por nombre (filtrado en el cliente, sin llamada extra a la API)
- Al hacer clic en un paciente: redirigir a `historial.html?pacienteId=<id>`
- Botón **Cerrar sesión**
- WebSocket activo que recargue la tabla al recibir `refresh_data`

### Pantalla 3 — Historial y nueva consulta (`historial.html`)

- Leer `?pacienteId=<id>` de la URL con `URLSearchParams`
- Cabecera con datos del paciente desde `GET /pacientes/{id}`
- Lista de consultas y tratamientos previos
- Formulario con los campos:
  - Medicamento (texto)
  - Dosis (texto)
  - Duración en días (número)
- Al enviar: llamar a `postData('/consultas', datos)`
  - Si es exitoso: limpiar el formulario (el WebSocket actualizará la lista)
  - Si es `400`: mostrar modal de alerta médica
- WebSocket activo que recargue el historial al recibir `refresh_data`

---

## 9. Estilos y diseño

- Paleta de colores: blancos, grises neutros y azules médicos (`blue-600`, `blue-800`, `slate-*`)
- Tipografía legible y de buen tamaño — los datos clínicos deben leerse sin esfuerzo
- Diseño responsivo (que funcione en tablet y desktop mínimo)
- Las alertas médicas (errores 400) **siempre** en rojo y con modal, nunca con `alert()` del navegador
- Referencia visual: usar Google Stitch para el diseño inicial y traducirlo a Tailwind

---

> Ante cualquier duda sobre un endpoint o el formato de los datos que devuelve la API, consulta la documentación automática en **http://localhost:8000/docs** (Swagger UI generado por FastAPI).