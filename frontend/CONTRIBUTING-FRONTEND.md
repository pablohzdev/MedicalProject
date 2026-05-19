
# 🎨 Guía del Equipo 2 — Frontend y Conexión

**Integrantes:** Juan y Sergio
**Rama de trabajo:** `frontend/...`

← Volver al índice: [`CONTRIBUTING.md`](./CONTRIBUTING.md)

---

## Índice

1. [Tus archivos](#1-tus-archivos)
2. [Cómo arrancar sin Docker](#2-cómo-arrancar-sin-docker)
3. [Flujo de trabajo con Git](#3-flujo-de-trabajo-con-git)
4. [Convención de commits](#4-convención-de-commits)
5. [Pull Requests](#5-pull-requests)
6. [Reglas del frontend](#6-reglas-del-frontend)
7. [Pantallas que debes implementar](#7-pantallas-que-debes-implementar)
8. [Referencia rápida de la API](#8-referencia-rápida-de-la-api)

---

## 1. Tus archivos

```
proyecto-db/
└──frontend/
    ├── CONTRIBUTING-FRONTEND.md
    ├── index.html
    ├── tailwind.config.js
    └── src/
        ├── js/
        │   ├── components/
        │   │   ├── alerts.js
        │   │   └── navbar.js
        │   └── services/
        │       ├── api.js
        │       └── websocket.js
        └── views/
            ├── altapaciente.html
            ├── consulta.html
            ├── historial.html
            ├── login.html
            └── navbar.html
```




No toques archivos fuera de `frontend/` sin coordinarlo con el Equipo 1.

---

## 2. Cómo arrancar sin Docker

Para desarrollar con **Live Server** no necesitas levantar Docker completo, pero la API sí debe estar corriendo:

```bash
# Desde la raíz del proyecto, levantar solo el backend y la DB
docker compose up db api

# Luego en VS Code:
# Click derecho sobre frontend/index.html → Open with Live Server
# El frontend estará en: http://127.0.0.1:5500
```

> Cuando uses Live Server, la `API_URL` en `api.js` sigue siendo `http://localhost:8000` — no cambia.

---

## 3. Flujo de trabajo con Git

```bash
# Siempre partir de main actualizado
git checkout main
git pull origin main

# Crear rama con prefijo frontend/
git checkout -b frontend/nombre-de-la-tarea

# Ejemplos de nombres de rama
frontend/login-simulado
frontend/dashboard-pacientes
frontend/historial-consulta
frontend/modal-alerta-medica
frontend/buscador-pacientes
```

```bash
# Subir cambios
git add .
git commit -m "feat(frontend): agregar buscador por nombre en dashboard"
git push origin frontend/nombre-de-la-tarea
```

---

## 4. Convención de commits

Formato: `tipo(área): descripción en minúsculas`

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva pantalla, componente o funcionalidad visual |
| `fix` | Corrección de un bug |
| `style` | Cambios de Tailwind o CSS sin tocar lógica JS |
| `refactor` | Reorganizar código sin cambiar comportamiento |
| `docs` | Documentación |

### Ejemplos correctos

```bash
git commit -m "feat(frontend): implementar pantalla de login con select de médicos"
git commit -m "feat(frontend): agregar tabla de pacientes con datos de la API"
git commit -m "feat(ws): iniciar websocket en dashboard y reconectar automáticamente"
git commit -m "fix(frontend): corregir lectura de pacienteId desde URLSearchParams"
git commit -m "style(frontend): ajustar colores del modal de alerta a rojo-600"
```

### Ejemplos incorrectos ❌

```bash
git commit -m "cambios html"
git commit -m "arreglé el login"
git commit -m "estilos"
```

---

## 5. Pull Requests

### Proceso

1. Termina tu trabajo en `frontend/...`
2. Abre un PR en GitHub apuntando a `main`
3. Llena la plantilla de descripción
4. Asigna como revisor al otro integrante del Equipo 2
5. Haz merge una vez aprobado

### Plantilla

```markdown
## ¿Qué hace este PR?
Descripción breve del cambio.

## ¿Cómo probarlo?
1. `docker compose up --build`
2. Abrir http://localhost:3000
3. Verificar que...

## Checklist
- [ ] La pantalla se ve correcta en http://localhost:3000
- [ ] No hay `console.log` de debug olvidados
- [ ] El WebSocket actualiza la vista sin recargar la página
- [ ] Los errores 400 muestran el modal de alerta (no un `alert()`)
- [ ] El diseño es responsivo
```

---

## 6. Reglas del frontend

Estas reglas no son opcionales.

**❌ No uses `alert()`** para mostrar errores. Usa siempre el modal de alerta médica.

**❌ No uses `location.reload()`** para actualizar datos. El WebSocket se encarga de eso.

**❌ No hardcodees datos** de pacientes, médicos o consultas. Todo viene de la API.

**✅ Usa siempre `fetchData()` y `postData()`** de `api.js`. No escribas `fetch()` directamente en `dashboard.js` o `historial.js`.

**✅ Protege todas las páginas privadas** con esta verificación al inicio del JS:

```js
if (!localStorage.getItem('medicoId')) {
  window.location.href = 'index.html';
}
```

**✅ El WebSocket va al final del JS de cada página**, una sola vez:

```js
// Al final de dashboard.js
iniciarWebSocket(() => cargarPacientes());

// Al final de historial.js
iniciarWebSocket(() => cargarHistorial(pacienteId));
```

---

## 7. Pantallas que debes implementar

### Login — `index.html`

- `<select>` con los médicos (consúltale al Equipo 1 qué IDs usar o pídeles el endpoint)
- Botón **Entrar** que guarda el ID en `localStorage` y redirige a `dashboard.html`
- Si ya hay sesión activa, redirigir directo al dashboard

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

### Dashboard — `dashboard.html`

- Tabla con todos los pacientes desde `GET /pacientes`
- Buscador por nombre filtrado en el cliente (sin llamadas extra a la API)
- Click en un paciente → `historial.html?pacienteId=<id>`
- Botón **Cerrar sesión** que limpia `localStorage` y vuelve al login
- WebSocket activo → al recibir `"refresh_data"` volver a llamar `GET /pacientes`

### Historial — `historial.html`

- Leer el ID del paciente con `new URLSearchParams(window.location.search).get('pacienteId')`
- Cabecera con nombre y datos del paciente desde `GET /pacientes/{id}`
- Lista de consultas y tratamientos previos
- Formulario con: **Medicamento**, **Dosis**, **Duración (días)**
- Al enviar: `postData('/consultas', datos)`
  - Éxito → limpiar el formulario (el WebSocket actualiza la lista)
  - Error 400 → mostrar modal de alerta médica con el mensaje exacto del servidor
- WebSocket activo → al recibir `"refresh_data"` recargar el historial

### Modal de alerta médica (va en `historial.html` y cualquier página con POST)

```html
<!-- Pegar antes del </body> -->
<div id="modal-alerta" class="hidden fixed inset-0 bg-black/50 flex items-center justify-center z-50">
  <div class="bg-white border-2 border-red-500 rounded-xl p-6 max-w-md w-full shadow-2xl">
    <div class="flex items-center gap-3 mb-4">
      <span class="text-3xl">⚠️</span>
      <h2 class="text-red-600 font-bold text-lg">Alerta Médica</h2>
    </div>
    <p id="modal-alerta-texto" class="text-gray-800 mb-6"></p>
    <button onclick="cerrarAlerta()"
      class="w-full bg-red-600 text-white font-semibold py-2 rounded-lg hover:bg-red-700 transition">
      Entendido
    </button>
  </div>
</div>
```

---

## 8. Referencia rápida de la API

> Documentación completa e interactiva en **http://localhost:8000/docs**

| Método | Endpoint | Para qué |
|---|---|---|
| `GET` | `/pacientes` | Lista de todos los pacientes |
| `GET` | `/pacientes/{id}` | Datos de un paciente específico |
| `GET` | `/pacientes/{id}/historial` | Consultas y tratamientos del paciente |
| `POST` | `/consultas` | Registrar un nuevo tratamiento |
| `WS` | `ws://localhost:8000/ws` | Escuchar cambios en tiempo real |

### Body esperado por `POST /consultas`

```json
{
  "paciente_id": 1,
  "medico_id": 2,
  "medicamento": "Ibuprofeno",
  "dosis": "400mg",
  "duracion_dias": 5
}
```

> Si la API responde `400`, el campo `detail` contiene el mensaje del Trigger. Muéstralo en el modal.


## 9. Estilos y diseño

- Paleta de colores: blancos, grises neutros y azules médicos (`blue-600`, `blue-800`, `slate-*`)
- Tipografía legible y de buen tamaño — los datos clínicos deben leerse sin esfuerzo
- Diseño responsivo (que funcione en tablet y desktop mínimo)
- Las alertas médicas (errores 400) **siempre** en rojo y con modal, nunca con `alert()` del navegador
- Referencia visual: usar Google Stitch para el diseño inicia