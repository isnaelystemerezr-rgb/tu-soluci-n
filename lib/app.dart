import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/ordenes_list_screen.dart';
import 'ui/screens/orden_detail_screen.dart';
import 'ui/screens/orden_form_screen.dart';
import 'ui/screens/inventario_screen.dart';
import 'ui/screens/historial_screen.dart';
import 'ui/screens/cliente_form_screen.dart';
import 'ui/screens/equipo_form_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/ordenes', builder: (_, __) => const OrdenesListScreen()),
    GoRoute(path: '/ordenes/nueva', builder: (_, __) => const OrdenFormScreen()),
    GoRoute(path: '/ordenes/:id', builder: (context, state) {
      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
      return OrdenDetailScreen(ordenId: id);
    }),
    GoRoute(path: '/inventario', builder: (_, __) => const InventarioScreen()),
    GoRoute(path: '/historial', builder: (_, __) => const HistorialScreen()),
    GoRoute(path: '/clientes/nueva', builder: (_, __) => const ClienteFormScreen()),
    GoRoute(path: '/equipos/nueva', builder: (_, __) => const EquipoFormScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tu Solution',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1F6FEB),
      ),
      routerConfig: router,
    );
  }
}
