import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/motion.dart';
import '../models/resultado_busqueda.dart';
import '../models/bitacora_entry.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.token,
    required this.onNavigateToSearch,
    required this.onNavigateToBitacora,
    required this.onNavigateToPlanes,
    required this.onSelectExpediente,
    required this.onLogout,
  });

  final String token;
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToBitacora;
  final VoidCallback onNavigateToPlanes;
  final ValueChanged<ResultadoBusqueda> onSelectExpediente;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeNavIndex = 0;
  late final ApiService _api = ApiService(widget.token);

  bool _loading = true;
  String? _error;
  List<BitacoraEntry> _recentSearches = [];
  int? _cargandoDetalleId;

  @override
  void initState() {
    super.initState();
    _cargarBusquedas();
  }

  Future<void> _cargarBusquedas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final historial = await _api.historial();
      if (!mounted) return;
      setState(() {
        _recentSearches = historial.take(5).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _abrirExpediente(int searchId) async {
    setState(() => _cargandoDetalleId = searchId);
    try {
      final resultado = await _api.detalle(searchId);
      if (!mounted) return;
      widget.onSelectExpediente(resultado);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cargandoDetalleId = null);
    }
  }

  Future<void> _imprimirDesdeHistorial(int searchId) async {
    setState(() => _cargandoDetalleId = searchId);
    try {
      final resultado = await _api.detalle(searchId);
      await imprimirFichaNotarial(resultado);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cargandoDetalleId = null);
    }
  }

  ({String status, Color color, Color bgColor, Color borderColor}) _estadoVisual(BitacoraEntry entry) {
    if (entry.homonimiaDescartada) {
      return (
        status: 'Homonimia descartada',
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
      );
    }
    switch (entry.semaforo) {
      case Semaforo.verde:
        return (
          status: 'Sin coincidencia',
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
        );
      case Semaforo.amarillo:
        return (
          status: 'Coincidencia parcial (${entry.matchCount})',
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
        );
      case Semaforo.rojo:
        return (
          status: 'Alerta - coincidencia confirmada',
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFCA5A5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1024;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          drawer: isDesktop ? null : _buildSidebar(isDrawer: true),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    'Cotejo Notarial',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5)),
                      onPressed: widget.onNavigateToSearch,
                    ),
                  ],
                ),
          body: Row(
            children: [
              if (isDesktop) _buildSidebar(isDrawer: false),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop) _buildTopHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGreetingHeader(),
                                const SizedBox(height: 24),
                                _buildHeroCtaBanner(),
                                const SizedBox(height: 24),
                                _buildKpiGrid(constraints.maxWidth),
                                const SizedBox(height: 28),
                                _buildMainGrid(constraints.maxWidth),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar({required bool isDrawer}) {
    final sidebarContent = Container(
      width: 256,
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Logo header
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 28, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.gavel, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COTEJO',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'SAAS COMPLIANCE',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF818CF8),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Notaría Pública No. 143',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 6),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF64748B), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'CDMX',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF1E293B)),

              // Navigation Links
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildNavItem(0, Icons.dashboard, 'Panel Principal', isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(1, Icons.person_search, 'Nueva Búsqueda', onTap: widget.onNavigateToSearch, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(2, Icons.menu_book, 'Bitácora Notarial', onTap: widget.onNavigateToBitacora, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(3, Icons.credit_card, 'Planes y Suscripción', onTap: widget.onNavigateToPlanes, isDrawer: isDrawer),
                  ],
                ),
              ),
            ],
          ),

          // User Card & Logout
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF172033).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.7)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lic. Mauro García Martínez',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Notario Titular',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF34D399), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout, size: 15, color: Color(0xFF94A3B8)),
                      label: Text('Cerrar Sesión', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return isDrawer ? Drawer(child: sidebarContent) : sidebarContent;
  }

  Widget _buildNavItem(int index, IconData icon, String label, {VoidCallback? onTap, bool isDrawer = false}) {
    bool isActive = _activeNavIndex == index;
    return InkWell(
      onTap: () {
        if (isDrawer) Navigator.of(context).pop();
        setState(() => _activeNavIndex = index);
        if (onTap != null) onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isActive ? Colors.white : const Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 17, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(
                'Fecha Oficial: 24 May 2024',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Sincronización Activa: ', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text('SAT 69-B, OFAC, ONU', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: widget.onNavigateToSearch,
                icon: const Icon(Icons.add, size: 17),
                label: Text('Nueva Consulta', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.notifications_outlined, size: 18, color: Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              child: Text(
                'EXPEDIENTE MATRIZ LFPIORPI',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA)),
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: GoogleFonts.inter(color: const Color(0xFFCBD5E1))),
            const SizedBox(width: 8),
            Text(
              'Folio Notarial Activo: 2024-Q4',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            children: [
              const TextSpan(text: 'Bienvenido, Lic. García '),
              TextSpan(
                text: '• Notaría Pública No. 143 de la CDMX',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.normal, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Plataforma institucional de debida diligencia, cotejo preventivo y certificación registral en prevención de lavado de dinero.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildHeroCtaBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF172033), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.verified_user, color: Color(0xFF818CF8), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'PROTOCOLO PRE-FIRMA',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA5B4FC)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Art. 18 Fracc. IV LFPIORPI',
                            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Validación Preventiva de Comparecientes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cotejo en tiempo real contra listas vinculantes OFAC (SDN List), Consejo de Seguridad ONU, SAT 69-B (EFOS) y catálogo PEP México previo a escrituración.',
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFCBD5E1), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: widget.onNavigateToSearch,
            icon: const Icon(Icons.person_search, size: 20),
            label: Text('Iniciar Nueva Búsqueda', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(double width) {
    int crossAxisCount = width > 1200 ? 4 : (width > 600 ? 2 : 1);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        staggerIn(0, _buildKpiCard('BÚSQUEDAS HOY', '18', 'consultas', Icons.query_stats, const Color(0xFF4F46E5), '+12% vs jornada previa')),
        staggerIn(1, _buildKpiCard('ACUMULADO MES', '342', 'cotejos notariales', Icons.folder_shared, const Color(0xFF2563EB), 'Promedio: 14.2 actos/día')),
        staggerIn(2, _buildKpiCard('ALERTAS MES', '2', 'casos bajo análisis', Icons.notification_important, const Color(0xFFD97706), '100% homonimias descartadas')),
        staggerIn(3, _buildKpiCard('CERTIFICADOS PDF', '340', 'constancias sello', Icons.workspace_premium, const Color(0xFF059669), 'Archivados en apéndice')),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, String unit, IconData icon, Color color, String footer) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          Text(
            footer,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainGrid(double width) {
    bool isWide = width >= 1024;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isWide ? 8 : 1,
          child: Column(
            children: [
              _buildTableCard(),
              const SizedBox(height: 16),
              _buildComplianceNote(),
            ],
          ),
        ),
        if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),
        SizedBox(
          width: isWide ? 340 : double.infinity,
          child: Column(
            children: [
              _buildSourcesStatusCard(),
              const SizedBox(height: 20),
              _buildBatchWidget(),
              const SizedBox(height: 20),
              _buildCircularBanner(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment, size: 20, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        Text(
                          'Últimas Búsquedas Notariales',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registro estricto con folio de consulta, hash criptográfico y semáforo.',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: widget.onNavigateToSearch,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text('Nueva', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (_loading)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB91C1C)))),
                  TextButton(onPressed: _cargarBusquedas, child: const Text('Reintentar')),
                ],
              ),
            )
          else if (_recentSearches.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Aún no hay búsquedas registradas.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = _recentSearches[index];
                final visual = _estadoVisual(item);
                final cargando = _cargandoDetalleId == item.id;
                return staggerIn(index, InkWell(
                  onTap: cargando ? null : () => _abrirExpediente(item.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE0E7FF)),
                          ),
                          child: Text(
                            item.folio,
                            style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.queriedName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                              Text(
                                item.rfcBuscado != null && item.rfcBuscado!.isNotEmpty ? 'RFC: ${item.rfcBuscado}' : 'Sin RFC',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: visual.bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: visual.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: visual.color, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(
                                visual.status,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: visual.color),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        cargando
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Color(0xFF475569)),
                                onPressed: () => _imprimirDesdeHistorial(item.id),
                                tooltip: 'Descargar PDF',
                              ),
                      ],
                    ),
                  ),
                ));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildComplianceNote() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.policy_outlined, size: 24, color: Color(0xFF4F46E5)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aviso de Responsabilidad Notarial (LFPIORPI)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Text(
                  'Los certificados integran sellos digitales e inmutabilidad para acreditar la debida diligencia previa ante requerimientos de la UIF.',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sync, size: 18, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Text('Fuentes Oficiales', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 14),
          _buildSourceRow('Lista OFAC (SDN)', 'Dept. Tesoro EE.UU.', 'Al día'),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildSourceRow('Consejo Seg. ONU', 'Resoluciones vinc.', 'Al día'),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildSourceRow('SAT Art. 69-B', 'EFOS definitivos', 'DOF Sinc'),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildSourceRow('PEP México', 'Servidores públicos', 'Monitoreo'),
        ],
      ),
    );
  }

  Widget _buildSourceRow(String name, String detail, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            Text(detail, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Text(status, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF047857))),
        ),
      ],
    );
  }

  Widget _buildBatchWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.batch_prediction_outlined, size: 18, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text('Cotejo por Lote', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(Icons.upload_file, size: 28, color: Color(0xFF64748B)),
                const SizedBox(height: 6),
                Text('Cargar CSV / XLSX', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Hasta 200 comparecientes', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, size: 16, color: Color(0xFF4F46E5)),
              const SizedBox(width: 6),
              Text('CIRCULAR NOTARIAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA))),
            ],
          ),
          const SizedBox(height: 4),
          Text('Criterios UIF 2024 / Actividades Vulnerables', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text('La verificación de titulares reales es obligatoria en poderes especiales irrevocables.', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
        ],
      ),
    );
  }
}
