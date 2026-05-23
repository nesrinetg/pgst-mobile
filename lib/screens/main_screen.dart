import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme_provider.dart';
import 'contractor_home_page.dart';
import 'interventions_page.dart';
import 'kpi_page.dart';
import 'account_page.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int? focusInterventionId;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.focusInterventionId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late List<Widget> _pages;

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);

  final List<_NavItem> _items = const [
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Carte',
    ),
    _NavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Interventions',
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'KPI',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Compte',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    _pages = [
      ContractorHomePage(
        focusInterventionId: widget.focusInterventionId,
      ),
      const InterventionsPage(),
      const KpiPage(),
      const AccountPage(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  void goToTab(int index) {
    setState(() => _selectedIndex = index);
    _controller.forward(from: 0);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusInterventionId != widget.focusInterventionId ||
        oldWidget.initialIndex != widget.initialIndex) {
      _pages = [
        ContractorHomePage(
          focusInterventionId: widget.focusInterventionId,
        ),
        const InterventionsPage(),
        const KpiPage(),
        const AccountPage(),
      ];

      _selectedIndex = widget.initialIndex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    final bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF7FAFD);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: _buildLuxuryMenu(),
    );
  }

  Widget _buildLuxuryMenu() {
    final isDark = context.watch<ThemeProvider>().isDark;

    final cardColor =
        isDark ? const Color(0xFF1E293B) : Colors.white;

    final textSoft =
        isDark ? Colors.white70 : const Color(0xFF7B8794);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : deepBlue.withOpacity(0.13),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
          border: Border.all(
            color: blue.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final selected = _selectedIndex == index;
            final item = _items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              deepBlue,
                              blue,
                              green,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: blue.withOpacity(0.22),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: green.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: AnimatedScale(
                    scale: selected ? 1.04 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? Colors.white : textSoft,
                          size: selected ? 25 : 23,
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            color: selected ? Colors.white : textSoft,
                            fontSize: selected ? 12.5 : 11.5,
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}