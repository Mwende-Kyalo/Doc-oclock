import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/call_history_service.dart';
import '../../models/call_history_model.dart';

class DoctorVoiceCallScreen extends StatefulWidget {
  final String callId;
  final String participantId;
  final String participantName;
  final bool isIncoming;

  const DoctorVoiceCallScreen({
    super.key,
    required this.callId,
    required this.participantId,
    required this.participantName,
    this.isIncoming = false,
  });

  @override
  State<DoctorVoiceCallScreen> createState() => _DoctorVoiceCallScreenState();
}

class _DoctorVoiceCallScreenState extends State<DoctorVoiceCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerEnabled = false;
  bool _isCallActive = true;
  Duration _callDuration = Duration.zero;
  String _callStatus = '';
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    _callStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCall();
    });
  }

  Future<void> _initializeCall() async {
    final l10n = AppLocalizations.of(context)!;
    if (mounted) {
      setState(() {
        _callStatus = l10n.callConnecting;
      });
    }
    // Simulate call connection
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _callStatus = l10n.connected;
        _isCallActive = true;
      });
      _startCallTimer();
    }
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isCallActive) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
        _startCallTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return '${twoDigits(hours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _endCall() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final endTime = DateTime.now();
    
    setState(() {
      _isCallActive = false;
      _callStatus = l10n.callEnded;
    });

    // Save call history
    if (_callStartTime != null && _callDuration.inSeconds > 0) {
      try {
        await CallHistoryService.saveCall(
          appointmentId: widget.callId,
          patientId: widget.participantId,
          patientName: widget.participantName,
          doctorId: authProvider.user!.id,
          doctorName: authProvider.user!.fullName,
          type: CallType.voice,
          startTime: _callStartTime!,
          endTime: endTime,
          duration: _callDuration,
          status: CallStatus.completed,
          isIncoming: widget.isIncoming,
        );
      } catch (e) {
        // Silently fail - call history is not critical
        debugPrint('Failed to save call history: $e');
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
  }

  void _answerCall() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _callStatus = l10n.connected;
      _isCallActive = true;
    });
    _startCallTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      widget.participantName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Name
                  Text(
                    widget.participantName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Call status or duration
                  if (_isCallActive && _callDuration.inSeconds > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_callDuration),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _callStatus.isEmpty ? l10n.callConnecting : _callStatus,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isIncoming ? l10n.incomingCall : l10n.outgoingCall,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Call controls at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (widget.isIncoming && !_isCallActive)
                    // Incoming call - Answer/Decline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decline button
                        _buildControlButton(
                          icon: Icons.call_end,
                          label: l10n.endCall,
                          backgroundColor: AppTheme.errorRed,
                          onPressed: _endCall,
                          isLarge: true,
                        ),
                        // Answer button
                        _buildControlButton(
                          icon: Icons.call,
                          label: l10n.voiceCall,
                          backgroundColor: AppTheme.successGreen,
                          onPressed: _answerCall,
                          isLarge: true,
                        ),
                      ],
                    )
                  else if (_isCallActive)
                    // Active call controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: _isMuted ? l10n.unmute : l10n.mute,
                          backgroundColor:
                              _isMuted ? AppTheme.errorRed : Colors.grey[700]!,
                          onPressed: _toggleMute,
                        ),

                        // Speaker button
                        _buildControlButton(
                          icon: _isSpeakerEnabled
                              ? Icons.volume_up
                              : Icons.volume_off,
                          label: _isSpeakerEnabled
                              ? l10n.videoCall
                              : l10n.earpiece,
                          backgroundColor: _isSpeakerEnabled
                              ? AppTheme.lightBlue
                              : Colors.grey[700]!,
                          onPressed: _toggleSpeaker,
                        ),

                        // End call button
                        _buildControlButton(
                          icon: Icons.call_end,
                          label: l10n.endCall,
                          backgroundColor: AppTheme.errorRed,
                          onPressed: _endCall,
                          isLarge: true,
                        ),
                      ],
                    )
                  else
                    // Call ended
                    Center(
                      child: _buildControlButton(
                        icon: Icons.check,
                        label: l10n.ok,
                        backgroundColor: Colors.grey[700]!,
                        onPressed: () => Navigator.of(context).pop(),
                        isLarge: false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isLarge ? 64 : 56,
          height: isLarge ? 64 : 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: isLarge ? 28 : 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
