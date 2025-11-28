from fastapi import FastAPI, Depends, HTTPException, File, UploadFile
from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP, ForeignKey, DECIMAL, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from pydantic import BaseModel
from typing import Optional
import hashlib
import base64
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

DATABASE_URL = "mysql+mysqlconnector://root:@localhost/db_paquexpress"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI(title="Paquexpress API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Usuario(Base):
    __tablename__ = "usuarios"
    id_usuario = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    nombre_completo = Column(String(100), nullable=False)
    fecha_creacion = Column(TIMESTAMP, default=datetime.utcnow)

class Paquete(Base):
    __tablename__ = "paquetes"
    id_paquete = Column(Integer, primary_key=True, index=True)
    id_usuario_asignado = Column(Integer, ForeignKey("usuarios.id_usuario"))
    direccion_destino = Column(String(255), nullable=False)
    descripcion = Column(Text)
    estatus = Column(String(20), default='pendiente')
    fecha_asignacion = Column(TIMESTAMP, default=datetime.utcnow)
    usuario = relationship("Usuario")

class Entrega(Base):
    __tablename__ = "entregas"
    id_entrega = Column(Integer, primary_key=True, index=True)
    id_paquete = Column(Integer, ForeignKey("paquetes.id_paquete"))
    id_usuario = Column(Integer, ForeignKey("usuarios.id_usuario"))
    foto_evidencia = Column(Text)  # Base64
    latitud = Column(DECIMAL(10, 8), nullable=False)
    longitud = Column(DECIMAL(11, 8), nullable=False)
    direccion_completa = Column(String(255))
    fecha_entrega = Column(TIMESTAMP, default=datetime.utcnow)
    paquete = relationship("Paquete")
    usuario = relationship("Usuario")


class LoginModel(BaseModel):
    username: str
    password: str

class EntregaModel(BaseModel):
    id_paquete: int
    id_usuario: int
    foto_base64: str
    latitud: float
    longitud: float
    direccion_completa: Optional[str] = None


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def md5_hash(password: str) -> str:
    return hashlib.md5(password.encode()).hexdigest()


@app.get("/")
def read_root():
    return {
        "mensaje": "API de Paquexpress funcionando correctamente",
        "version": "1.0",
        "endpoints": ["/login", "/paquetes/{id_usuario}", "/entregas"]
    }

@app.post("/login/")
def login(data: LoginModel, db=Depends(get_db)):
    """
    Endpoint para login de usuarios (repartidores)
    """
    usuario = db.query(Usuario).filter(Usuario.username == data.username).first()
    
    # Verificar que existe y la contraseña coincide
    if not usuario or usuario.password_hash != md5_hash(data.password):
        raise HTTPException(status_code=400, detail="Credenciales inválidas")
    
    return {
        "msg": "Login exitoso",
        "id_usuario": usuario.id_usuario,
        "nombre_completo": usuario.nombre_completo,
        "username": usuario.username
    }

@app.get("/paquetes/{id_usuario}")
def listar_paquetes(id_usuario: int, db=Depends(get_db)):
    """
    Obtiene todos los paquetes asignados a un repartidor
    Por defecto muestra solo los pendientes
    """
    paquetes = db.query(Paquete).filter(
        Paquete.id_usuario_asignado == id_usuario,
        Paquete.estatus == 'pendiente'
    ).all()
    
    if not paquetes:
        return {"msg": "No hay paquetes pendientes", "data": []}
    
    lista_paquetes = []
    for paq in paquetes:
        lista_paquetes.append({
            "id_paquete": paq.id_paquete,
            "direccion_destino": paq.direccion_destino,
            "descripcion": paq.descripcion,
            "estatus": paq.estatus,
            "fecha_asignacion": paq.fecha_asignacion.strftime("%Y-%m-%d %H:%M:%S")
        })
    
    return {"msg": "Paquetes obtenidos", "data": lista_paquetes}

#  Guardar foto + GPS + actualizar paquete
@app.post("/entregas/")
def registrar_entrega(data: EntregaModel, db=Depends(get_db)):
    """
    Registra una entrega completada:
    - Guarda foto en base64
    - Guarda coordenadas GPS
    - Marca el paquete como 'entregado'
    """
    try:
        paquete = db.query(Paquete).filter(Paquete.id_paquete == data.id_paquete).first()
        
        if not paquete:
            raise HTTPException(status_code=404, detail="Paquete no encontrado")
        
        if paquete.estatus == 'entregado':
            raise HTTPException(status_code=400, detail="Este paquete ya fue entregado")
        
        nueva_entrega = Entrega(
            id_paquete=data.id_paquete,
            id_usuario=data.id_usuario,
            foto_evidencia=data.foto_base64,
            latitud=data.latitud,
            longitud=data.longitud,
            direccion_completa=data.direccion_completa or "Dirección no especificada"
        )
        
        paquete.estatus = 'entregado'
        
        db.add(nueva_entrega)
        db.commit()
        db.refresh(nueva_entrega)
        
        return {
            "msg": "Entrega registrada exitosamente",
            "id_entrega": nueva_entrega.id_entrega,
            "id_paquete": data.id_paquete,
            "estatus": "entregado"
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al registrar entrega: {str(e)}")

@app.get("/entregas/{id_usuario}")
def historial_entregas(id_usuario: int, db=Depends(get_db)):
    """
    Obtiene el historial de entregas completadas por un usuario
    """
    entregas = db.query(Entrega).filter(Entrega.id_usuario == id_usuario).order_by(Entrega.fecha_entrega.desc()).all()
    
    if not entregas:
        return {"msg": "No hay entregas registradas", "data": []}
    
    lista_entregas = []
    for ent in entregas:
        paquete = db.query(Paquete).filter(Paquete.id_paquete == ent.id_paquete).first()
        
        lista_entregas.append({
            "id_entrega": ent.id_entrega,
            "id_paquete": ent.id_paquete,
            "direccion_destino": paquete.direccion_destino if paquete else "Desconocida",
            "direccion_completa": ent.direccion_completa,
            "latitud": float(ent.latitud),
            "longitud": float(ent.longitud),
            "fecha_entrega": ent.fecha_entrega.strftime("%Y-%m-%d %H:%M:%S"),
            "tiene_foto": True if ent.foto_evidencia else False
        })
    
    return {"msg": "Historial obtenido", "data": lista_entregas}

@app.get("/entregas/{id_entrega}/foto")
def obtener_foto(id_entrega: int, db=Depends(get_db)):
    """
    Devuelve la foto en base64 de una entrega específica
    """
    entrega = db.query(Entrega).filter(Entrega.id_entrega == id_entrega).first()
    
    if not entrega:
        raise HTTPException(status_code=404, detail="Entrega no encontrada")
    
    if not entrega.foto_evidencia:
        raise HTTPException(status_code=404, detail="Esta entrega no tiene foto")
    
    return {
        "id_entrega": id_entrega,
        "foto_base64": entrega.foto_evidencia
    }