import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/checkin_service.dart';
import '../widgets/event_theme.dart';

/// Écran de scan QR pour valider la présence d'un participant.
///
/// Paramètre optionnel [eventId] : si fourni, vérifie que le billet
/// correspond bien à cet événement.
/// Paramètre optionnel [eventTitle] : affiché dans l'en-tête.
///
/// AVERTISSEMENT — VERSION UNIVERSITAIRE LOCALE :
/// La validation repose sur la base SQLite locale du téléphone.
class QrScannerScreen extends StatefulWidget {
  final int? eventId;
  final String? eventTitle;

  const QrScannerScreen({super.key, this.eventId, this.eventTitle});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _checkInService = CheckInService();
  final MobileScannerController _controller = MobileScannerController();

  bool _processing = false; // verrou anti-doublon
  CheckInResult? _lastResult;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // Ignorer si on traite déjà un scan ou si un résultat est affiché
    if (_processing || _lastResult != null) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;
    setState(() => _processing = true);
    await _controller.stop();

    final result = await _checkInService.validateTicket(
      ticketCode: rawValue,
      expectedEventId: widget.eventId,
    );

    if (mounted) {
      setState(() {
        _lastResult = result;
        _processing = false;
      });
    }
  }

  void _reset() {
    setState(() => _lastResult = null);
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.bg,
      appBar: AppBar(
        backgroundColor: EventTheme.bg,
        foregroundColor: EventTheme.text,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scanner QR', style: EventTheme.titleStyle),
            if (widget.eventTitle != null)
              Text(
                widget.eventTitle!,
                style: EventTheme.labelStyle.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, state, child) => Icon(
                state.torchState == TorchState.on
                    ? Icons.flashlight_off_outlined
                    : Icons.flashlight_on_outlined,
                color: EventTheme.mint,
              ),
            ),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Lampe torche',
          ),
        ],
      ),
      body: _lastResult != null ? _buildResult() : _buildScanner(),
    );
  }

  // ── Scanner actif ────────────────────────────────────────────────────────

  Widget _buildScanner() {
    return Stack(
      children: [
        // Flux caméra
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) => _buildError(error),
        ),

        // Overlay : viseur + instructions
        _ScanOverlay(),

        // Indicateur de traitement
        if (_processing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: EventTheme.mint),
            ),
          ),

        // Note version locale
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '⚠ Validation locale SQLite — version universitaire',
              style: TextStyle(
                fontFamily: EventTheme.fontFamily,
                fontSize: 11,
                color: EventTheme.warning,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // ── Erreur d'accès caméra ────────────────────────────────────────────────

  Widget _buildError(MobileScannerException error) {
    String message;
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        message = 'Permission caméra refusée.\n\n'
            'Allez dans Paramètres → Applications → Robotto → '
            'Autorisations → Caméra pour l\'activer.';
        break;
      default:
        message = 'Impossible d\'accéder à la caméra.\n${error.errorDetails?.message ?? ''}';
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined,
                size: 64, color: EventTheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: EventTheme.bodyStyle.copyWith(color: EventTheme.error),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: EventTheme.mint,
                side: const BorderSide(color: EventTheme.mint),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour',
                  style: TextStyle(fontFamily: EventTheme.fontFamily)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Résultat du scan ─────────────────────────────────────────────────────

  Widget _buildResult() {
    final result = _lastResult!;
    final isSuccess = result.isSuccess;
    final color = isSuccess ? EventTheme.success : EventTheme.error;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined;
    final reg = result.registration;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(EventTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Icône résultat
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 20),

          // Message principal
          Text(
            result.message,
            style: EventTheme.titleStyle.copyWith(fontSize: 18, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Détails du participant (si dispo)
          if (reg != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: EventTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultRow(
                    icon: Icons.event_outlined,
                    label: 'Événement',
                    value: reg.eventTitle ?? 'Événement #${reg.eventId}',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Code billet',
                    value: reg.ticketCode ?? '',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    icon: Icons.person_outline,
                    label: 'ID Participant',
                    value: '#${reg.userId}',
                  ),
                  if (isSuccess && reg.checkedInAt != null) ...[
                    const SizedBox(height: 8),
                    _ResultRow(
                      icon: Icons.access_time_outlined,
                      label: 'Heure',
                      value: _fmtDateTime(reg.checkedInAt!),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Bouton scanner un autre
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: EventTheme.mint,
              foregroundColor: EventTheme.bg,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _reset,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text(
              'Scanner un autre billet',
              style: TextStyle(
                  fontFamily: EventTheme.fontFamily,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Bouton fermer
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: EventTheme.textSoft,
              side: const BorderSide(color: EventTheme.surfaceHigh),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(fontFamily: EventTheme.fontFamily),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _fmtDateTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Overlay viseur QR ───────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const double size = 250;
      final double cx = (constraints.maxWidth - size) / 2;
      final double cy = (constraints.maxHeight - size) / 2 - 40;

      return Stack(
        children: [
          // Fond sombre autour du viseur
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
                Colors.black54, BlendMode.srcOut),
            child: Stack(
              children: [
                Container(color: Colors.transparent),
                Positioned(
                  left: cx, top: cy,
                  child: Container(
                    width: size, height: size,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Coins du viseur
          Positioned(
            left: cx, top: cy,
            child: _Corner(Alignment.topLeft),
          ),
          Positioned(
            left: cx + size - 28, top: cy,
            child: _Corner(Alignment.topRight),
          ),
          Positioned(
            left: cx, top: cy + size - 28,
            child: _Corner(Alignment.bottomLeft),
          ),
          Positioned(
            left: cx + size - 28, top: cy + size - 28,
            child: _Corner(Alignment.bottomRight),
          ),

          // Instruction
          Positioned(
            left: 0, right: 0, top: cy + size + 20,
            child: const Text(
              'Placez le QR code dans le cadre',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: EventTheme.fontFamily,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner(this.alignment);

  @override
  Widget build(BuildContext context) {
    const double length = 28;
    final bool isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final bool isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;

    return SizedBox(
      width: length, height: length,
      child: CustomPaint(
        painter: _CornerPainter(isLeft, isTop),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isLeft, isTop;
  const _CornerPainter(this.isLeft, this.isTop);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EventTheme.mint
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double len = 24;
    final double x = isLeft ? 0 : size.width;
    final double y = isTop ? 0 : size.height;
    final double dx = isLeft ? len : -len;
    final double dy = isTop ? len : -len;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

// ─── Sous-widgets résultat ───────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ResultRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: EventTheme.mint),
          const SizedBox(width: 8),
          Text('$label : ',
              style:
                  EventTheme.labelStyle.copyWith(color: EventTheme.textSoft)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontFamily: EventTheme.fontFamily,
                      fontSize: 13,
                      color: EventTheme.text))),
        ],
      );
}
