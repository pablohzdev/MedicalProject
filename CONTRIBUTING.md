# 🤝 Guía de Contribución — Sistema de Alertas Clínicas

Bienvenido al proyecto. Este archivo es el punto de entrada — léelo primero y luego ve a la guía de tu equipo.

---

## ¿Quién eres?

| Equipo | Integrantes | Tu guía |
|---|---|---|
| 🗄️ Base de Datos y Backend | Carrasco y Pablo | [`CONTRIBUTING-DB.md`](./backend/CONTRIBUTING-DB.md) |
| 🎨 Frontend y Conexión | Juan y Sergio | [`CONTRIBUTING-FRONTEND.md`](./frontend/CONTRIBUTING-FRONTEND.md) |
| 📋 QA y Documentación | Walas y Alejandro | [`CONTRIBUTING-QA.md`](./CONTRIBUTING-QA.md.md) |

---

## Reglas que aplican a todos

1. **Nunca hagas push directo a `main`.** Todo cambio entra por Pull Request.
2. **Usa Conventional Commits.** Formato: `tipo(área): descripción` — ejemplos en la guía de tu equipo.
3. **El proyecto debe levantarse con un solo comando:** `docker compose up --build`. Si tu cambio lo rompe, no va al PR.
4. **No subas archivos innecesarios.** El `.gitignore` cubre: `.venv/`, `__pycache__/`, `*.pyc`, `.env`.
5. **No hardcodees credenciales** fuera del `docker-compose.yml`.

---

## Stack (Mayo 2026)

| Tecnología | Versión |
|---|---|
| PostgreSQL | `18-alpine` |
| Python | `3.13` |
| FastAPI | `0.136.x` |
| Nginx | `1.30.0-alpine` |
| Tailwind CSS | `4.x` |
| Docker Compose | v2 (sin clave `version:` en el archivo) |

> El `docker-compose.yml` y el `Dockerfile` ya reflejan estas versiones. No las cambies sin consultar al Equipo 1.

---

## URLs del proyecto levantado

| Servicio | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API | http://localhost:8000 |
| Swagger / Docs | http://localhost:8000/docs |
| Base de datos | `localhost:5432` · usuario: `admin` · db: `clinica_db` |

---

## Ramas por equipo

| Prefijo | Equipo |
|---|---|
| `db/...` | Equipo 1 — Carrasco y Pablo |
| `frontend/...` | Equipo 2 — Juan y Sergio |
| `qa/...` | Equipo 3 — Walas y Alejandro |
| `fix/...` | Cualquiera |