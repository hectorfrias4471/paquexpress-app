import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class EntregaPage extends StatefulWidget {
  final int idPaquete;
  final int idUsuario;
  final String direccion;
  final String descripcion;

  const EntregaPage({
    super.key,
    required this.idPaquete,
    required this.idUsuario,
    required this.direccion,
    required this.descripcion,
  });

  @override
  EntregaPageState createState() => EntregaPageState();
}

class EntregaPageState extends State<EntregaPage> {
  // Variables de estado
  File? imagenSeleccionada;
  Position? ubicacionGPS;
  bool cargando = false;
  String mensaje = "";
  final ImagePicker _picker = ImagePicker();

  // Función para tomar foto
  Future<void> tomarFoto() async {
    try {
      // Pedir permiso de cámara
      var status = await Permission.camera.request();
      
      if (status.isGranted) {
        // Abrir cámara
        final XFile? foto = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70, // Comprimir imagen al 70%
        );

        if (foto != null) {
          setState(() {
            imagenSeleccionada = File(foto.path);
            mensaje = "✅ Foto capturada correctamente";
          });
        }
      } else {
        setState(() {
          mensaje = "❌ Se necesita permiso de cámara";
        });
      }
    } catch (e) {
      setState(() {
        mensaje = "❌ Error al tomar foto: $e";
      });
    }
  }

  // Función alternativa: seleccionar foto de galería
  Future<void> seleccionarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (foto != null) {
        setState(() {
          imagenSeleccionada = File(foto.path);
          mensaje = "✅ Foto seleccionada correctamente";
        });
      }
    } catch (e) {
      setState(() {
        mensaje = "❌ Error al seleccionar foto: $e";
      });
    }
  }

  // Función para obtener ubicación GPS
  Future<void> obtenerUbicacion() async {
    setState(() {
      cargando = true;
      mensaje = "Obteniendo ubicación GPS...";
    });

    try {
      // Verificar permisos de ubicación
      LocationPermission permiso = await Geolocator.checkPermission();
      
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        setState(() {
          mensaje = "❌ Los permisos de ubicación están deshabilitados";
          cargando = false;
        });
        return;
      }

      // Obtener posición actual
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        ubicacionGPS = posicion;
        mensaje = "✅ Ubicación GPS obtenida correctamente\n"
            "📍 Lat: ${posicion.latitude.toStringAsFixed(6)}\n"
            "📍 Lon: ${posicion.longitude.toStringAsFixed(6)}";
        cargando = false;
      });
    } catch (e) {
      setState(() {
        mensaje = "❌ Error al obtener ubicación: $e";
        cargando = false;
      });
    }
  }

  // Función para convertir imagen a Base64
  String imagenABase64(File imagen) {
    final bytes = imagen.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Función para registrar la entrega (enviar a la API)
  Future<void> registrarEntrega() async {
    // Validar que tenga foto y GPS
    if (imagenSeleccionada == null) {
      setState(() {
        mensaje = "❌ Debes tomar una foto primero";
      });
      return;
    }

    if (ubicacionGPS == null) {
      setState(() {
        mensaje = "❌ Debes obtener la ubicación GPS primero";
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = "Registrando entrega...";
    });

    try {
      // Convertir imagen a base64
      String fotoBase64 = imagenABase64(imagenSeleccionada!);

      // Enviar a la API
      var url = Uri.parse("http://localhost:8000/entregas/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_paquete": widget.idPaquete,
          "id_usuario": widget.idUsuario,
          "foto_base64": fotoBase64,
          "latitud": ubicacionGPS!.latitude,
          "longitud": ubicacionGPS!.longitude,
          "direccion_completa": widget.direccion,
        }),
      );

      var decoded = utf8.decode(response.bodyBytes);
      var data = json.decode(decoded);

      if (response.statusCode == 200) {
        // Mostrar diálogo de éxito
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("✅ Entrega Registrada"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Paquete #${widget.idPaquete} entregado exitosamente"),
                const SizedBox(height: 8),
                Text(
                  "ID Entrega: ${data['id_entrega']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.pop(context, true); // Volver a lista de paquetes
                },
                child: const Text("Aceptar"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          mensaje = "❌ Error: ${data['detail']}";
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = "❌ Error al registrar entrega: $e";
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entregar Paquete #${widget.idPaquete}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información del paquete
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Paquete #${widget.idPaquete}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFF6B35)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.direccion,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.description, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.descripcion,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección de foto
            const Text(
              "1️⃣ Evidencia Fotográfica",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Mostrar foto o placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: imagenSeleccionada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imagenSeleccionada!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sin foto",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Botones de foto
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar Foto"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: seleccionarFoto,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galería"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      foregroundColor: const Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sección de GPS
            const Text(
              "2️⃣ Ubicación GPS",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Mostrar coordenadas o placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ubicacionGPS != null 
                    ? Colors.green[50] 
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ubicacionGPS != null 
                      ? Colors.green 
                      : Colors.grey[400]!,
                ),
              ),
              child: ubicacionGPS != null
                  ? Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "📍 Latitud: ${ubicacionGPS!.latitude.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "📍 Longitud: ${ubicacionGPS!.longitude.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sin ubicación GPS",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            // Botón de GPS
            ElevatedButton.icon(
              onPressed: cargando ? null : obtenerUbicacion,
              icon: const Icon(Icons.my_location),
              label: const Text("Obtener Ubicación GPS"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),

            // Mensaje de estado
            if (mensaje.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mensaje.startsWith("✅") 
                      ? Colors.green[100] 
                      : mensaje.startsWith("❌")
                          ? Colors.red[100]
                          : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: mensaje.startsWith("✅") 
                        ? Colors.green[900] 
                        : mensaje.startsWith("❌")
                            ? Colors.red[900]
                            : Colors.blue[900],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),

            // Botón principal: PAQUETE ENTREGADO
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: cargando ? null : registrarEntrega,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "PAQUETE ENTREGADO",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}