import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/call_history_service.dart';
import '../../models/call_history_model.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String participantId;
  final String participantName;
  final bool isIncoming;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.participantId,
    required this.participantName,
    this.isIncoming = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoEnabled = true;
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
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
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
          patientId: authProvider.user!.id,
          patientName: authProvider.user!.fullName,
          doctorId: widget.participantId,
          doctorName: widget.participantName,
          type: CallType.video,
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

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video view - participant's video (or placeholder)
            Center(
              child: _isVideoEnabled
                  ? Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.primaryBlue,
                              child: Text(
                                widget.participantName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.participantName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _callStatus == 'Connecting...' ? l10n.callConnecting :
                              _callStatus == 'Call Ended' ? l10n.callEnded :
                              _callStatus == 'Connected' ? l10n.connected : _callStatus,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[800],
                              child: Icon(
                                Icons.videocam_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.participantName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Local video preview (small picture-in-picture)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.lightBlue,
                    child: Text(
                      authProvider.user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Call duration and status at top
            Positioned(
              top: 16,
              left: 16,
              right: 140,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isCallActive && _callDuration.inSeconds > 0) ...[
                      const Icon(Icons.access_time, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      Text(
                        _callStatus == 'Connecting...' ? l10n.callConnecting :
                        _callStatus == 'Call Ended' ? l10n.callEnded :
                        _callStatus == 'Connected' ? l10n.connected : _callStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Call controls at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? l10n.unmute : l10n.mute,
                    backgroundColor: _isMuted ? AppTheme.errorRed : Colors.grey[700]!,
                    onPressed: _toggleMute,
                  ),

                  // Video toggle button
                  _buildControlButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    label: _isVideoEnabled ? l10n.videoOn : l10n.videoOff,
                    backgroundColor: _isVideoEnabled ? Colors.grey[700]! : AppTheme.errorRed,
                    onPressed: _toggleVideo,
                  ),

                  // Speaker button
                  _buildControlButton(
                    icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
                    label: _isSpeakerEnabled ? l10n.videoCall : l10n.earpiece,
                    backgroundColor: _isSpeakerEnabled ? AppTheme.lightBlue : Colors.grey[700]!,
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
        const SizedBox(height: 4),
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
