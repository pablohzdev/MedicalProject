# 📋 Guía del Equipo 3 — QA, Data Seeding y Documentación

**Integrantes:** Walas y Alejandro
**Rama de trabajo:** `qa/...`

← Volver al índice: [`CONTRIBUTING.md`](./CONTRIBUTING.md)

---

## Índice

1. [Tus archivos](#1-tus-archivos)
2. [Cómo configurar el entorno](#2-cómo-configurar-el-entorno)
3. [Data Seeding](#3-data-seeding)
4. [Validación de Triggers](#4-validación-de-triggers)
5. [Checklist de QA](#5-checklist-de-qa)
6. [Flujo de trabajo con Git](#6-flujo-de-trabajo-con-git)
7. [Convención de commits](#7-convención-de-commits)
8. [Pull Requests](#8-pull-requests)

---

## 1. Tus archivos

```
proyecto-db/
├── README.md                   # README principal del repositorio
├── CONTRIBUTING.md             # Índice de guías (este conjunto de archivos)
├── backend/CONTRIBUTING-DB.md
├── frontend/CONTRIBUTING-FRONTEND.md
├── CONTRIBUTING-QA.md          # Este archivo
└── init-db/
    └── 03_seeding.sql          # Datos ficticios para pruebas
```

No toques `01_schema.sql` ni `02_triggers.sql` — esos son del Equipo 1.

---

## 2. Cómo configurar el entorno

```bash
git clone <url-del-repositorio>
cd proyecto-db
docker compose up --build
```

Una vez levantado, conéctate a la base de datos desde **pgAdmin**:

| Campo | Valor |
|---|---|
| Host | `localhost` |
| Puerto | `5432` |
| Usuario | `admin` |
| Contraseña | `password123` |
| Base de datos | `clinica_db` |

### Resetear la base de datos

Si necesitas que `init-db/` corra de nuevo desde cero (por ejemplo, después de modificar `03_seeding.sql`):

```bash
docker compose down -v    # -v elimina el volumen con los datos
docker compose up --build
```

---

## 3. Data Seeding

El archivo `03_seeding.sql` se ejecuta automáticamente al crear el contenedor por primera vez. Debe insertar datos suficientes para que **todos los triggers puedan probarse sin necesidad de insertar datos a mano**.

### Qué debe incluir el seeding

Coordina con el Equipo 1 para saber exactamente qué tablas existen. Como mínimo necesitas:

**Médicos** — al menos 3, con los mismos IDs que usa el login del frontend.

**Pacientes** — al menos 5, con nombres realistas.

**Consultas previas** — al menos un paciente debe tener consultas repetidas con el mismo medicamento, para que el trigger de alerta se dispare al agregar una más.

### Ejemplo de estructura

```sql
-- 03_seeding.sql

-- Médicos
INSERT INTO medicos (nombre, especialidad) VALUES
  ('Dra. García',    'Medicina General'),
  ('Dr. Martínez',   'Cardiología'),
  ('Dra. López',     'Pediatría');

-- Pacientes
INSERT INTO pacientes (nombre, fecha_nacimiento) VALUES
  ('Carlos Ramírez',  '1985-03-12'),
  ('Ana Torres',      '1990-07-24'),
  ('Luis Mendoza',    '1978-11-05'),
  ('María Soto',      '2000-01-30'),
  ('Jorge Ríos',      '1965-09-18');

-- Consultas previas (para probar el trigger de alerta)
-- Carlos Ramírez ya recibió Ibuprofeno dos veces seguidas
INSERT INTO consultas (paciente_id, medico_id, medicamento, dosis, duracion_dias) VALUES
  (1, 1, 'Ibuprofeno', '400mg', 5),
  (1, 1, 'Ibuprofeno', '400mg', 5);
-- Al registrar una tercera consulta con Ibuprofeno para Carlos,
-- el trigger debe disparar la alerta.
```

> Ajusta los nombres de columnas y tablas según lo que defina el Equipo 1 en `01_schema.sql`.

---

## 4. Validación de Triggers

Tu responsabilidad es confirmar que cada trigger funciona correctamente. Hazlo desde pgAdmin **y** desde el frontend.

### Desde pgAdmin

1. Abre el Query Tool en pgAdmin.
2. Inserta una consulta que debería disparar la alerta:

```sql
-- Tercera consulta con el mismo medicamento para el mismo paciente
INSERT INTO consultas (paciente_id, medico_id, medicamento, dosis, duracion_dias)
VALUES (1, 1, 'Ibuprofeno', '400mg', 5);
```

3. El trigger debe lanzar un error. En pgAdmin verás algo como:

```
ERROR: ALERTA: El paciente ya recibió este tratamiento sin mejoría evidente.
```

### Desde el frontend

1. Abre http://localhost:3000
2. Inicia sesión con cualquier médico
3. Ve al historial de Carlos Ramírez
4. Registra un tratamiento con **Ibuprofeno, 400mg, 5 días**
5. Debe aparecer el **modal de alerta médica** con el mensaje del trigger

Si aparece un `alert()` nativo del navegador en lugar del modal, repórtalo al Equipo 2.

---

## 5. Checklist de QA

Ejecuta esta lista completa antes de que el equipo entregue el proyecto. Marca cada punto y reporta lo que falle.

### Sistema general

- [ ] `docker compose up --build` corre sin errores en una máquina limpia
- [ ] `docker compose ps` muestra los 3 servicios en estado `running`
- [ ] http://localhost:3000 carga el login
- [ ] http://localhost:8000/docs carga la documentación de la API

### Login

- [ ] El `<select>` muestra los médicos correctamente
- [ ] Al seleccionar un médico y presionar **Entrar**, redirige al dashboard
- [ ] Si se accede a `dashboard.html` sin sesión, redirige al login
- [ ] **Cerrar sesión** limpia el `localStorage` y vuelve al login

### Dashboard

- [ ] La tabla carga todos los pacientes del seeding
- [ ] El buscador filtra por nombre sin recargar la página
- [ ] Al hacer clic en un paciente, abre `historial.html?pacienteId=<id>`
- [ ] Al insertar un paciente directo desde pgAdmin, la tabla se actualiza sola (WebSocket)

### Historial

- [ ] La cabecera muestra los datos correctos del paciente
- [ ] La lista de consultas previas se muestra correctamente
- [ ] Al registrar un tratamiento exitoso, el formulario se limpia
- [ ] Al registrar un tratamiento que dispara el trigger, aparece el **modal** (no un `alert()`)
- [ ] El mensaje del modal es exactamente el que viene del servidor

### Trigger

- [ ] El trigger se dispara correctamente desde pgAdmin
- [ ] El trigger se dispara correctamente desde el frontend
- [ ] El mensaje de error es claro y descriptivo

---

## 6. Flujo de trabajo con Git

```bash
# Siempre partir de main actualizado
git checkout main
git pull origin main

# Crear rama con prefijo qa/
git checkout -b qa/nombre-de-la-tarea

# Ejemplos de nombres de rama
qa/seeding-inicial
qa/seeding-casos-trigger
qa/validacion-triggers
qa/checklist-entrega
qa/readme-principal
```

```bash
# Subir cambios
git add .
git commit -m "feat(qa): agregar datos de seeding para probar trigger de alerta"
git push origin qa/nombre-de-la-tarea
```

---

## 7. Convención de commits

Formato: `tipo(área): descripción en minúsculas`

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nuevo bloque de datos en el seeding |
| `fix` | Corrección de un bug encontrado en QA (en cualquier archivo) |
| `docs` | Cambios en README o CONTRIBUTING |
| `qa` | Reportes, checklists, scripts de validación |

### Ejemplos correctos

```bash
git commit -m "feat(qa): agregar pacientes y consultas previas al seeding"
git commit -m "feat(qa): agregar caso de prueba para trigger de alerta"
git commit -m "fix(qa): corregir FK incorrecta en 03_seeding.sql"
git commit -m "docs: actualizar README con instrucciones de despliegue"
```

### Ejemplos incorrectos ❌

```bash
git commit -m "datos"
git commit -m "seeding listo"
git commit -m "actualicé el readme"
```

---

## 8. Pull Requests

### Proceso

1. Termina tu trabajo en `qa/...`
2. Abre un PR en GitHub apuntando a `main`
3. Llena la plantilla de descripción
4. Asigna como revisor a cualquier integrante disponible
5. Haz merge una vez aprobado

### Plantilla

```markdown
## ¿Qué hace este PR?
Descripción breve del cambio.

## ¿Cómo probarlo?
1. `docker compose down -v && docker compose up --build`
2. Verificar que los datos de seeding existen en pgAdmin
3. Probar el trigger desde el frontend siguiendo el checklist de QA

## Checklist
- [ ] `docker compose down -v && docker compose up --build` corre sin errores
- [ ] Los datos de seeding aparecen correctamente en las tablas
- [ ] El trigger se dispara con los datos del seeding
- [ ] El frontend muestra el modal de alerta (no un `alert()` nativo)
```
