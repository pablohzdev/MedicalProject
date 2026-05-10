from fastapi import FastAPI

app = FastAPI(title="API Sistema Clínico - TEC")

@app.get("/")
def read_root():
    return {"mensaje": "API funcionando correctamente. Ve a /docs para ver la documentación del sistema."}