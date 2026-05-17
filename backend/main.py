from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import psycopg
import psycopg.rows
import psycopg.errors as pg_errors
import asyncio

# --- LIFESPAN ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    asyncio.create_task(listen_to_pg())
    yield

app = FastAPI(title="API Sistema Clínico - TEC", lifespan=lifespan)

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:5500", "http://localhost:5500"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_URL = "postgresql://admin:password123@db:5432/clinica_db"

# --- MODELOS ---
class TratamientoIn(BaseModel):
    medicamento: str
    dosis: str
    duracion_dias: int
    motivo_tratamiento: Optional[str] = None

class ConsultaIn(BaseModel):
    paciente_id: int
    medico_id: int
    motivo_consulta: str
    diagnostico: str
    tratamientos: List[TratamientoIn]
    force: Optional[bool] = False  # Para bypass del trigger

# --- WEBSOCKET ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

async def listen_to_pg():
    while True:
        try:
            conn = await psycopg.AsyncConnection.connect(DB_URL, autocommit=True)
            async with conn:
                await conn.execute("LISTEN cambios_clinica")
                print("🔊 Escuchando notificaciones en 'cambios_clinica'...")
                async for notify in conn.notifies():
                    await manager.broadcast(notify.payload)
        except Exception as e:
            print(f"Error en escucha de BD: {e}. Reintentando en 5s...")
            await asyncio.sleep(5)

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# --- ENDPOINTS ---
@app.get("/pacientes")
async def obtener_pacientes():
    async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
        async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            await cur.execute(
                "SELECT id, nombre, fecha_nacimiento, genero, grupo_sanguineo, antecedentes FROM pacientes ORDER BY nombre ASC"
            )
            return await cur.fetchall()

# FIX: ahora incluye grupo_sanguineo y antecedentes
@app.get("/pacientes/{paciente_id}")
async def obtener_paciente(paciente_id: int):
    async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
        async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            await cur.execute(
                "SELECT id, nombre, fecha_nacimiento, genero, grupo_sanguineo, antecedentes FROM pacientes WHERE id = %s",
                (paciente_id,)
            )
            paciente = await cur.fetchone()
            if not paciente:
                raise HTTPException(status_code=404, detail="Paciente no encontrado")
            return paciente

# Devuelve consultas con tratamientos anidados
@app.get("/pacientes/{paciente_id}/historial")
async def obtener_historial(paciente_id: int):
    async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
        async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:

            await cur.execute("SELECT id FROM pacientes WHERE id = %s", (paciente_id,))
            if not await cur.fetchone():
                raise HTTPException(status_code=404, detail="Paciente no encontrado")

            await cur.execute("""
                SELECT
                    c.id              AS consulta_id,
                    c.fecha,
                    c.motivo_consulta,
                    c.diagnostico,
                    t.id              AS tratamiento_id,
                    t.medicamento,
                    t.dosis,
                    t.duracion_dias,
                    t.motivo_tratamiento,
                    t.fecha_registro
                FROM consultas c
                LEFT JOIN tratamientos t ON c.id = t.consulta_id
                WHERE c.paciente_id = %s
                ORDER BY c.fecha DESC, t.id ASC
            """, (paciente_id,))

            filas = await cur.fetchall()

            # Agrupar por consulta
            consultas = {}
            for fila in filas:
                cid = fila["consulta_id"]
                if cid not in consultas:
                    consultas[cid] = {
                        "id":              cid,
                        "fecha":           fila["fecha"].isoformat() if fila["fecha"] else None,
                        "motivo_consulta": fila["motivo_consulta"],
                        "diagnostico":     fila["diagnostico"],
                        "tratamientos":    [],
                    }
                if fila["tratamiento_id"] is not None:
                    consultas[cid]["tratamientos"].append({
                        "id":                 fila["tratamiento_id"],
                        "medicamento":        fila["medicamento"],
                        "dosis":              fila["dosis"],
                        "duracion_dias":      fila["duracion_dias"],
                        "motivo_tratamiento": fila["motivo_tratamiento"],
                        "fecha_registro":     fila["fecha_registro"].isoformat() if fila["fecha_registro"] else None,
                    })

            return list(consultas.values())

@app.post("/tratamientos")
async def registrar_tratamiento(datos: ConsultaIn):
    try:
        async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
            async with conn.transaction():
                async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
                    
                    # Si force=true, desactivar el trigger temporalmente
                    if datos.force:
                        await cur.execute("SET session_replication_role = 'replica';")
                    
                    await cur.execute("""
                        INSERT INTO consultas (paciente_id, medico_id, motivo_consulta, diagnostico)
                        VALUES (%s, %s, %s, %s) RETURNING id
                    """, (datos.paciente_id, datos.medico_id, datos.motivo_consulta, datos.diagnostico))

                    consulta_id = (await cur.fetchone())['id']

                    for trat in datos.tratamientos:
                        await cur.execute("""
                            INSERT INTO tratamientos (consulta_id, medicamento, dosis, duracion_dias, motivo_tratamiento)
                            VALUES (%s, %s, %s, %s, %s)
                        """, (consulta_id, trat.medicamento, trat.dosis, trat.duracion_dias, trat.motivo_tratamiento))

                    # Reactivar triggers si se desactivaron
                    if datos.force:
                        await cur.execute("SET session_replication_role = 'origin';")

                return {"status": "success", "consulta_id": consulta_id}

    except pg_errors.RaiseException as e:
        raise HTTPException(status_code=400, detail=str(e).split('\n')[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

# Modelo para crear paciente
class PacienteIn(BaseModel):
    nombre: str
    fecha_nacimiento: Optional[str] = None
    genero: Optional[str] = None
    grupo_sanguineo: Optional[str] = None
    antecedentes: Optional[str] = None

@app.post("/pacientes")
async def crear_paciente(datos: PacienteIn):
    try:
        async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
            async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
                await cur.execute("""
                    INSERT INTO pacientes (nombre, fecha_nacimiento, genero, grupo_sanguineo, antecedentes)
                    VALUES (%s, %s, %s, %s, %s) RETURNING id
                """, (
                    datos.nombre,
                    datos.fecha_nacimiento if datos.fecha_nacimiento else None,
                    datos.genero if datos.genero else None,
                    datos.grupo_sanguineo if datos.grupo_sanguineo else None,
                    datos.antecedentes if datos.antecedentes else None
                ))
                paciente_id = (await cur.fetchone())['id']
                return {"status": "success", "paciente_id": paciente_id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al registrar paciente: {str(e)}")