import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'menus.dart';
import 'info_derangement.dart';

class ContractorHomePage extends StatefulWidget {
  const ContractorHomePage({super.key});

  @override
  State<ContractorHomePage> createState() => _ContractorHomePageState();
}

class _ContractorHomePageState extends State<ContractorHomePage> {
  final MapController _mapController = MapController();

  double _currentZoom = 14.5;
  LatLng _currentCenter = LatLng(36.7525, 3.0420);

  final List<LatLng> derangements = [
    LatLng(36.7538, 3.0588),
    LatLng(36.7495, 3.0420),
    LatLng(36.7555, 3.0515),
    LatLng(36.7478, 3.0602),
    LatLng(36.7512, 3.0470),
  ];

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
    });
    _mapController.move(_currentCenter, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
    });
    _mapController.move(_currentCenter, _currentZoom);
  }

  void _goToMyLocation() {
    setState(() {
      _currentCenter = LatLng(36.7525, 3.0420);
      _currentZoom = 16;
    });

    _mapController.move(_currentCenter, _currentZoom);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Localisation centrée (mode test)'),
      ),
    );
  }

  void _showDerangementInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InfoDerangementSheet(
        id: 'D-101',
        nom: 'Dérangement Fibre',
        typeService: 'Internet / Fibre',
        priorite: 'Haute',
        statut: 'En attente',
        adresse: 'Rue Didouche Mourad, Alger',
        clientNom: 'Client Test',
        clientTelephone: '0550 00 00 00',
        description:
            'Le client signale une coupure totale de la connexion fibre depuis ce matin.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppMenuDrawer(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _currentZoom,
              onPositionChanged: (position, hasGesture) {
                if (position.center != null) {
                  _currentCenter = position.center!;
                }
                if (position.zoom != null) {
                  _currentZoom = position.zoom!;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile_app',
              ),
              MarkerLayer(
                markers: [
                  ...derangements.map(
                    (point) => Marker(
                      point: point,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: _showDerangementInfo,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: _currentCenter,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF4E6CF1),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black87,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'IntervTrack',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil placeholder'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black87,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _MapActionButton(
                  icon: Icons.add,
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 10),
                _MapActionButton(
                  icon: Icons.remove,
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 10),
                _MapActionButton(
                  icon: Icons.my_location,
                  onTap: _goToMyLocation,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Dérangements affichés : ${derangements.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
