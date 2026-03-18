import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'log_period_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    InsightsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final bg = storage.isMinimalMode
        ? AppTheme.backgroundGradientMinimal
        : AppTheme.backgroundGradient;

    return Container(
      decoration: BoxDecoration(gradient: bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        drawer: _buildDrawer(context, storage),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          title: ShaderMask(
            shaderCallback: (b) => AppTheme.titleGradient.createShader(b),
            child: Text(
              'Her-Flowmate',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: _screens[_selectedIndex],
        floatingActionButton: _selectedIndex == 0 ? Animate(
        effects: const [
          ScaleEffect(
            begin: Offset(0.9, 0.9), // Fix syntax for v4
            end: Offset(1.0, 1.0),
            curve: Curves.easeOutBack,
            duration: Duration(milliseconds: 800),
          ),
          ShimmerEffect(
            duration: Duration(seconds: 3),
            color: Colors.white24,
          ),
        ],
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const LogPeriodScreen(),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [Color(0xFF00FFFF), Color(0xFFFF00AA), Color(0xFFAA00FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
          ),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, StorageService storage) {
    final initial = storage.userName.isNotEmpty ? storage.userName[0].toUpperCase() : 'U';
    
    return Drawer(
      backgroundColor: Colors.transparent,
      child: AppTheme.glassBlur(
        sigmaX: 24,
        sigmaY: 24,
        borderRadius: 0,
        child: Container(
          color: Colors.black.withValues(alpha: 0.2), // Dark tint over blur
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonPurple.withValues(alpha: 0.3), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: AppTheme.glassDecoration(
                        borderRadius: 24,
                        glowColor: AppTheme.neonPink,
                        glowOpacity: 0.25,
                      ),
                      child: AppTheme.glassBlur(
                        borderRadius: 24,
                        child: Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hi, ${storage.userName}',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Links
              _drawerItem(icon: Icons.home_rounded, title: 'Home', index: 0),
              _drawerItem(icon: Icons.lightbulb_rounded, title: 'Insights', index: 1),
              _drawerItem(icon: Icons.history_rounded, title: 'History', index: 2),
              _drawerItem(icon: Icons.person_rounded, title: 'Profile', index: 3),
              
              const Divider(color: Colors.white24, height: 32, thickness: 1, indent: 16, endIndent: 16),

              // Toggles and Settings
              ListTile(
                leading: Icon(
                  storage.isMinimalMode ? Icons.motion_photos_paused_outlined : Icons.animation,
                  color: AppTheme.neonGreen,
                ),
                title: Text(storage.isMinimalMode ? 'Vivid Theme' : 'Minimal Theme', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
                onTap: () {
                  storage.toggleMinimalMode();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded, color: AppTheme.neonCyan),
                title: Text('Settings', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
                onTap: () {
                  // TODO: Navigation to Settings Screen
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, required int index}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.neonPink : Colors.white70),
      title: Text(
        title, 
        style: GoogleFonts.outfit(
          color: isSelected ? Colors.white : Colors.white70, 
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.neonPink.withValues(alpha: 0.1),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}
