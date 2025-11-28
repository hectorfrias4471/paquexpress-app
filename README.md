# Paquexpress - Sistema 

Sistema de gestión de entregas de paquetes con captura de GPS y evidencia con fotos

## Tecnologías

- **Frontend:** Flutter
- **Backend:** FastAPI 
- **Base de datos:** MySQL
- **Sensores:** GPS (Geolocator) + Cámara (Image Picker)

## Características

- Login seguro con encriptación MD5
- Lista de paquetes asignados
- Captura de foto como evidencia
- Registro de ubicación GPS
- Almacenamiento en base de datos
- Mapa interactivo 

## Instalación

### 1. Base de Datos
```bash
# Ejecutar en MySQL
mysql -u root -p < database/script.sql
```

### 2. API (FastAPI)
```bash
cd api
pip install fastapi uvicorn sqlalchemy mysql-connector-python python-multipart
uvicorn main:app --reload
```

### 3. App (Flutter)
```bash
cd app
flutter pub get
flutter run
```

## Usuarios de Prueba

| Usuario | Contraseña |
|---------|------------|
| repartidor1 | pass123 |
| repartidor2 | pass456 |
| admin | admin123 |

## 📸 Capturas

_(Agregar capturas aquí)_

## 👨‍💻 Autor

Hector Frias - Desarrollo de Aplicaciones Móviles UTEQ LIITID001