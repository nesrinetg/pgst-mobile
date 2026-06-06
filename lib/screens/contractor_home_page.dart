import 'dart:async';
import '../services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../config/theme_provider.dart';
import '../models/intervention_pointer.dart';
import '../services/api_service.dart';
import 'info_derangement.dart';
import 'notifications_page.dart';

class ContractorHomePage extends StatefulWidget {
  final int? focusInterventionId;

  const ContractorHomePage({super.key, this.focusInterventionId});

  @override
  State<ContractorHomePage> createState() => _ContractorHomePageState();
}

class _ContractorHomePageState extends State<ContractorHomePage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  double _currentZoom = 14.5;
  LatLng _currentCenter = LatLng(36.7525, 3.0420);

  LatLng? myPosition;
  List<InterventionPointer> derangements = [];

  int unreadCount = 0;
  Timer? notificationTimer;

  late AnimationController _animController;
  late AnimationController _notifController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _buttonScale;
  late Animation<double> _notifJump;

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color textDark = Color(0xFF14213D);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _notifController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _notifJump = Tween<double>(begin: 1, end: 1.25).animate(
      CurvedAnimation(parent: _notifController, curve: Curves.elasticOut),
    );

    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.10), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _buttonScale = Tween<double>(begin: 0.90, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    loadNotifications();

    notificationTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => loadNotifications(),
    );

    _loadPointers();
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    _notifController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _moveTo(LatLng position, double zoom) {
    setState(() {
      _currentCenter = position;
      _currentZoom = zoom;
    });

    _mapController.move(position, zoom);
  }

  String _safe(String? value, String fallback) {
    return value != null && value.trim().isNotEmpty ? value : fallback;
  }

  Future<void> loadNotifications() async {
    try {
      final data = await _apiService.getSimpleNotifications();

      if (!mounted) return;

      final newCount = data.length;

      if (newCount > unreadCount) {
        _notifController.forward(from: 0);
      }

      setState(() {
        unreadCount = newCount;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _loadPointers() async {
    try {
      final data = await _apiService.getMapPointers();

      if (!mounted) return;

      setState(() => derangements = data);

      if (widget.focusInterventionId != null) {
        _focusOnInterventionById(widget.focusInterventionId!);
        return;
      }

      if (data.isNotEmpty) {
        final first = LatLng(data.first.latitude, data.first.longitude);
        _moveTo(first, _currentZoom);
      }
    } catch (e) {
      debugPrint('Erreur pointeurs: $e');
    }
  }

  void _zoomIn() => _moveTo(_currentCenter, _currentZoom + 1);

  void _zoomOut() => _moveTo(_currentCenter, _currentZoom - 1);

  Future<void> _goToMyLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    final myPos = LatLng(pos.latitude, pos.longitude);
    setState(() => myPosition = myPos);

    _moveTo(myPos, 16);
  }

  void _focusOnInterventionById(int interventionId) {
    try {
      final item = derangements.firstWhere((e) => e.id == interventionId);

      final target = LatLng(item.latitude, item.longitude);
      _moveTo(target, 17);

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _showDerangementInfo(item);
      });
    } catch (e) {
      debugPrint('Introuvable: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position introuvable')),
      );
    }
  }

  void _showDerangementInfo(InterventionPointer item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize: 0.50,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return InfoDerangementSheet(
            scrollController: scrollController,
            id: item.id.toString(),
            nom: _safe(item.typeReclamation, 'Dérangement'),
            typeService: _safe(item.typeReclamation, 'Service'),
            priorite: 'Haute',
            statut: _safe(item.statut, 'En attente'),
            adresse: _safe(item.adresse, 'Adresse indisponible'),
            clientNom: _safe(item.clientNom, 'Client inconnu'),
            clientTelephone: _safe(item.telephone, 'Téléphone indisponible'),
            description: _safe(item.description, 'Aucune description'),
            latitude: item.latitude,
            longitude: item.longitude,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    final buttonColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.35)
        : Colors.black.withOpacity(0.18);
    final normalIconColor = isDark ? Colors.white : textDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF7FAFD),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile_app',
              ),
              MarkerLayer(
                markers: [
                  ...derangements.map(
                    (item) => Marker(
                      point: LatLng(item.latitude, item.longitude),
                      width: 50,
                      height: 58,
                      child: GestureDetector(
                        onTap: () => _showDerangementInfo(item),
                        child: const _JumpingOldPointer(),
                      ),
                    ),
                  ),
                  if (myPosition != null)
                    Marker(
                      point: myPosition!,
                      width: 56,
                      height: 56,
                      child: const Icon(
                        Icons.my_location,
                        color: blue,
                        size: 38,
                      ),
                    ),
                ],
              ),
            ],
          ),
          _topHeader(),
          Positioned(
            right: 15,
            bottom: 185,
            child: ScaleTransition(
              scale: _buttonScale,
              child: Column(
                children: [
                  _MapActionButton(
                    icon: Icons.add,
                    onTap: _zoomIn,
                    buttonColor: buttonColor,
                    shadowColor: shadowColor,
                    iconColor: normalIconColor,
                  ),
                  const SizedBox(height: 9),
                  _MapActionButton(
                    icon: Icons.remove,
                    onTap: _zoomOut,
                    buttonColor: buttonColor,
                    shadowColor: shadowColor,
                    iconColor: normalIconColor,
                  ),
                  const SizedBox(height: 9),
                  _MapActionButton(
                    icon: Icons.my_location,
                    onTap: _goToMyLocation,
                    buttonColor: buttonColor,
                    shadowColor: shadowColor,
                    iconColor: blue,
                    isLocation: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _headerFade,
        child: SlideTransition(
          position: _headerSlide,
          child: Container(
            padding: EdgeInsets.fromLTRB(18, topPadding + 12, 16, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [deepBlue, blue, green],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: deepBlue.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'IntervTrack',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                _notificationButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _notifJump,
          builder: (context, child) {
            return Transform.scale(
              scale: _notifJump.value,
              child: child,
            );
          },
          child: Material(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );

                await loadNotifications();
              },
              child: const SizedBox(
                width: 50,
                height: 50,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -5,
            top: -6,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(unreadCount),
              tween: Tween(begin: 0.75, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 23,
                  minHeight: 23,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _JumpingOldPointer extends StatefulWidget {
  const _JumpingOldPointer();

  @override
  State<_JumpingOldPointer> createState() => _JumpingOldPointerState();
}

class _JumpingOldPointerState extends State<_JumpingOldPointer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jump;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _jump = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _jump,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _jump.value),
          child: child,
        );
      },
      child: const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 42,
      ),
    );
  }
}

class _MapActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLocation;
  final Color buttonColor;
  final Color shadowColor;
  final Color iconColor;

  const _MapActionButton({
    required this.icon,
    required this.onTap,
    required this.buttonColor,
    required this.shadowColor,
    required this.iconColor,
    this.isLocation = false,
  });

  @override
  State<_MapActionButton> createState() => _MapActionButtonState();
}

class _MapActionButtonState extends State<_MapActionButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.92),
        onTapUp: (_) => setState(() => _scale = 1),
        onTapCancel: () => setState(() => _scale = 1),
        onTap: widget.onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: widget.buttonColor,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.isLocation ? 27 : 31,
          ),
        ),
      ),
    );
  }
}