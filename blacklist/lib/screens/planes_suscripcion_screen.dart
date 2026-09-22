import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanesSuscripcionScreen extends StatefulWidget {
  const PlanesSuscripcionScreen({
    super.key,
    required this.onBackToDashboard,
    required this.onNavigateToSearch,
    required this.onNavigateToBitacora,
    required this.onLogout,
  });

  final VoidCallback onBackToDashboard;
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToBitacora;
  final VoidCallback onLogout;

  @override
  State<PlanesSuscripcionScreen> createState() => _PlanesSuscripcionScreenState();
}

class _PlanesSuscripcionScreenState extends State<PlanesSuscripcionScreen> {
  final int _activeNavIndex = 3;

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
                    'Planes y Licenciamiento',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
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
                                _buildHeaderBar(),
                                const SizedBox(height: 24),
                                _buildEditorialBanner(),
                                const SizedBox(height: 28),
                                _buildPricingGrid(constraints.maxWidth),
                                const SizedBox(height: 28),
                                _buildComparisonTableCard(),
                                const SizedBox(height: 28),
                                _buildFaqSection(constraints.maxWidth),
                                const SizedBox(height: 28),
                                _buildInstitutionalFooter(),
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
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildNavItem(0, Icons.dashboard, 'Panel Principal', onTap: widget.onBackToDashboard, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(1, Icons.person_search, 'Nueva Búsqueda', onTap: widget.onNavigateToSearch, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(2, Icons.menu_book, 'Bitácora Notarial', onTap: widget.onNavigateToBitacora, isDrawer: isDrawer),
                    const SizedBox(height: 6),
                    _buildNavItem(3, Icons.credit_card, 'Planes y Suscripción', isDrawer: isDrawer),
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

  Widget _buildHeaderBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Módulo Administrativo', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
                const SizedBox(width: 8),
                Text('•', style: GoogleFonts.inter(color: const Color(0xFFCBD5E1))),
                const SizedBox(width: 8),
                Text('Licenciamiento Notarial Vigente', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Planes y Licenciamiento Notarial',
              style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Cumplimiento legal garantizado y blindaje preventivo ante la UIF y la Secretaría de Hacienda bajo lineamientos de la LFPIORPI.',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long, color: Color(0xFF4F46E5), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Facturación Fiscal CFDI 4.0', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text('Mensual o anual deducible para la notaría', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialBanner() {
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
                              'DICTAMEN DE VALIDEZ TÉCNICA',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA5B4FC)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NOM-151 • LFPIORPI Art. 17 Fracc. XII',
                            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Las constancias digitales expedidas por Cotejo incorporan sellado criptográfico inmutable SHA-256, asegurando certeza jurídica ante revisiones ordinarias o extraordinarias de la UIF y autoridades federales.',
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFCBD5E1), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('100%', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Trazabilidad Expediente', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFA5B4FC))),
                  ],
                ),
                Container(height: 30, width: 1, color: const Color(0xFF334155), margin: const EdgeInsets.symmetric(horizontal: 16)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('0 min', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Latencia Listas', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFA5B4FC))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingGrid(double width) {
    bool isWide = width >= 900;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPlanCardBasic()),
        if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),
        Expanded(child: _buildPlanCardPro()),
      ],
    );
  }

  Widget _buildPlanCardBasic() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Suscripción Notaría Titular', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF047857))),
                  ],
                ),
              ),
              Text('LICENCIA REGULAR', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plan Básico', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: Text('Operación Regular', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Verificación continua e ilimitada contra las listas regulatorias públicas obligatorias en México.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('\$3,800', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                    const SizedBox(width: 6),
                    Text('MXN / mes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('o \$38,000 MXN anual (ahorro de 2 meses)', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                    Text('+ IVA con CFDI', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('CAPACIDADES JURÍDICAS INCLUIDAS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
          const SizedBox(height: 12),
          _buildFeatureCheck('Búsquedas ILIMITADAS contra OFAC (EE.UU.), ONU y SAT 69-B (EFOS).'),
          _buildFeatureCheck('Semáforo de riesgo y cálculo algorítmico de homonimias (pg_trgm).'),
          _buildFeatureCheck('Descarga de Fichas Notariales en PDF con sello SHA-256 inmutable.'),
          _buildFeatureCheck('Hasta 5 usuarios simultáneos autorizados para abogados dictaminadores.'),
          _buildFeatureCheck('Soporte técnico preferencial por WhatsApp y teléfono.'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 6),
                    Text('Estado en su despacho:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                Text('NOTARÍA 143 CDMX • ACTIVO', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.manage_accounts, size: 18),
              label: Text('Gestionar Suscripción Notarial', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCardPro() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('PRÓXIMAMENTE (FASE 2)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4338CA))),
                  ],
                ),
              ),
              Text('Q3 2024', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plan Pro', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                child: Text('Blindaje Total', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4338CA))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Máxima diligencia jurídica para operaciones inmobiliarias complejas, corporativas y fideicomisos.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('\$6,500', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                    const SizedBox(width: 6),
                    Text('MXN / mes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Incluye migración de expedientes y configuración de API REST', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('AMPLIACIÓN INTEGRAL DE DILIGENCIA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
          const SizedBox(height: 12),
          _buildFeatureCheck('Todo lo incluido en el Plan Básico (OFAC, ONU, SAT 69-B, SHA-256).'),
          _buildFeatureCheck('Módulo PEP Completo (Personas Políticamente Expuestas federal y estatal).'),
          _buildFeatureCheck('Listas de Contraloría Federal y Función Pública (SFP).'),
          _buildFeatureCheck('Generación y exportación de Avisos UIF en XML oficial.'),
          _buildFeatureCheck('API REST para integración con Notalia, SIEN y bases locales.'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_clock, size: 18),
              label: Text('Solicitar Acceso Temprano / Demostración', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCheck(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTableCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RESPALDO REGULATORIO • MÉXICO', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text('Cuadro Comparativo de Cobertura Notarial', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Table(
            border: TableBorder.symmetric(inside: const BorderSide(color: Color(0xFFF1F5F9))),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  _buildTableCell('Criterio de Auditoría / Lista', isHeader: true),
                  _buildTableCell('Obligatoriedad Legal', isHeader: true),
                  _buildTableCell('Plan Básico', isHeader: true, alignCenter: true),
                  _buildTableCell('Plan Pro', isHeader: true, alignCenter: true),
                ],
              ),
              _buildTableRow('Lista OFAC (EE.UU.)', 'Obligatoria (Tratados internacionales)', true, true),
              _buildTableRow('Consejo de Seguridad ONU', 'Obligatoria (Vigilancia CSNU)', true, true),
              _buildTableRow('SAT Art. 69-B (EFOS)', 'Obligatoria (Código Fiscal)', true, true),
              _buildTableRow('Módulo PEP Completo', 'Debida diligencia reforzada', false, true),
              _buildTableRow('Generador XML Avisos UIF', 'Para reporte mensual de vulnerables', false, true),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String legal, bool inBasic, bool inPro) {
    return TableRow(
      children: [
        _buildTableCell(title, isBold: true),
        _buildTableCell(legal),
        _buildTableCellCheck(inBasic),
        _buildTableCellCheck(inPro),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false, bool alignCenter = false}) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
        style: isHeader
            ? GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))
            : (isBold
                ? GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
                : GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
      ),
    );
  }

  Widget _buildTableCellCheck(bool isChecked) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: isChecked
            ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20)
            : Text('—', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8))),
      ),
    );
  }

  Widget _buildFaqSection(double width) {
    int crossAxisCount = width >= 1024 ? 3 : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CERTEZA JURÍDICA Y TÉCNICA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text('Preguntas Frecuentes de Notarios y Titulares', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildFaqCard(
              Icons.policy,
              '¿Las constancias emitidas sirven ante la UIF?',
              'Sí, plenamente. Cada consulta emite una constancia digital PDF con hash SHA-256 y estampado de tiempo oficial que acredita la debida diligencia previa.',
            ),
            _buildFaqCard(
              Icons.sync,
              '¿Con qué frecuencia se sincronizan las listas?',
              'OFAC y ONU se sincronizan continuamente. El listado del SAT 69-B se actualiza ante publicaciones del Diario Oficial de la Federación (DOF).',
            ),
            _buildFaqCard(
              Icons.security,
              '¿Cómo se garantiza la confidencialidad?',
              'Implementamos cifrado en tránsito (TLS 1.3) y en reposo (AES-256). La notaría es la única titular de su bitácora confidencial.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFaqCard(IconData icon, String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(question, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(answer, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildInstitutionalFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.handshake, color: Color(0xFF4F46E5), size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Representa a un Colegio Notarial o red asociativa?', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text('Disponemos de convenios marco de licenciamiento colectivo y tarifas por volumen.', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mail, size: 16),
            label: Text('Contactar Dirección Jurídica', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F172A),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
