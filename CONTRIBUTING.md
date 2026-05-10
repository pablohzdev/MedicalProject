# 🤝 Guía de Contribución — Sistema de Alertas Clínicas

Este documento define las reglas de trabajo en equipo. Todos los integrantes deben leerlo y respetarlo antes de hacer su primer commit.

---

## Índice

1. [Stack actualizado (Mayo 2026)](#1-stack-actualizado-mayo-2026)
2. [Requisitos previos](#2-requisitos-previos)
3. [Cómo configurar el entorno local](#3-cómo-configurar-el-entorno-local)
4. [Flujo de trabajo con Git](#4-flujo-de-trabajo-con-git)
5. [Convención de commits](#5-convención-de-commits)
6. [Pull Requests](#6-pull-requests)
7. [Estructura del proyecto](#7-estructura-del-proyecto)
8. [Responsabilidades por rol](#8-responsabilidades-por-rol)
9. [Reglas generales](#9-reglas-generales)

---

## 1. Stack actualizado (Mayo 2026)

| Tecnología | Versión correcta (Mayo 2026) | Notas |
|---|---|---|---|
| PostgreSQL | **18-alpine** |
| Python | **3.13** |
| FastAPI | **0.136.x** | Instalar desde `requirements.txt` |
| Nginx | **1.30.0-alpine** | Rama stable de Docker Hub |
| Tailwind CSS | **4.x**  |
| Docker Compose | **v2** |

> El `docker-compose.yml` y el `Dockerfile` del repositorio ya reflejan estas versiones. **No las cambies sin consultar al líder técnico.**

---

## 2. Requisitos previos

Instala estas herramientas antes de clonar el repositorio:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (incluye Docker Compose v2)
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) con las extensiones:
  - **Python** (Microsoft)
  - **Pylance**
  - **Docker**
  - **Live Server** (para desarrollo frontend sin Docker)
  - **Tailwind CSS IntelliSense**

---

## 3. Cómo configurar el entorno local

### Clonar e iniciar el proyecto

```bash
git clone <url-del-repositorio>
cd proyecto-db
docker compose up --build
```

Una vez levantado:

| Servicio | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API (FastAPI) | http://localhost:8000 |
| Docs automáticas (Swagger) | http://localhost:8000/docs |
| Base de datos | `localhost:5432` (usuario: `admin`, pass: `password123`, db: `clinica_db`) |

### Entorno virtual de Python (solo para desarrollo backend local)

El backend corre dentro de Docker, pero para que VS Code no muestre errores de importación debes tener un entorno virtual local con las dependencias instaladas:

```bash
cd backend
python3 -m venv .venv

# Mac / Linux
source .venv/bin/activate

# Windows
.venv\Scripts\activate

pip install -r requirements.txt
```

Luego en VS Code: `Ctrl+Shift+P` → **Python: Select Interpreter** → seleccionar `.venv`.

> Esto es solo para el editor. El código siempre se ejecuta dentro del contenedor Docker, no en el `.venv`.

### Verificar que todo funciona

```bash
# La API responde
curl http://localhost:8000/docs

# La base de datos está activa
docker compose ps
```

---

## 4. Flujo de trabajo con Git

Somos 6 personas divididas en 3 equipos. Usamos **ramas por equipo + feature**. Nunca se trabaja directamente sobre `main`.

### Ramas principales

| Rama | Quién la mantiene | Uso |
|---|---|---|
| `main` | Todo el equipo | Código estable y revisado. Solo recibe merges desde PRs aprobados. |
| `db/...` | Equipo 1 (Carrasco y Pablo) | Trabajo de base de datos y backend |
| `frontend/...` | Equipo 2 (Juan y Sergio) | Trabajo de UI y conexión con la API |
| `qa/...` | Equipo 3 (Walas y Alejandro) | Seeding, QA y documentación |

### Crear una rama nueva

```bash
# Asegúrate de estar actualizado antes de ramificar
git checkout main
git pull origin main

# Crear y cambiar a la nueva rama según tu equipo
git checkout -b db/trigger-alertas        # Equipo 1
git checkout -b frontend/tabla-pacientes  # Equipo 2
git checkout -b qa/seeding-inicial        # Equipo 3
```

### Nomenclatura de ramas

```
# Equipo 1 — Base de datos y Backend
db/schema-inicial
db/trigger-tratamiento-repetido
db/endpoint-historial
db/websocket-notify

# Equipo 2 — Frontend y Conexión
frontend/login-simulado
frontend/dashboard-pacientes
frontend/historial-consulta
frontend/modal-alerta-medica

# Equipo 3 — QA y Documentación
qa/seeding-pacientes
qa/validacion-triggers
qa/manual-despliegue

# Cualquier equipo
fix/descripcion-del-bug
```

### Subir cambios

```bash
git add .
git commit -m "feat(db): crear trigger de alerta por tratamiento repetido"
git push origin db/trigger-alertas
```

---

## 5. Convención de commits

Usamos **Conventional Commits**. El formato es:

```
<tipo>(<área>): <descripción corta en minúsculas>
```

### Tipos válidos

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de un bug |
| `docs` | Cambios en documentación (README, CONTRIBUTING, etc.) |
| `style` | Cambios de formato o estilos visuales (sin lógica) |
| `refactor` | Refactorización de código sin cambiar comportamiento |
| `db` | Cambios en SQL: esquema, triggers, seeding |
| `chore` | Tareas de configuración (Docker, dependencias, etc.) |

### Áreas sugeridas

`frontend`, `backend`, `db`, `docker`, `api`, `ws` (websocket)

### Ejemplos correctos

```bash
git commit -m "feat(backend): agregar endpoint GET /pacientes/{id}"
git commit -m "feat(db): crear trigger de alerta por tratamiento repetido"
git commit -m "fix(frontend): corregir reconexión automática del WebSocket"
git commit -m "docs: actualizar CONTRIBUTING con versiones 2026"
git commit -m "chore(docker): actualizar imagen postgres a 18-alpine"
```

### Ejemplos incorrectos ❌

```bash
git commit -m "cambios"
git commit -m "arreglé cosas"
git commit -m "WIP"
git commit -m "Subiendo archivos"
```

---

## 6. Pull Requests

Todo cambio llega a `main` mediante un **Pull Request**. No se hace push directo a `main`.

### Proceso

1. Termina tu trabajo en la rama de tu equipo (`db/...`, `frontend/...`, `qa/...`)
2. Abre un PR en GitHub apuntando a `main`
3. Completa la descripción del PR (ver plantilla abajo)
4. Asigna como revisor a **alguien de otro equipo** — el que más entienda el área
   - PRs de `db/...` → revisor del Equipo 1
   - PRs de `frontend/...` → revisor del Equipo 2
   - PRs de `qa/...` → cualquier integrante disponible
5. El autor del PR hace el merge una vez aprobado

### Plantilla de descripción del PR

```markdown
## ¿Qué hace este PR?
Breve descripción de los cambios.

## ¿Cómo probarlo?
Pasos para verificar que funciona correctamente.

## Checklist
- [ ] El código corre con `docker compose up --build` sin errores
- [ ] Los endpoints nuevos aparecen en http://localhost:8000/docs
- [ ] El frontend se ve correcto en http://localhost:3000
- [ ] No hay `console.log` de debug olvidados
- [ ] No hay credenciales ni contraseñas hardcodeadas fuera del `docker-compose.yml`
```

### Reglas del revisor

- Aprueba si el código funciona y sigue las convenciones de este documento.
- Deja comentarios específicos y constructivos, no solo "está mal".
- No apruebes un PR que no hayas probado localmente.

---

## 7. Estructura del proyecto

```
proyecto-db/
├── docker-compose.yml          # Orquestación de servicios
├── CONTRIBUTING.md             # Este archivo
├── backend/
│   ├── main.py                 # API FastAPI + WebSockets
│   ├── requirements.txt        # Dependencias Python
│   └── Dockerfile              # Imagen del backend
├── frontend/
│   ├── index.html              # Login
│   ├── dashboard.html          # Panel de pacientes
│   ├── historial.html          # Historial y nueva consulta
│   ├── api.js                  # Funciones fetch reutilizables
│   └── websocket.js            # Lógica de WebSocket
└── init-db/
    ├── 01_schema.sql           # Definición de tablas
    ├── 02_triggers.sql         # Triggers y funciones PL/pgSQL
    └── 03_seeding.sql          # Datos ficticios para pruebas
```

> Los archivos de `init-db/` se ejecutan automáticamente al levantar el contenedor de PostgreSQL por primera vez, en orden numérico.

---

## 8. Responsabilidades por rol

### 🗄️ Equipo 1 — Base de Datos y Backend · `Carrasco` y `Pablo`

- Esquema de la base de datos (`01_schema.sql`)
- Triggers y lógica PL/pgSQL (`02_triggers.sql`)
- API con FastAPI: endpoints REST y WebSockets (`main.py`)
- Configuración de Docker (`docker-compose.yml`, `Dockerfile`)
- Revisión y aprobación de PRs que toquen backend o DB

**Archivos de su responsabilidad:** `main.py`, `requirements.txt`, `Dockerfile`, `docker-compose.yml`, `init-db/01_schema.sql`, `init-db/02_triggers.sql`

**Rama de trabajo:** `db/...`

---

### 🎨 Equipo 2 — Frontend y Conexión · `Juan` y `Sergio`

- Implementación de las 3 pantallas: login, dashboard e historial
- Conexión con la API usando las funciones de `api.js`
- Lógica de WebSocket y reconexión automática (`websocket.js`)
- Estilos con Tailwind CSS 4
- Modal de alertas médicas para errores 400 del Trigger
- Revisión y aprobación de PRs que toquen el directorio `frontend/`

**Archivos de su responsabilidad:** todo el directorio `frontend/`

**Rama de trabajo:** `frontend/...`

---

### 📋 Equipo 3 — Data Seeding, QA y Documentación · `Walas` y `Alejandro`

- `03_seeding.sql`: datos ficticios suficientes para disparar todos los triggers
- Validar manualmente que cada trigger se dispara correctamente desde pgAdmin
- Verificar que el comando `docker compose up --build` funcione de principio a fin en una máquina limpia
- Mantener actualizados `README.md` y `CONTRIBUTING.md`
- Reportar bugs encontrados durante QA abriendo un issue o PR con rama `fix/...`

**Archivos de su responsabilidad:** `init-db/03_seeding.sql`, `README.md`, `CONTRIBUTING.md`

**Rama de trabajo:** `qa/...`

---

## 9. Reglas generales

- **No subas archivos innecesarios.** Agrega al `.gitignore`: `.venv/`, `__pycache__/`, `*.pyc`, `.env`, `node_modules/` (si aplica).
- **No hardcodees credenciales** en el código fuente. Las únicas credenciales van en `docker-compose.yml` (ya que es un proyecto académico local).
- **No uses `alert()`** en el frontend. Usa el modal de alerta médica definido en el README de frontend.
- **No hagas `location.reload()`** para actualizar datos. Usa `fetch` + WebSocket.
- **Ante una duda técnica**, primero revisa la documentación en `http://localhost:8000/docs`, luego consulta al líder técnico.
- **El profesor debe poder levantar el proyecto con un solo comando:** `docker compose up --build`. Si tu cambio rompe eso, no va al PR.