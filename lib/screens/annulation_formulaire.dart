import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../config/theme_provider.dart';
import '../services/api_service.dart';

class ReportProblemPage extends StatefulWidget {
  final int reclamationId;
  final String reclamationTitle;

  const ReportProblemPage({
    super.key,
    required this.reclamationId,
    required this.reclamationTitle,
  });

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController noteController = TextEditingController();

  bool isSubmitting = false;
  String? selectedMotif;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color bg = Color(0xFFF7FAFD);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  bool get isDark => context.watch<ThemeProvider>().isDark;

  Color get bgColor => isDark ? const Color(0xFF0F172A) : bg;
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get fieldColor =>
      isDark ? const Color(0xFF273549) : const Color(0xFFF0F4F8);
  Color get titleColor => isDark ? Colors.white : textDark;
  Color get softColor => isDark ? Colors.white70 : textSoft;
  Color get shadowColor =>
      isDark ? Colors.black.withOpacity(0.35) : deepBlue.withOpacity(0.08);

  String get todayText {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} - '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  List<String> _motifs(AppLocalizations t) => [
        t.clientAbsent,
        t.addressNotFound,
        t.accessImpossible,
        t.missingMaterial,
        t.externalFailure,
        t.other,
      ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    final currentMotif = selectedMotif ?? _motifs(t).first;
    final motif =
        currentMotif == t.other ? noteController.text.trim() : currentMotif;

    if (motif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.emptyReason),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Laravel génère le PDF et le stocke directement en BDD (LONGBLOB)
      await _apiService.sendAnnulationReport(
        reclamationId: widget.reclamationId,
        motif: motif,
        impact: '',
        actions: '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.reportSentSuccess),
          backgroundColor: green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 24 + bottomSafe),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 20),
                  _heroCard(),
                  const SizedBox(height: 20),
                  _formCard(),
                  const SizedBox(height: 24),
                  _submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        _roundButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            t.errorReport,
            style: TextStyle(
              color: titleColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
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
          BoxShadow(
            color: green.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.report_problem_outlined,
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
                  t.company,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.reclamationTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${t.systemDate} : $todayText',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    final t = AppLocalizations.of(context)!;
    selectedMotif ??= _motifs(t).first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: blue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.problemReason,
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          _motifDropdown(),
          if (selectedMotif == t.other) ...[
            const SizedBox(height: 16),
            _noteField(),
          ],
        ],
      ),
    );
  }

  Widget _motifDropdown() {
    final t = AppLocalizations.of(context)!;
    final motifs = _motifs(t);

    selectedMotif ??= motifs.first;
    if (!motifs.contains(selectedMotif)) {
      selectedMotif = motifs.first;
    }

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: blue.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMotif,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: blue),
          dropdownColor: cardColor,
          borderRadius: BorderRadius.circular(18),
          style: TextStyle(
            color: titleColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          items: motifs.map((motif) {
            return DropdownMenuItem(value: motif, child: Text(motif));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMotif = value ?? motifs.first;
            });
          },
        ),
      ),
    );
  }

  Widget _noteField() {
    final t = AppLocalizations.of(context)!;

    return TextField(
      controller: noteController,
      maxLines: 4,
      style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: t.describeProblem,
        hintStyle: TextStyle(color: softColor, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      ),
    );
  }

  Widget _submitButton() {
    final t = AppLocalizations.of(context)!;

    return _Pressable(
      child: GestureDetector(
        onTap: isSubmitting ? null : _submit,
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [deepBlue, blue, green],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.26),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        t.sendReport,
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
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: blue, size: 25),
        ),
      ),
    );
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