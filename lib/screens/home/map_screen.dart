import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/service_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../services/service_detail_screen.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirestoreService _fs = FirestoreService();
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(4.6097, -74.0817); // Bogotá por defecto
  LatLng? _userLocation;
  String _locationLabel = 'Obteniendo ubicación...';
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        final loc = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _userLocation = loc;
          _center = loc;
          _locationLabel = 'Tu ubicación actual';
        });
        _mapController.move(loc, 13);
      } else {
        setState(() => _locationLabel = 'Permiso de ubicación no concedido');
      }
    } catch (e) {
      setState(() => _locationLabel = 'No se pudo obtener la ubicación');
    } finally {
      setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de servicios')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: StreamBuilder<List<ServiceModel>>(
                  stream: _fs.servicesStream(),
                  builder: (context, snap) {
                    final services = snap.data ?? [];

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.conectalocal.app',
                        ),
                        // Marcador de ubicación del usuario
                        if (_userLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Color(0xFF4F46E5),
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        // Marcadores de servicios (posición fija demo)
                        // En producción: agregar lat/lng a cada servicio
                        MarkerLayer(
                          markers: _buildServiceMarkers(context, services),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.place_outlined,
                          color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_locationLabel)),
                  if (!_locating)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _getLocation,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  List<Marker> _buildServiceMarkers(
      BuildContext context, List<ServiceModel> services) {
    // Demo: distribuir marcadores alrededor del centro
    // En producción: usa las coordenadas reales de cada servicio
    final markers = <Marker>[];
    for (int i = 0; i < services.length; i++) {
      final offset = 0.01 * (i + 1);
      final point = LatLng(
        _center.latitude + (i % 2 == 0 ? offset : -offset),
        _center.longitude + (i % 3 == 0 ? offset : -offset * 0.5),
      );

      markers.add(
        Marker(
          point: point,
          width: 120,
          height: 50,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              ServiceDetailScreen.routeName,
              arguments: services[i],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                services[i].category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}
