# 🗄️ Guía del Equipo 1 — Base de Datos y Backend

**Integrantes:** Carrasco y Pablo
**Rama de trabajo:** `db/...`

← Volver al índice: [`CONTRIBUTING.md`](./CONTRIBUTING.md)

---

## Índice

1. [Tus archivos](#1-tus-archivos)
2. [Configurar el entorno local](#2-configurar-el-entorno-local)
3. [Flujo de trabajo con Git](#3-flujo-de-trabajo-con-git)
4. [Convención de commits](#4-convención-de-commits)
5. [Pull Requests](#5-pull-requests)
6. [Estructura de init-db](#6-estructura-de-init-db)

---

## 1. Tus archivos

Estos son los archivos bajo tu responsabilidad. No los modifiques sin coordinar con el otro integrante del equipo.

```
proyecto-db/
├── docker-compose.yml          # Orquestación de contenedores
├── backend/
│   ├── main.py                 # API FastAPI + WebSockets
│   ├── requirements.txt        # Dependencias Python
│   └── Dockerfile              # Imagen del backend
└── init-db/
    ├── 01_schema.sql           # Tablas y relaciones
    └── 02_triggers.sql         # Triggers y funciones PL/pgSQL
```

> `03_seeding.sql` es responsabilidad del Equipo 3. Coordina con Walas y Alejandro si necesitas datos de prueba.

---

## 2. Configurar el entorno local

### Levantar el proyecto

```bash
git clone <url-del-repositorio>
cd proyecto-db
docker compose up --build
```

### Entorno virtual de Python (para que VS Code no marque errores)

El código corre dentro de Docker, pero necesitas un `.venv` local para que Pylance funcione:

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

### Verificar que todo funciona

```bash
docker compose ps           # Todos los servicios deben estar "running"
curl http://localhost:8000/docs   # Debe responder con HTML de Swagger
```

### Conectar a la base de datos desde pgAdmin

| Campo | Valor |
|---|---|
| Host | `localhost` |
| Puerto | `5433` |
| Usuario | `admin` |
| Contraseña | `password123` |
| Base de datos | `postgres` |

---

## 3. Flujo de trabajo con Git

```bash
# Siempre partir de main actualizado
git checkout main
git pull origin main

# Crear rama con prefijo db/
git checkout -b db/nombre-de-la-tarea

# Ejemplos de nombres de rama
db/schema-inicial
db/trigger-tratamiento-repetido
db/endpoint-historial
db/websocket-notify
db/endpoint-pacientes
```

```bash
# Subir cambios
git add .
git commit -m "feat(db): crear trigger de alerta por tratamiento repetido"
git push origin db/nombre-de-la-tarea
```

---

## 4. Convención de commits

Formato: `tipo(área): descripción en minúsculas`

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva funcionalidad (endpoint, trigger, tabla) |
| `fix` | Corrección de un bug |
| `db` | Cambios en SQL que no son features nuevas (ajustes de schema, índices) |
| `refactor` | Refactorización sin cambiar comportamiento |
| `chore` | Cambios de configuración (Docker, dependencias) |
| `docs` | Documentación |

### Ejemplos correctos

```bash
git commit -m "feat(db): agregar tabla consultas con FK a pacientes"
git commit -m "feat(db): crear trigger pg_notify al insertar tratamiento"
git commit -m "feat(api): agregar endpoint GET /pacientes/{id}/historial"
git commit -m "feat(ws): emitir refresh_data al recibir notificación de postgres"
git commit -m "fix(api): corregir error 500 en endpoint POST /consultas"
git commit -m "chore(docker): actualizar healthcheck de postgres"
```

### Ejemplos incorrectos ❌

```bash
git commit -m "trigger listo"
git commit -m "arreglé el endpoint"
git commit -m "cambios en la api"
```

---

## 5. Pull Requests

### Proceso

1. Termina tu trabajo en `db/...`
2. Abre un PR en GitHub apuntando a `main`
3. Llena la plantilla de descripción
4. Asigna como revisor al otro integrante del Equipo 1
5. Haz merge una vez aprobado

### Plantilla

```markdown
## ¿Qué hace este PR?
Descripción breve del cambio.

## ¿Cómo probarlo?
1. `docker compose up --build`
2. Conectarse a pgAdmin y verificar...
3. Llamar al endpoint en http://localhost:8000/docs y verificar...

## Checklist
- [ ] `docker compose up --build` corre sin errores
- [ ] Los endpoints nuevos aparecen en http://localhost:8000/docs
- [ ] Los triggers se disparan correctamente desde pgAdmin
- [ ] No hay credenciales hardcodeadas fuera de `docker-compose.yml`
```

---

## 6. Estructura de init-db

Los archivos de `init-db/` se ejecutan **automáticamente y en orden numérico** al crear el contenedor de PostgreSQL por primera vez.

```
init-db/
├── 01_schema.sql     ← Primero: crea las tablas
├── 02_triggers.sql   ← Segundo: crea triggers (depende de las tablas)
└── 03_seeding.sql    ← Tercero: inserta datos (responsabilidad del Equipo 3)
```

> Si necesitas resetear la base de datos para que corra `init-db/` de nuevo:
> ```bash
> docker compose down -v   # -v elimina el volumen postgres_data
> docker compose up --build
> ```