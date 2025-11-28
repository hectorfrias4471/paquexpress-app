CREATE DATABASE IF NOT EXISTS db_paquexpress;
USE db_paquexpress;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE paquetes (
    id_paquete INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_asignado INT NOT NULL,
    direccion_destino VARCHAR(255) NOT NULL,
    descripcion TEXT,
    estatus VARCHAR(20) DEFAULT 'pendiente',  -- 'pendiente' o 'entregado'
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario_asignado) REFERENCES usuarios(id_usuario)
);

CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_paquete INT NOT NULL,
    id_usuario INT NOT NULL,
    foto_evidencia LONGTEXT,  -- Guardaremos la imagen en base64
    latitud DECIMAL(10, 8) NOT NULL,
    longitud DECIMAL(11, 8) NOT NULL,
    direccion_completa VARCHAR(255),
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paquete) REFERENCES paquetes(id_paquete),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- usuarios de prueba contraseñas encriptadas con MD5
INSERT INTO usuarios (username, password_hash, nombre_completo) VALUES
('repartidor1', MD5('pass123'), 'Juan Perez'),
('repartidor2', MD5('pass456'), 'Luisa García'),
('admin', MD5('admin123'), 'Administrador Sistema');

-- paquetes de prueba asignados a repartidor1 id_usuario = 1
INSERT INTO paquetes (id_usuario_asignado, direccion_destino, descripcion, estatus) VALUES
(1, 'Av. Paloma #123, Col. Centro, Querétaro', ' Electrónica', 'pendiente'),
(1, 'Calle Reforma #456, Col. Jardines, Querétaro', 'Documentos urgentes', 'pendiente'),
(1, 'Blvd. Bernardo Quintana #789, Col. San Pablo, Querétaro', 'Ropa y accesorios', 'pendiente');

-- paquetes para repartidor2 id_usuario = 2
INSERT INTO paquetes (id_usuario_asignado, direccion_destino, descripcion, estatus) VALUES
(2, 'Calle Juárez #321, Col. El Pueblito, Querétaro', 'Paquete mediano - Libros', 'pendiente'),
(2, 'Av. Universidad #654, Col. San Pedrito, Querétaro', 'Medicamentos - Refrigerado', 'pendiente');

