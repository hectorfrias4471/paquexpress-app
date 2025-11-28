import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  final double latitud;
  final double longitud;
  final String direccion;

  const MapaPage({
    super.key,
    required this.latitud,
    required this.longitud,
    required this.direccion,
  });

  @override
  MapaPageState createState() => MapaPageState();
}

class MapaPageState extends State<MapaPage> {
  GoogleMapController? controladorMapa;
  late Set<Marker> marcadores;

  @override
  void initState() {
    super.initState();
    // Crear marcador en la ubicación de entrega
    marcadores = {
      Marker(
        markerId: const MarkerId('ubicacion_entrega'),
        position: LatLng(widget.latitud, widget.longitud),
        infoWindow: InfoWindow(
          title: 'Ubicación de Entrega',
          snippet: widget.direccion,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Entrega'),
        actions: [
          // Botón para centrar el mapa
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centrar en ubicación',
            onPressed: () {
              if (controladorMapa != null) {
                controladorMapa!.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(widget.latitud, widget.longitud),
                    16,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la dirección
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFF6B35).withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📍 Dirección:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.direccion,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Lat: ${widget.latitud.toStringAsFixed(6)}, '
                      'Lon: ${widget.longitud.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitud, widget.longitud),
                zoom: 16,
              ),
              markers: marcadores,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                controladorMapa = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}