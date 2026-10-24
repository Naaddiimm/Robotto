import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/audio_helper.dart';
import '../models/project.dart';

class VoiceNotesTab extends StatefulWidget {
  final Project project;

  const VoiceNotesTab({super.key, required this.project});

  @override
  State<VoiceNotesTab> createState() => _VoiceNotesTabState();
}

class _VoiceNotesTabState extends State<VoiceNotesTab> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  String? _playingId;
  bool _isPlaying = false;
  Duration _playPosition = Duration.zero;
  Duration _playDuration = Duration.zero;
  Timer? _playTimer;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _recordingTimer?.cancel();
    _playTimer?.cancel();
    super.dispose();
  }

  // ─── RECORDING ───────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Permission microphone refusée. Activez-la dans les paramètres.',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: path,
      );

      _recordingDuration = Duration.zero;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingDuration += const Duration(seconds: 1));
      });

      AudioHelper.playClickSound();
      setState(() => _isRecording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur démarrage enregistrement: $e',
              style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
      });

      if (path != null && path.isNotEmpty) {
        AudioHelper.playSuccessSound();
        _showSaveNoteDialog(path, _recordingDuration);
      }
    } catch (e) {
      _recordingTimer?.cancel();
      setState(() => _isRecording = false);
    }
  }

  void _showSaveNoteDialog(String filePath, Duration duration) {
    final titleCtrl = TextEditingController(
      text: 'Note du ${_formattedNow()}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.mic_rounded, color: AppTheme.accent, size: 22),
                const SizedBox(width: 8),
                Text('Enregistrer la note',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
              const SizedBox(height: 6),
              Text('Durée : ${_formatDuration(duration)}',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textSoft)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Titre de la note',
                  labelStyle:
                      GoogleFonts.poppins(color: AppTheme.accent, fontSize: 13),
                  prefixIcon: const Icon(Icons.label_outline_rounded,
                      color: AppTheme.accent, size: 18),
                  filled: true,
                  fillColor: AppTheme.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E2942)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.accent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    final title = titleCtrl.text.trim().isNotEmpty
                        ? titleCtrl.text.trim()
                        : 'Note vocale';
                    Navigator.pop(ctx);
                    setState(() {
                      widget.project.voiceNotes.add(VoiceNote(
                        id: 'vn_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        filePath: filePath,
                        duration: duration,
                        createdAt: _formattedNow(),
                        createdBy: 'Vous',
                      ));
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Note vocale enregistrée !',
                          style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: AppTheme.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: Text('Sauvegarder',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bg)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Delete the temp file
                    try {
                      File(filePath).deleteSync();
                    } catch (_) {}
                  },
                  child: Text('Annuler',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppTheme.textSoft)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── PLAYBACK ────────────────────────────────────────────────────────────────

  Future<void> _playNote(VoiceNote note) async {
    if (_playingId == note.id && _isPlaying) {
      await _player.pause();
      _playTimer?.cancel();
      setState(() => _isPlaying = false);
      return;
    }

    if (_playingId != note.id) {
      await _player.stop();
      _playTimer?.cancel();
      setState(() {
        _playingId = note.id;
        _playPosition = Duration.zero;
        _playDuration = note.duration;
      });
    }

    await _player.play(DeviceFileSource(note.filePath));
    AudioHelper.playClickSound();

    _playTimer = Timer.periodic(const Duration(milliseconds: 300), (_) async {
      final pos = await _player.getCurrentPosition();
      if (mounted && pos != null) {
        setState(() {
          _playPosition = pos;
          if (_playPosition >= _playDuration) {
            _isPlaying = false;
            _playTimer?.cancel();
          }
        });
      }
    });

    setState(() => _isPlaying = true);

    _player.onPlayerComplete.listen((_) {
      _playTimer?.cancel();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playPosition = Duration.zero;
        });
      }
    });
  }

  Future<void> _deleteNote(VoiceNote note) async {
    AudioHelper.playClickSound();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceHigh,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer la note ?',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text('"${note.title}" sera définitivement supprimée.',
            style:
                GoogleFonts.poppins(color: AppTheme.textSoft, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style:
                    GoogleFonts.poppins(color: AppTheme.textDisabled, fontSize: 13)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Supprimer',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_playingId == note.id) {
        await _player.stop();
        _playTimer?.cancel();
        setState(() {
          _playingId = null;
          _isPlaying = false;
        });
      }
      try {
        File(note.filePath).deleteSync();
      } catch (_) {}
      setState(() =>
          widget.project.voiceNotes.removeWhere((n) => n.id == note.id));
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formattedNow() {
    final now = DateTime.now();
    const months = [
      'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Record Button ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [Colors.redAccent, Colors.red.shade800]
                      : [AppTheme.accent, const Color(0xFF0A6E5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.redAccent : AppTheme.accent)
                        .withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRecording
                        ? Icons.stop_circle_rounded
                        : Icons.mic_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRecording
                        ? 'Arrêter  •  ${_formatDuration(_recordingDuration)}'
                        : 'Appuyer pour enregistrer',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PulsingDot(),
                          const SizedBox(width: 6),
                          Text('Enregistrement en cours...',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            const Icon(Icons.library_music_rounded,
                color: AppTheme.accent, size: 16),
            const SizedBox(width: 6),
            Text(
              '${widget.project.voiceNotes.length} note${widget.project.voiceNotes.length != 1 ? 's' : ''} vocale${widget.project.voiceNotes.length != 1 ? 's' : ''}',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSoft),
            ),
          ]),
        ),

        // ── List ──
        Expanded(
          child: widget.project.voiceNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic_off_rounded,
                          size: 56, color: Color(0xFF1E2942)),
                      const SizedBox(height: 12),
                      Text('Aucune note vocale pour le moment',
                          style: GoogleFonts.poppins(
                              color: AppTheme.textSoft, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                          'Appuyez sur le bouton pour enregistrer votre première note.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF4B5563), fontSize: 11)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.project.voiceNotes.length,
                  itemBuilder: (context, index) {
                    final note = widget.project.voiceNotes[
                        widget.project.voiceNotes.length - 1 - index];
                    final isThisPlaying =
                        _playingId == note.id && _isPlaying;
                    final isThisActive = _playingId == note.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isThisActive
                              ? AppTheme.accent.withValues(alpha: 0.5)
                              : const Color(0xFF1E2942),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Play/Pause button
                              GestureDetector(
                                onTap: () => _playNote(note),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isThisActive
                                        ? AppTheme.accent
                                        : AppTheme.accent
                                            .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isThisPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: isThisActive
                                        ? AppTheme.bg
                                        : AppTheme.accent,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Par ${note.createdBy} · ${note.createdAt}  •  ${_formatDuration(note.duration)}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppTheme.textDisabled),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 18, color: AppTheme.textDisabled),
                                onPressed: () => _deleteNote(note),
                              ),
                            ],
                          ),

                          // Progress bar (shown when active)
                          if (isThisActive) ...[
                            const SizedBox(height: 10),
                            Row(children: [
                              Text(_formatDuration(_playPosition),
                                  style: GoogleFonts.poppins(
                                      fontSize: 10, color: AppTheme.textSoft)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _playDuration.inMilliseconds > 0
                                        ? (_playPosition.inMilliseconds /
                                                _playDuration.inMilliseconds)
                                            .clamp(0.0, 1.0)
                                        : 0.0,
                                    backgroundColor:
                                        const Color(0xFF1E2942),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppTheme.accent),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_formatDuration(_playDuration),
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: AppTheme.textSoft)),
                            ]),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── PULSING DOT ANIMATION ───────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: const CircleAvatar(
            radius: 4, backgroundColor: Colors.redAccent),
      ),
    );
  }
}
