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
    allow_origins=["http://localhost:3000"],
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
                "SELECT id, nombre, fecha_nacimiento, genero FROM pacientes ORDER BY nombre ASC"
            )
            return await cur.fetchall()

@app.get("/pacientes/{paciente_id}")
async def obtener_paciente(paciente_id: int):
    async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
        async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            await cur.execute(
                "SELECT id, nombre, fecha_nacimiento, genero FROM pacientes WHERE id = %s",
                (paciente_id,)
            )
            paciente = await cur.fetchone()
            if not paciente:
                raise HTTPException(status_code=404, detail="Paciente no encontrado")
            return paciente

@app.get("/pacientes/{paciente_id}/historial")
async def obtener_historial(paciente_id: int):
    async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
        async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            await cur.execute("""
                SELECT c.id, c.fecha, c.motivo_consulta, c.diagnostico,
                       t.medicamento, t.dosis, t.duracion_dias, t.motivo_tratamiento
                FROM consultas c
                LEFT JOIN tratamientos t ON c.id = t.consulta_id
                WHERE c.paciente_id = %s
                ORDER BY c.fecha DESC
            """, (paciente_id,))
            return await cur.fetchall()

@app.post("/tratamientos")
async def registrar_tratamiento(datos: ConsultaIn):
    try:
        async with await psycopg.AsyncConnection.connect(DB_URL) as conn:
            async with conn.transaction():
                async with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
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

                return {"status": "success", "consulta_id": consulta_id}

    except pg_errors.RaiseException as e:
        raise HTTPException(status_code=400, detail=str(e).split('\n')[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")