import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/resultado_busqueda.dart';
import '../services/api_service.dart';

class NuevaBusquedaScreen extends StatefulWidget {
  const NuevaBusquedaScreen({
    super.key,
    required this.token,
    required this.onBackToDashboard,
    required this.onSearchResult,
  });

  final String token;
  final VoidCallback onBackToDashboard;
  final ValueChanged<ResultadoBusqueda> onSearchResult;

  @override
  State<NuevaBusquedaScreen> createState() => _NuevaBusquedaScreenState();
}

class _NuevaBusquedaScreenState extends State<NuevaBusquedaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController(text: 'Roberto Elizondo Garza');
  final _rfcController = TextEditingController(text: 'EIGR790814K34');
  final _curpController = TextEditingController(text: 'EIGR790814HNLXXX09');
  final _instrumentoController = TextEditingController(text: 'Escritura Pública No. 45,219');

  bool _ofacChecked = true;
  bool _onuChecked = true;
  bool _satChecked = true;

  bool _isSearching = false;
  String? _errorMessage;

  Future<void> _ejecutarCotejo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final nombre = _nombreController.text.trim();
    final rfc = _rfcController.text.trim();

    try {
      final resultado = await ApiService(widget.token).buscar(nombre, rfc.isNotEmpty ? rfc : null);
      if (!mounted) return;
      setState(() => _isSearching = false);
      widget.onSearchResult(resultado);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = e.message;
      });
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _rfcController.clear();
    _curpController.clear();
    _instrumentoController.clear();
  }

  void _aplicarPreset(String nombre, String rfc, String curp) {
    setState(() {
      _nombreController.text = nombre;
      _rfcController.text = rfc;
      _curpController.text = curp;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rfcController.dispose();
    _curpController.dispose();
    _instrumentoController.dispose();
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
                    'Nueva Consulta Notarial',
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
                          _buildContextStrip(),
                          const SizedBox(height: 16),
                          _buildHeaderSection(),
                          const SizedBox(height: 24),
                          _buildMainLayout(constraints.maxWidth),
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
                'Nueva Consulta de Cotejo Regulatorio',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 17, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(
                '24 May 2024 • Sincronización Al día',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContextStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'MÓDULO LFPIORPI v4.2',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 8),
            Text('/', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFCBD5E1))),
            const SizedBox(width: 8),
            Text(
              'EXP-KYC-2024-0891',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.shield_outlined, size: 17, color: Color(0xFF10B981)),
            const SizedBox(width: 6),
            Text(
              'Cifrado HSM de 256-bit Activo',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                    ),
                    child: Text(
                      'VALIDACIÓN PREVIA NOTARIAL',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FOLIO ACTIVO #NT-9082',
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Nueva Consulta de Cotejo Regulatorio',
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                'Verificación previa de prevención de lavado de dinero conforme a la LFPIORPI, disposiciones de la UIF y listas de restricción internacional.',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONSULTAS DISPONIBLES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      children: [
                        const TextSpan(text: '1,840 '),
                        TextSpan(text: '/ 2,000', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VELOCIDAD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                  Text('1.2 seg', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainLayout(double width) {
    bool isWide = width >= 1024;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isWide ? 8 : 1,
          child: _buildFormCard(),
        ),
        if (isWide) const SizedBox(width: 24) else const SizedBox(height: 24),
        SizedBox(
          width: isWide ? 340 : double.infinity,
          child: _buildSidebarBento(),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E7FF)),
                      ),
                      child: const Icon(Icons.verified_user, color: Color(0xFF4F46E5), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cédula de Identificación del Compareciente', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text('Personas Físicas, Morales, Representantes o Apoderados', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Text('Fase 1: Búsqueda', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF475569))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 20),

            // Quick presets for demo purposes
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip(
                  'Caso Limpio',
                  Icons.check_circle_outline,
                  const Color(0xFF10B981),
                  () => _aplicarPreset('Ana Sofía Martínez Cordero', '', ''),
                ),
                _buildPresetChip(
                  'Homonimia OFAC',
                  Icons.person_search,
                  const Color(0xFFD97706),
                  () => _aplicarPreset('Roberto Elizondo Garza', '', ''),
                ),
                _buildPresetChip(
                  'Alerta SAT 69-B',
                  Icons.gavel,
                  const Color(0xFFDC2626),
                  () => _aplicarPreset('Comercializadora Fantasma SA de CV', 'SATX800101AAA', ''),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Field 1: Nombre Completo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
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
                          Text('Nombre Completo o Razón Social', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text(' *', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Text('Campo Obligatorio', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreController,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Ingrese el nombre completo' : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF94A3B8), size: 22),
                      hintText: 'Ej. Roberto Elizondo Garza o Grupo Inmobiliario S.A.',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Se cotejan automáticamente variantes ortográficas, acentuación y algoritmos fonéticos (Metaphone/Levenshtein).',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Row 2: RFC & CURP
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RFC (Contribuyentes)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _rfcController,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 19),
                          hintText: 'EJ. EIGR790814K34',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURP (Registro Único)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _curpController,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.fingerprint_outlined, color: Color(0xFF94A3B8), size: 19),
                          hintText: 'EJ. EIGR790814HNLXXX09',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Field 4: Folio Instrumento
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Número de Instrumento o Folio Interno Notarial', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _instrumentoController,
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.gavel_outlined, color: Color(0xFF94A3B8), size: 19),
                    hintText: 'Ej. Escritura Pública No. 45,219 / Proyecto Compraventa Polanco',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Watchlists Checkboxes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Listas Regulatorias y Sanciones a Consultar', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                      child: Text('3 DE 3 ACTIVAS', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        value: _ofacChecked,
                        onChanged: (val) => setState(() => _ofacChecked = val ?? true),
                        title: Text('OFAC EE.UU.', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: Text('SDN List', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        dense: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CheckboxListTile(
                        value: _onuChecked,
                        onChanged: (val) => setState(() => _onuChecked = val ?? true),
                        title: Text('ONU / CSNU', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: Text('Sanciones', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        dense: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CheckboxListTile(
                        value: _satChecked,
                        onChanged: (val) => setState(() => _satChecked = val ?? true),
                        title: Text('SAT 69-B', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: Text('EFOS', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB91C1C))),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Submit Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _limpiarFormulario,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Limpiar', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _ejecutarCotejo,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isSearching
                        ? const SizedBox(key: ValueKey('loading'), width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.document_scanner, key: ValueKey('idle'), size: 19),
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _isSearching ? 'Consultando Servidores...' : 'Cotejar Compareciente',
                      key: ValueKey(_isSearching),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSidebarBento() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ART. 17 LFPIORPI', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
              const SizedBox(height: 4),
              Text('Aviso de Responsabilidad Notarial', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text(
                'Las Notarías Públicas están obligadas a conformar el expediente único de identificación y verificar las listas oficiales emitidas por la UIF previo al otorgamiento del acto.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Integridad de Nodos de Búsqueda', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildNodeRow('OFAC SDN Department', 'Latencia: 18ms'),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildNodeRow('Naciones Unidas (SCIS)', 'Res 1267/1988'),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildNodeRow('SAT Art. 69-B', 'DOF Lista Completa'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNodeRow(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
          child: Text('ONLINE', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF047857))),
        ),
      ],
    );
  }
}
