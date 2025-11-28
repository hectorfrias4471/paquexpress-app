import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mapa_page.dart';

class HistorialPage extends StatefulWidget {
  final int idUsuario;
  final String nombreCompleto;

  const HistorialPage({
    super.key,
    required this.idUsuario,
    required this.nombreCompleto,
  });

  @override
  HistorialPageState createState() => HistorialPageState();
}

class HistorialPageState extends State<HistorialPage> {
  List<dynamic> listaEntregas = [];
  bool cargando = true;
  String mensajeError = "";

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    setState(() {
      cargando = true;
      mensajeError = "";
    });

    try {
      var url = Uri.parse("http://localhost:8000/entregas/${widget.idUsuario}");
      var response = await http.get(url);

      var decoded = utf8.decode(response.bodyBytes);
      var data = json.decode(decoded);

      setState(() {
        listaEntregas = data['data'] ?? [];
        cargando = false;
      });
    } catch (e) {
      setState(() {
        mensajeError = "Error al cargar historial: $e";
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
            const Text("Historial de Entregas"),
            Text(
              widget.nombreCompleto,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarHistorial,
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
                        onPressed: cargarHistorial,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                )
              : listaEntregas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No hay entregas registradas",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listaEntregas.length,
                      itemBuilder: (context, index) {
                        var entrega = listaEntregas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Paquete #${entrega['id_paquete']}",
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
                                              color: Colors.green[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "ENTREGADO",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                        entrega['direccion_destino'] ?? entrega['direccion_completa'] ?? "Sin dirección",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      entrega['fecha_entrega'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.gps_fixed, size: 20, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Lat: ${entrega['latitud']}, Lon: ${entrega['longitud']}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (entrega['tiene_foto'] == true)
                                      TextButton.icon(
                                        onPressed: () {
                                          // Mostrar foto en diálogo
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Evidencia Fotográfica"),
                                              content: const Text("La foto está guardada en la base de datos"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text("Cerrar"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.photo),
                                        label: const Text("Ver Foto"),
                                      ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapaPage(
                                              latitud: entrega['latitud'],
                                              longitud: entrega['longitud'],
                                              direccion: entrega['direccion_completa'] ?? "Ubicación de entrega",
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.map),
                                      label: const Text("Ver Mapa"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}