import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resultado_busqueda.dart';
import '../models/bitacora_entry.dart';
import '../services/api_service.dart';

class BitacoraNotarialScreen extends StatefulWidget {
  const BitacoraNotarialScreen({
    super.key,
    required this.token,
    required this.onBackToDashboard,
    required this.onNavigateToSearch,
    required this.onSelectExpediente,
    required this.onNavigateToPlanes,
    required this.onLogout,
  });

  final String token;
  final VoidCallback onBackToDashboard;
  final VoidCallback onNavigateToSearch;
  final ValueChanged<ResultadoBusqueda> onSelectExpediente;
  final VoidCallback onNavigateToPlanes;
  final VoidCallback onLogout;

  @override
  State<BitacoraNotarialScreen> createState() => _BitacoraNotarialScreenState();
}

// Maps a bitácora entry to this screen's filter keys. A discarded homonymy
// counts as resolved/"cleared" regardless of its original semáforo.
String _statusKeyFor(BitacoraEntry entry) {
  if (entry.homonimiaDescartada) return 'cleared';
  switch (entry.semaforo) {
    case Semaforo.verde:
      return 'cleared';
    case Semaforo.amarillo:
      return 'parcial';
    case Semaforo.rojo:
      return 'alerta';
  }
}

class _BitacoraNotarialScreenState extends State<BitacoraNotarialScreen> {
  int _activeNavIndex = 2; // Bitácora active
  String _filterStatus = 'todos';
  final _searchController = TextEditingController();
  late final ApiService _api = ApiService(widget.token);

  bool _loading = true;
  String? _error;
  List<BitacoraEntry> _allLogs = [];
  int? _cargandoDetalleId;

  @override
  void initState() {
    super.initState();
    _cargarBitacora();
  }

