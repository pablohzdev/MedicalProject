# 🏥 Sistema de Alertas Clínicas

Plataforma de gestión clínica con un motor de alertas médicas implementado directamente en la base de datos. Desarrollado como proyecto final para la materia de **Administración de Base de Datos — TEC**.

---

## ¿De qué trata el proyecto?

El sistema permite a los médicos registrar consultas y tratamientos de sus pacientes. Su funcionalidad central es un **Motor de Alertas Clínicas**: cuando un paciente recibe el mismo tratamiento en múltiples consultas consecutivas sin mejoría evidente, la base de datos dispara automáticamente una alerta que sugiere una reevaluación médica inmediata.

Esta lógica vive en la base de datos mediante **Triggers y funciones PL/pgSQL**, no en el backend ni en el frontend. El backend simplemente expone los datos y retransmite las notificaciones; la inteligencia está en PostgreSQL.

---

## ✨ Funcionalidades principales

- **Login simulado** por selector de médico
- **Dashboard de pacientes** con búsqueda en tiempo real
- **Historial clínico** por paciente con lista de consultas y tratamientos previos
- **Registro de tratamientos** con validación automática vía Trigger
- **Alertas médicas** en tiempo real cuando el Trigger detecta un patrón de riesgo
- **Sincronización automática** de la UI mediante WebSockets — cualquier cambio en la base de datos (incluso desde pgAdmin) se refleja en el frontend sin recargar la página

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                        Frontend                         │
│         HTML + Vanilla JS + Tailwind CSS 4              │
│   Login │ Dashboard de Pacientes │ Historial + Consulta │
└──────────────────┬──────────────────────┬───────────────┘
                   │ HTTP (fetch)         │ WebSocket
                   ▼                      ▼
┌─────────────────────────────────────────────────────────┐
│                  Backend — FastAPI                       │
│         Endpoints REST  │  WebSocket /ws                │
│     Escucha pg_notify y retransmite al frontend         │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│               Base de Datos — PostgreSQL 18             │
│                                                         │
│  Tablas: medicos, pacientes, consultas                  │
│                                                         │
│  Trigger: al insertar una consulta, verifica si el      │
│  paciente ya recibió el mismo tratamiento en consultas  │
│  anteriores. Si detecta el patrón → lanza excepción     │
│  (error 400 al frontend) y ejecuta pg_notify            │
│  para avisar al backend en tiempo real.                 │
└─────────────────────────────────────────────────────────┘
```

### Flujo de una alerta médica

```
Médico registra tratamiento
         │
         ▼
   POST /consultas
         │
         ▼
  Trigger de PostgreSQL evalúa
         │
    ┌────┴─────┐
    │          │
  Sin       Patrón
 patrón   detectado
    │          │
    ▼          ▼
 Consulta   RAISE EXCEPTION
 guardada   → FastAPI devuelve 400
    │       → Frontend muestra
    │         modal de alerta ⚠️
    ▼
pg_notify → FastAPI → WebSocket
→ Frontend recarga datos
```

---

## 🛠️ Stack tecnológico (Mayo 2026)

| Capa | Tecnología | Versión |
|---|---|---|
| Base de datos | PostgreSQL | `18-alpine` |
| Backend | Python + FastAPI | `3.13` / `0.136.x` |
| Servidor estático | Nginx | `1.30.0-alpine` |
| Frontend | HTML + Vanilla JS | — |
| Estilos | Tailwind CSS | `4.x` |
| Contenedores | Docker Compose | v2 |

> No se usan frameworks de JS (React, Vue, etc.) ni librerías externas en el frontend. Todo corre con APIs nativas del navegador: `fetch` y `WebSocket`.

---

## 🚀 Cómo ejecutar el proyecto

### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo

### Pasos

```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd proyecto-db

# 2. Levantar todos los servicios
docker compose up --build
```

Listo. El sistema estará disponible en:

| Servicio | URL |
|---|---|
| 🌐 Frontend | http://localhost:3000 |
| ⚙️ API | http://localhost:8000 |
| 📄 Documentación API (Swagger) | http://localhost:8000/docs |
| 🗄️ Base de datos | `localhost:5432` |

> La base de datos se inicializa automáticamente con el esquema, los triggers y los datos de prueba al primer arranque. No se requiere ningún paso adicional.

### Credenciales de la base de datos

| Campo | Valor |
|---|---|
| Host | `localhost` |
| Puerto | `5432` |
| Usuario | `admin` |
| Contraseña | `password123` |
| Base de datos | `clinica_db` |

### Reiniciar la base de datos desde cero

```bash
docker compose down -v   # elimina el volumen con los datos
docker compose up --build
```

---

## 📁 Estructura del repositorio

```
proyecto-db/
├── docker-compose.yml            # Orquestación de los 3 servicios
│
├── backend/
│   ├── main.py                   # API REST + WebSockets (FastAPI)
│   ├── requirements.txt          # Dependencias Python
│   └── Dockerfile                # Imagen del backend
│
├── frontend/
│   ├── index.html                # Pantalla de login
│   ├── dashboard.html            # Lista de pacientes
│   ├── historial.html            # Historial y nueva consulta
│   ├── api.js                    # Funciones fetch centralizadas
│   └── websocket.js              # Lógica de WebSocket y reconexión
│
└── init-db/                      # Se ejecuta automáticamente al crear el contenedor
    ├── 01_schema.sql             # Definición de tablas y relaciones
    ├── 02_triggers.sql           # Triggers y funciones PL/pgSQL
    └── 03_seeding.sql            # Datos ficticios para pruebas
```

---

## 👥 Equipo

| Equipo | Integrantes | Responsabilidad |
|---|---|---|
| 🗄️ Base de Datos y Backend | Carrasco y Pablo | Esquema SQL, Triggers, API FastAPI, Docker |
| 🎨 Frontend y Conexión | Juan y Sergio | UI, integración con la API, WebSockets |
| 📋 QA y Documentación | Walas y Alejandro | Seeding, validación de Triggers, documentación |

---

## 📚 Documentación adicional

| Documento | Descripción |
|---|---|
| [`CONTRIBUTING.md`](./CONTRIBUTING.md) | Índice de guías por equipo |
| [`CONTRIBUTING-DB.md`](./backend/CONTRIBUTING-DB.md) | Guía para el Equipo 1 (DB y Backend) |
| [`CONTRIBUTING-FRONTEND.md`](./frontend/CONTRIBUTING-FRONTEND.md) | Guía para el Equipo 2 (Frontend) |
| [`CONTRIBUTING-QA.md`](./CONTRIBUTING-QA.md) | Guía para el Equipo 3 (QA y Docs) |
| [Swagger UI](http://localhost:8000/docs) | Documentación interactiva de la API (requiere el proyecto levantado) |