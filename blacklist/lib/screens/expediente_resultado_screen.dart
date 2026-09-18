import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/motion.dart';
import '../models/resultado_busqueda.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';

class ExpedienteResultadoScreen extends StatefulWidget {
  const ExpedienteResultadoScreen({
    super.key,
    required this.token,
    required this.resultado,
    required this.onBackToDashboard,
    required this.onNavigateToSearch,
  });

  final String token;
  final ResultadoBusqueda resultado;
  final VoidCallback onBackToDashboard;
  final VoidCallback onNavigateToSearch;

  @override
  State<ExpedienteResultadoScreen> createState() => _ExpedienteResultadoScreenState();
}

class _ExpedienteResultadoScreenState extends State<ExpedienteResultadoScreen> {
  late bool _homonimiaDescartada;
  bool _generandoPdf = false;
  bool _guardandoDescarte = false;
  late final TextEditingController _justificacionController;
  late final ApiService _api = ApiService(widget.token);

  ResultadoBusqueda get _r => widget.resultado;
  bool get _tieneCoincidencias => _r.coincidencias.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _homonimiaDescartada = _r.homonimiaDescartada;
    final topMatch = _r.coincidencias.isNotEmpty ? _r.coincidencias.first : null;
    _justificacionController = TextEditingController(
      text: _r.justificacionDescarte ??
          (topMatch == null
              ? ''
              : 'Se verifica que el compareciente ${_r.nombreBuscado} difiere en identidad plena '
                  '(RFC/CURP, filiación y demás datos de identificación) respecto al registro '
                  '"${topMatch.nombreCoincidente}" localizado en ${topMatch.lista}.'),
    );
  }

  Future<void> _descargarPdf() async {
    setState(() => _generandoPdf = true);
    try {
      await imprimirFichaNotarial(_r);
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  Future<void> _confirmarDescarte(BuildContext dialogContext, StateSetter setDialogState) async {
    final justificacion = _justificacionController.text.trim();
    if (justificacion.isEmpty) return;

    setDialogState(() => _guardandoDescarte = true);
    try {
      await _api.descartarHomonimia(_r.searchId, justificacion);
      if (!mounted) return;
      setState(() => _homonimiaDescartada = true);
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Homonimia formalmente descartada y asentada en el expediente.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } on ApiException catch (e) {
      setDialogState(() => _guardandoDescarte = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _showDescarteModal() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descarte Notarial de Homonimia',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  Text(
                    'Expediente ${_r.folio}',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como fedatario público, asiente la motivación legal que desvirtúa la identidad del compareciente respecto al individuo listado, para anexar al apéndice del instrumento.',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569), height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'JUSTIFICACIÓN EN EL PROTOCOLO NOTARIAL',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _justificacionController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _guardandoDescarte ? null : () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: _guardandoDescarte ? null : () => _confirmarDescarte(context, setDialogState),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _guardandoDescarte
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Firmar y Asentar Descarte', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
        });
      },
    );
  }

  @override
  void dispose() {
    _justificacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1024;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBackToDashboard,
                  ),
                  title: Text(
                    'Expediente ${_r.folio}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
          body: Column(
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
                          staggerIn(0, _buildExpedienteHeader()),
                          const SizedBox(height: 24),
                          staggerIn(1, _buildTrafficLightHero()),
                          const SizedBox(height: 24),
                          staggerIn(2, _buildActionToolbar()),
                          const SizedBox(height: 28),
                          staggerIn(3, _buildAuditCardsGrid(constraints.maxWidth)),
                          const SizedBox(height: 28),
                          staggerIn(4, _buildLegalValiditySection()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                onPressed: widget.onBackToDashboard,
                tooltip: 'Volver al Panel Principal',
              ),
              const SizedBox(width: 8),
              Text(
                'Expediente Regulatorio ${_r.folio}',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: widget.onNavigateToSearch,
            icon: const Icon(Icons.add, size: 17),
            label: Text('Nueva Consulta', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpedienteHeader() {
    final fecha = _r.queriedAt.toLocal();
    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} • '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')} hrs';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Color(0xFFA5B4FC), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'FOLIO REGULATORIO ${_r.folio}',
                            style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LFPIORPI / Art. 17 Fracc. XII',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _r.nombreBuscado.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _r.rfcBuscado != null && _r.rfcBuscado!.isNotEmpty
                      ? 'RFC/CURP consultado: ${_r.rfcBuscado}'
                      : 'Sin RFC/CURP proporcionado en la consulta.',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _r.notariaId ?? 'Notaría',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                Text(
                  'Consulta #${_r.searchId}',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  fechaTexto,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLightHero() {
    final resuelto = _homonimiaDescartada;
    final Color mainColor = resuelto
        ? const Color(0xFF10B981)
        : switch (_r.semaforo) {
            Semaforo.verde => const Color(0xFF10B981),
            Semaforo.amarillo => const Color(0xFFD97706),
            Semaforo.rojo => const Color(0xFFDC2626),
          };

    final String statusTitle = resuelto
        ? 'Sin Coincidencia (Homonimia Descartada)'
        : switch (_r.semaforo) {
            Semaforo.verde => 'Sin Coincidencia',
            Semaforo.amarillo => 'Coincidencia Parcial / Alerta',
            Semaforo.rojo => 'Alerta Bloqueada - Coincidencia Confirmada',
          };

    final int scorePct = ((resuelto ? 0.0 : _r.score) * 100).round();
    final String badgeText = resuelto
        ? 'DESCARTE ASENTADO'
        : switch (_r.semaforo) {
            Semaforo.verde => 'SIN ALERTA',
            Semaforo.amarillo => 'ACTIVO NOTARIAL ($scorePct% MATCH)',
            Semaforo.rojo => 'BLOQUEO REQUERIDO ($scorePct% MATCH)',
          };

    final String descripcion = resuelto
        ? 'El fedatario público ha asentado la fundamentación legal para desvirtuar la homonimia con base en documentos fehacientes (INE, RFC y Acta de Nacimiento).'
        : switch (_r.semaforo) {
            Semaforo.verde =>
              'No se encontraron coincidencias relevantes contra las listas regulatorias consultadas (OFAC SDN, SAT Art. 69-B). El compareciente puede continuar el proceso de escrituración.',
            Semaforo.amarillo =>
              'Se identificó homonimia relevante con un registro activo en listas regulatorias. Conforme al protocolo del Colegio de Notarios y la UIF, el fedatario debe constatar la identidad plena mediante documento idóneo antes de escriturar.',
            Semaforo.rojo =>
              'Se identificó una coincidencia de alta confianza (posible identidad exacta) con un registro activo en listas regulatorias. Se recomienda suspender el acto y notificar a la UIF conforme al protocolo aplicable.',
          };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mainColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 3 Traffic Light Steps Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTrafficStep('Nivel 1', 'Sin Coincidencia', resuelto || _r.semaforo == Semaforo.verde, const Color(0xFF10B981)),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                Expanded(
                  child: _buildTrafficStep('Nivel 2', 'Coincidencia Parcial', !resuelto && _r.semaforo == Semaforo.amarillo, const Color(0xFFD97706)),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                Expanded(
                  child: _buildTrafficStep('Nivel 3', 'Bloqueo Inmediato', !resuelto && _r.semaforo == Semaforo.rojo, const Color(0xFFDC2626)),
                ),
              ],
            ),
          ),

          // Banner Body
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: mainColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            resuelto || _r.semaforo == Semaforo.verde ? Icons.check_circle : Icons.warning_amber_rounded,
                            key: ValueKey('$resuelto-${_r.semaforo}'),
                            color: mainColor,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: mainColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: mainColor.withValues(alpha: 0.3)),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  badgeText,
                                  key: ValueKey(badgeText),
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: mainColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                statusTitle,
                                key: ValueKey(statusTitle),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                descripcion,
                                key: ValueKey(descripcion),
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        ),
                        child: Text(
                          '$scorePct%',
                          key: ValueKey(scorePct),
                          style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: mainColor),
                        ),
                      ),
                      Text(
                        'ÍNDICE MATCH',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficStep(String level, String title, bool isActive, Color color) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      opacity: isActive ? 1.0 : 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: isActive ? color : const Color(0xFF94A3B8), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.balance, color: Color(0xFF4F46E5), size: 20),
              const SizedBox(width: 10),
              Text(
                'Acciones del Protocolo Notarial',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _generandoPdf ? null : _descargarPdf,
                icon: _generandoPdf
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.picture_as_pdf, size: 18),
                label: Text(
                  _generandoPdf ? 'Generando...' : 'Descargar Ficha PDF',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_tieneCoincidencias && !_homonimiaDescartada)
                OutlinedButton.icon(
                  onPressed: _showDescarteModal,
                  icon: const Icon(Icons.fact_check_outlined, size: 18, color: Color(0xFF475569)),
                  label: Text(
                    'Descartar Homonimia (Justificación)',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (_homonimiaDescartada)
                OutlinedButton.icon(
                  onPressed: _showDescarteModal,
                  icon: const Icon(Icons.edit_note, size: 18, color: Color(0xFF475569)),
                  label: Text(
                    'Editar Justificación Legal',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCardsGrid(double width) {
    bool isWide = width >= 1024;

    if (!_tieneCoincidencias) {
      return _buildAuditCard(
        title: 'Listas Regulatorias Consultadas',
        subtitle: 'OFAC SDN • SAT Art. 69-B',
        status: 'Sin Coincidencia (0%)',
        statusColor: const Color(0xFF10B981),
        icon: Icons.verified_user,
        details: const [
          'No se localizó ningún registro con similitud relevante de nombre o RFC.',
          'El compareciente puede continuar el proceso de escrituración.',
        ],
      );
    }

    final cards = _r.coincidencias
        .map(
          (c) => _buildAuditCard(
            title: c.lista,
            subtitle: c.tipoLista,
            status: '${(c.score * 100).toStringAsFixed(0)}% Match',
            statusColor: c.score >= 0.85 ? const Color(0xFFDC2626) : const Color(0xFFD97706),
            icon: Icons.gavel,
            details: [
              'Nombre Registrado: ${c.nombreCoincidente.toUpperCase()}',
              'Campos coincidentes: ${c.camposCoincidentes.join(', ')}',
            ],
          ),
        )
        .toList();

    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) (isWide ? const SizedBox(width: 16) : const SizedBox(height: 16)),
          Expanded(flex: 1, child: cards[i]),
        ],
      ],
    );
  }

  Widget _buildAuditCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    required List<String> details,
  }) {
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
                  Icon(icon, color: const Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details
                  .map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(d, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155))),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalValiditySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2, size: 80, color: Color(0xFF0F172A)),
                const SizedBox(height: 6),
                Text(
                  _r.folio,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Constancia de Verificación Legal e Integridad Criptográfica',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Constancia expedida en observancia de las Reglas Generales de la LFPIORPI (Art. 17 Fracc. XII) y recomendaciones de la UIF para Fedatarios Públicos.',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'SHA-256: ${_r.hash}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF4338CA), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