  Future<void> _cargarBitacora() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final historial = await _api.historial();
      if (!mounted) return;
      setState(() {
        _allLogs = historial;
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

  List<BitacoraEntry> get _filteredLogs {
    final query = _searchController.text.toLowerCase().trim();
    return _allLogs.where((item) {
      final matchesQuery = query.isEmpty ||
          item.queriedName.toLowerCase().contains(query) ||
          item.folio.toLowerCase().contains(query) ||
          (item.rfcBuscado ?? '').toLowerCase().contains(query);

      final matchesStatus = _filterStatus == 'todos' || _statusKeyFor(item) == _filterStatus;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    'Bitácora Notarial',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
                                _buildHeaderSection(),
                                const SizedBox(height: 24),
                                _buildKpiGrid(constraints.maxWidth),
                                const SizedBox(height: 24),
                                _buildFilterConsole(),
                                const SizedBox(height: 24),
                                _buildLogTableCard(),
                                const SizedBox(height: 28),
                                _buildGuidanceGrid(constraints.maxWidth),
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
                            gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.gavel, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('COTEJO', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5)),
                            Text('SAAS COMPLIANCE', style: GoogleFonts.inter(color: const Color(0xFF818CF8), fontWeight: FontWeight.w600, fontSize: 10, letterSpacing: 0.8)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Notaría Pública No. 143 • CDMX', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF1E293B)),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildNavItem(0, Icons.dashboard, 'Panel Principal', onTap: widget.onBackToDashboard, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(1, Icons.person_search, 'Nueva Búsqueda', onTap: widget.onNavigateToSearch, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(2, Icons.menu_book, 'Bitácora Notarial', isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(3, Icons.credit_card, 'Planes y Suscripción', onTap: widget.onNavigateToPlanes, isDrawer: isDrawer),
                  ],
                ),
              ),
            ],
          ),
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
                        decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lic. Mauro García Martínez', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                            Text('Notario Titular', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF34D399), fontWeight: FontWeight.w500)),
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
              Text('Fecha Oficial: 24 May 2024', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF475569))),
              const SizedBox(width: 24),
              Text('Sincronización Activa: SAT 69-B, OFAC, ONU (Al día)', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: widget.onNavigateToSearch,
            icon: const Icon(Icons.add, size: 17),
            label: Text('Nueva Consulta', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ART. 18 LFPIORPI • REGISTRO INALTERABLE SHA-256',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Firma Electrónica Avanzada Activa', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Bitácora Oficial de Búsquedas y Debida Diligencia',
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                'Registro inmutable de consultas preventivas realizadas por la Notaría Pública No. 143 de la CDMX.',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando archivo ZIP de certificados...')));
              },
              icon: const Icon(Icons.download, size: 18, color: Color(0xFF4F46E5)),
              label: Text('Certificados ZIP', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportando Bitácora UIF en formato Excel/CSV...')));
              },
              icon: const Icon(Icons.table_view, size: 18),
              label: Text('Exportar Bitácora UIF', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid(double width) {
    final total = _allLogs.length;
    final sinCoincidencia = _allLogs.where((e) => _statusKeyFor(e) == 'cleared').length;
    final parcial = _allLogs.where((e) => _statusKeyFor(e) == 'parcial').length;
    final alerta = _allLogs.where((e) => _statusKeyFor(e) == 'alerta').length;
    final pctVerde = total == 0 ? '0%' : '${(sinCoincidencia / total * 100).toStringAsFixed(1)}%';

    int crossAxisCount = width > 1200 ? 4 : (width > 600 ? 2 : 1);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildKpiCard('TOTAL COTEJOS', '$total', 'folios vigentes', Icons.balance, const Color(0xFF4F46E5)),
        _buildKpiCard('SIN COINCIDENCIA', '$sinCoincidencia', '$pctVerde verde', Icons.verified_user, const Color(0xFF10B981)),
        _buildKpiCard('COINCIDENCIA PARCIAL', '$parcial', 'requiere descarte', Icons.rule_folder, const Color(0xFFD97706)),
        _buildKpiCard('ALERTAS EXACTAS', '$alerta', 'bloqueo UIF', Icons.gavel, const Color(0xFFDC2626)),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
              Icon(icon, size: 22, color: color),
            ],
          ),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildFilterConsole() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                    hintText: 'Buscar por folio, compareciente, RFC, CURP o número de escritura...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterPill('todos', 'Todos (${_allLogs.length})'),
                  _buildFilterPill('cleared', 'Sin Coincidencia (${_allLogs.where((e) => _statusKeyFor(e) == 'cleared').length})'),
                  _buildFilterPill('parcial', 'Coincidencia Parcial (${_allLogs.where((e) => _statusKeyFor(e) == 'parcial').length})'),
                  _buildFilterPill('alerta', 'Alerta Exacta (${_allLogs.where((e) => _statusKeyFor(e) == 'alerta').length})'),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _filterStatus = 'todos';
                  });
                },
                icon: const Icon(Icons.restart_alt, size: 16, color: Color(0xFF64748B)),
                label: Text('Limpiar filtros', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String key, String label) {
    bool isSelected = _filterStatus == key;
    return InkWell(
      onTap: () => setState(() => _filterStatus = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildLogTableCard() {
    final logs = _filteredLogs;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Libro Auxiliar Digital Tomo 2024-C • Hash SHA-256 Verificado', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                Text('Mostrando ${logs.length} folios', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
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
                  TextButton(onPressed: _cargarBitacora, child: const Text('Reintentar')),
                ],
              ),
            )
          else if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No hay folios que coincidan con el filtro actual.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = logs[index];
                final visual = _estadoVisual(item.semaforo, item.matchCount, item.homonimiaDescartada);
                final cargando = _cargandoDetalleId == item.id;
                return InkWell(
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
                          child: Text(item.folio, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.queriedName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text(
                                item.rfcBuscado != null && item.rfcBuscado!.isNotEmpty ? 'RFC: ${item.rfcBuscado}' : 'Sin RFC',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(_formatFecha(item.queriedAt), style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
                        const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: visual.bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: visual.borderColor),
                          ),
                          child: Text(visual.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: visual.color)),
                        ),
                        const SizedBox(width: 12),
                        cargando
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : OutlinedButton(
                                onPressed: () => _abrirExpediente(item.id),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Dictamen', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final local = fecha.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  ({String status, Color color, Color bgColor, Color borderColor}) _estadoVisual(Semaforo semaforo, int matchCount, bool homonimiaDescartada) {
    if (homonimiaDescartada) {
      return (
        status: 'Homonimia Descartada',
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
      );
    }
    switch (semaforo) {
      case Semaforo.verde:
        return (
          status: 'Sin Coincidencia',
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
        );
      case Semaforo.amarillo:
        return (
          status: 'Coincidencia Parcial ($matchCount)',
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
        );
      case Semaforo.rojo:
        return (
          status: 'Alerta Bloqueada',
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFCA5A5),
        );
    }
  }

  Widget _buildGuidanceGrid(double width) {
    bool isWide = width >= 1024;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildGuidanceCard('Respaldo Decenal Notarial', 'Cada búsqueda genera un sello criptográfico inalterable que garantiza la constancia de hechos en la fecha del instrumento.'),
        ),
        if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
        Expanded(
          child: _buildGuidanceCard('Protocolo ante Alertamiento UIF', 'Las búsquedas marcadas con Alerta Exacta emiten automáticamente la plantilla del Informe en Cero o Aviso de Operación Inusual.'),
        ),
        if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
        Expanded(
          child: _buildGuidanceCard('Sincronización Automática', 'Padrón SAT 69-B y SDN OFAC sincronizados en tiempo real para reflejar la normatividad exacta al momento de la firma.'),
        ),
      ],
    );
  }

  Widget _buildGuidanceCard(String title, String body) {
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
              const Icon(Icons.policy_outlined, size: 18, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.4)),
        ],
      ),
    );
  }
}
