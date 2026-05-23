import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../config/theme_provider.dart';
import '../services/api_service.dart';
import 'camera_confirmation.dart';
import 'annulation_formulaire.dart';

class InfoDerangementSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String id;
  final String nom;
  final String typeService;
  final String priorite;
  final String statut;
  final String adresse;
  final String clientNom;
  final String clientTelephone;
  final String description;
  final double latitude;
  final double longitude;

  const InfoDerangementSheet({
    super.key,
    required this.scrollController,
    required this.id,
    required this.nom,
    required this.typeService,
    required this.priorite,
    required this.statut,
    required this.adresse,
    required this.clientNom,
    required this.clientTelephone,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<InfoDerangementSheet> createState() => _InfoDerangementSheetState();
}

class _InfoDerangementSheetState extends State<InfoDerangementSheet>
    with SingleTickerProviderStateMixin {
  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color orange = Color(0xFFFF9F1C);
  static const Color red = Color(0xFFE53935);
  static const Color purple = Color(0xFF9B5DE5);
  static const Color bg = Color(0xFFF7FAFD);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  final ApiService _apiService = ApiService();
  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  bool get isOpen {
    final s = widget.statut.trim().toLowerCase();
    return s == 'ouverte' || s == 'ouvert' || s == 'open';
  }

  bool get isInProgress {
    final s = widget.statut.trim().toLowerCase();
    return s == 'en_cours' || s == 'encours' || s == 'en cours';
  }

  bool get isDark => context.watch<ThemeProvider>().isDark;
  Color get sheetBg => isDark ? const Color(0xFF0F172A) : bg;
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get titleColor => isDark ? Colors.white : textDark;
  Color get softColor => isDark ? Colors.white70 : textSoft;
  Color get dividerColor =>
      isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
  Color get shadowColor =>
      isDark ? Colors.black.withOpacity(0.35) : deepBlue.withOpacity(0.07);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openItinerary() async {
    final t = AppLocalizations.of(context)!;

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&travelmode=driving',
    );

    final geoUrl = Uri.parse(
      'geo:${widget.latitude},${widget.longitude}?q=${widget.latitude},${widget.longitude}',
    );

    if (await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      return;
    }

    if (await launchUrl(geoUrl, mode: LaunchMode.externalApplication)) {
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.routeError)),
    );
  }

  Future<void> _callClient() async {
    final t = AppLocalizations.of(context)!;
    final phone = widget.clientTelephone.trim();

    if (phone.isEmpty || phone == 'Téléphone indisponible') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.phoneUnavailable)),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.callError)),
    );
  }

  Future<void> _startWork() async {
    final t = AppLocalizations.of(context)!;
    final id = int.tryParse(widget.id);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidId)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _apiService.startReclamation(id);

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.started)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openCamera() {
    final t = AppLocalizations.of(context)!;
    final id = int.tryParse(widget.id);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidId)),
      );
      return;
    }

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(reclamationId: id),
      ),
    );
  }

  void _reportProblem() {
    final t = AppLocalizations.of(context)!;
    final id = int.tryParse(widget.id);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidId)),
      );
      return;
    }

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportProblemPage(
          reclamationId: id,
          reclamationTitle: widget.nom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.93,
            ),
            padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomSafe),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
            ),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dragHandle(),
                  _heroHeader(),
                  const SizedBox(height: 16),
                  _detailsBox(),
                  const SizedBox(height: 18),
                  _descriptionBox(),
                  const SizedBox(height: 20),
                  _gradientButton(
                    label: t.itinerary,
                    icon: Icons.navigation_rounded,
                    colors: const [deepBlue, blue, green],
                    onTap: _openItinerary,
                  ),
                  const SizedBox(height: 14),
                  _actionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _heroHeader() {
    final t = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepBlue, blue, green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: blue.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${t.reclamation} #${widget.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _priorityBadge(widget.priorite),
        ],
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    final color = _priorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _detailsBox() {
    final t = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(t.serviceType, widget.typeService, Icons.build_outlined),
          _divider(),
          _infoRow(t.status, widget.statut, Icons.sync_rounded),
          _divider(),
          _infoRow(t.address, widget.adresse, Icons.place_outlined),
          _divider(),
          _infoRow(t.client, widget.clientNom, Icons.person_outline_rounded),
          _divider(),
          _infoRow(t.phone, widget.clientTelephone, Icons.call_outlined),
        ],
      ),
    );
  }

  Widget _descriptionBox() {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.description,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Text(
            widget.description,
            style: TextStyle(
              fontSize: 15,
              color: softColor,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    final t = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(color: blue),
        ),
      );
    }

    if (isOpen) {
      return Row(
        children: [
          Expanded(
            child: _solidActionButton(
              label: t.call,
              icon: Icons.call_rounded,
              color: blue,
              onTap: _callClient,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _solidActionButton(
              label: t.start,
              icon: Icons.play_arrow_rounded,
              color: green,
              onTap: _startWork,
            ),
          ),
        ],
      );
    }

    if (isInProgress) {
      return Row(
        children: [
          Expanded(
            child: _solidActionButton(
              label: t.problem,
              icon: Icons.report_problem_outlined,
              color: purple,
              onTap: _reportProblem,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _solidActionButton(
              label: t.camera,
              icon: Icons.camera_alt_outlined,
              color: green,
              onTap: _openCamera,
            ),
          ),
        ],
      );
    }

    return _solidActionButton(
      label: t.close,
      icon: Icons.close_rounded,
      color: red,
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return _Pressable(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.24),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _solidActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _Pressable(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    final isStatus = label.toLowerCase().contains('statut') ||
        label.toLowerCase().contains('status') ||
        label.contains('الحالة');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: blue, size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              '$label :',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: titleColor,
                fontSize: 14.5,
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: _statusChip(value),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: softColor,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value) {
    final color = _statusColor(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 8, color: dividerColor);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: blue.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return red;
      case 'moyenne':
        return orange;
      case 'basse':
        return green;
      default:
        return blue;
    }
  }

  Color _statusColor(String statut) {
    final s = statut.toLowerCase();

    if (s.contains('cours')) return blue;
    if (s.contains('term')) return green;
    if (s.contains('fermee')) return green;
    if (s.contains('resolue')) return green;
    if (s.contains('ouvert')) return orange;
    return textSoft;
  }
}

class _Pressable extends StatefulWidget {
  final Widget child;

  const _Pressable({required this.child});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) => setState(() => _scale = 1),
        onTapCancel: () => setState(() => _scale = 1),
        child: widget.child,
      ),
    );
  }
}