import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expediente_resultado_screen.dart';
import 'screens/nueva_busqueda_screen.dart';
import 'screens/bitacora_notarial_screen.dart';
import 'screens/planes_suscripcion_screen.dart';
import 'models/resultado_busqueda.dart';

void main() {
  runApp(const CotejoNotarialApp());
}

class CotejoNotarialApp extends StatefulWidget {
  const CotejoNotarialApp({super.key});

  @override
  State<CotejoNotarialApp> createState() => _CotejoNotarialAppState();
}

enum AppRoute { login, dashboard, nuevaBusqueda, expediente, bitacora, planes }

class _CotejoNotarialAppState extends State<CotejoNotarialApp> {
  AppRoute _currentRoute = AppRoute.login;
  String? _authToken;
  ResultadoBusqueda? _resultadoActivo;

  void _login(String token) {
    setState(() {
      _authToken = token;
      _currentRoute = AppRoute.dashboard;
    });
  }

  void _logout() {
    setState(() {
      _authToken = null;
      _currentRoute = AppRoute.login;
    });
  }

  void _navigateToNuevaBusqueda() {
    setState(() => _currentRoute = AppRoute.nuevaBusqueda);
  }

  void _navigateToExpediente(ResultadoBusqueda resultado) {
    setState(() {
      _resultadoActivo = resultado;
      _currentRoute = AppRoute.expediente;
    });
  }

  void _navigateToDashboard() {
    setState(() => _currentRoute = AppRoute.dashboard);
  }

  void _navigateToBitacora() {
    setState(() => _currentRoute = AppRoute.bitacora);
  }

  void _navigateToPlanes() {
    setState(() => _currentRoute = AppRoute.planes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotejo Notarial - Cumplimiento LFPIORPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentRoute),
          child: _buildCurrentScreen(),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case AppRoute.login:
        return LoginScreen(onLoginSuccess: _login);
      case AppRoute.dashboard:
        return DashboardScreen(
          token: _authToken!,
          onNavigateToSearch: _navigateToNuevaBusqueda,
          onNavigateToBitacora: _navigateToBitacora,
          onNavigateToPlanes: _navigateToPlanes,
          onSelectExpediente: _navigateToExpediente,
          onLogout: _logout,
        );
      case AppRoute.nuevaBusqueda:
        return NuevaBusquedaScreen(
          token: _authToken!,
          onBackToDashboard: _navigateToDashboard,
          onSearchResult: _navigateToExpediente,
        );
      case AppRoute.expediente:
        return ExpedienteResultadoScreen(
          token: _authToken!,
          resultado: _resultadoActivo!,
          onBackToDashboard: _navigateToDashboard,
          onNavigateToSearch: _navigateToNuevaBusqueda,
        );
      case AppRoute.bitacora:
        return BitacoraNotarialScreen(
          token: _authToken!,
          onBackToDashboard: _navigateToDashboard,
          onNavigateToSearch: _navigateToNuevaBusqueda,
          onSelectExpediente: _navigateToExpediente,
          onNavigateToPlanes: _navigateToPlanes,
          onLogout: _logout,
        );
      case AppRoute.planes:
        return PlanesSuscripcionScreen(
          onBackToDashboard: _navigateToDashboard,
          onNavigateToSearch: _navigateToNuevaBusqueda,
          onNavigateToBitacora: _navigateToBitacora,
          onLogout: _logout,
        );
    }
  }
}
