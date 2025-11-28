import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'entrega_page.dart';
import 'mapa_page.dart';  
import 'package:geolocator/geolocator.dart';  

class PaquetesPage extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;
  final String username;

  const PaquetesPage({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
    required this.username,
  });

  @override
  PaquetesPageState createState() => PaquetesPageState();
}

class PaquetesPageState extends State<PaquetesPage> {
  List<dynamic> listaPaquetes = [];
  bool cargando = true;
  String mensajeError = "";

  @override
  void initState() {
    super.initState();
    cargarPaquetes();
  }

  // Función para cargar paquetes desde la API
  Future<void> cargarPaquetes() async {
    setState(() {
      cargando = true;
      mensajeError = "";
    });

    try {
      var url = Uri.parse("http://localhost:8000/paquetes/${widget.idUsuario}");
      var response = await http.get(url);

      var decoded = utf8.decode(response.bodyBytes);
      var data = json.decode(decoded);

      setState(() {
        listaPaquetes = data['data'] ?? [];
        cargando = false;
      });
    } catch (e) {
      setState(() {
        mensajeError = "Error al cargar paquetes: $e";
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mis Paquetes"),
            Text(
              widget.nombreCompleto,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Actualizar lista",
            onPressed: cargarPaquetes,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : mensajeError.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(mensajeError),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cargarPaquetes,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                )
              : listaPaquetes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "¡No hay paquetes pendientes!",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Excelente trabajo 🎉",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: cargarPaquetes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listaPaquetes.length,
                        itemBuilder: (context, index) {
                          var paquete = listaPaquetes[index];
return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () async {
                                // Ir a la página de entrega
                                final resultado = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EntregaPage(
                                      idPaquete: paquete['id_paquete'],
                                      idUsuario: widget.idUsuario,
                                      direccion: paquete['direccion_destino'],
                                      descripcion: paquete['descripcion'],
                                    ),
                                  ),
                                );
                                
                                if (resultado == true) {
                                  cargarPaquetes();
                                }
                              },
                              child: Stack(  // CAMBIAR A STACK
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ... (todo el contenido actual)
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF6B35).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.inventory_2,
                                                color: Color(0xFFFF6B35),
                                                size: 30,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Paquete #${paquete['id_paquete']}",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange[100],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      paquete['estatus'].toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.orange[800],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 20, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                paquete['direccion_destino'],
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.description, size: 20, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                paquete['descripcion'] ?? "Sin descripción",
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
                                  
                                  // AGREGAR BOTÓN FLOTANTE DE MAPA
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.map, color: Color(0xFFFF6B35)),
                                      tooltip: 'Ver en mapa',
                                      onPressed: () async {
                                        // Obtener ubicación actual para mostrar en el mapa
                                        try {
                                          Position posicion = await Geolocator.getCurrentPosition();
                                          if (!mounted) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MapaPage(
                                                latitud: posicion.latitude,
                                                longitud: posicion.longitude,
                                                direccion: paquete['direccion_destino'],
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          // Si no puede obtener GPS, usar coordenadas de ejemplo
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('No se pudo obtener la ubicación actual'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}