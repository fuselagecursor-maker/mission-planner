import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/status_pill.dart';

/// SRS FR-22 wireframe.
///
/// Future:
/// - Replace feed placeholder with RTSP/MAVLink stream renderer.
/// - Connect gimbal controls to MAVLink mount/gimbal protocol.
class CameraPayloadScreen extends StatefulWidget {
  const CameraPayloadScreen({super.key});

  @override
  State<CameraPayloadScreen> createState() => _CameraPayloadScreenState();
}

enum _CameraSource { placeholder, deviceCamera, networkStream }

class _CameraPayloadScreenState extends State<CameraPayloadScreen> {
  double _pitch = 0;
  double _yaw = 0;
  bool _followMode = true;
  bool _burst = false;
  bool _recording = false;

  _CameraSource _source = _CameraSource.placeholder;
  List<CameraDescription> _cameras = const [];
  CameraDescription? _selectedCamera;
  CameraController? _cameraController;
  Future<void>? _cameraInit;
  bool _cameraError = false;
  String? _cameraErrorText;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadCameras() async {
    try {
      final cams = await availableCameras();
      if (!mounted) return;
      setState(() {
        _cameras = cams;
        _selectedCamera = cams.isNotEmpty ? cams.first : null;
        _cameraError = false;
        _cameraErrorText = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = true;
        _cameraErrorText = 'Camera discovery failed: $e';
      });
    }
  }

  Future<void> _startDeviceCamera() async {
    final cam = _selectedCamera;
    if (cam == null) {
      setState(() {
        _cameraError = true;
        _cameraErrorText = 'No camera devices found.';
      });
      return;
    }

    final prev = _cameraController;
    try {
      final controller = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: true,
      );
      setState(() {
        _cameraController = controller;
        _cameraInit = controller.initialize();
        _cameraError = false;
        _cameraErrorText = null;
      });
      await _cameraInit;
      if (!mounted) return;
      await prev?.dispose();
      setState(() {});
    } catch (e) {
      await prev?.dispose();
      if (!mounted) return;
      setState(() {
        _cameraController = null;
        _cameraInit = null;
        _cameraError = true;
        _cameraErrorText = 'Failed to start camera: $e';
      });
    }
  }

  Future<void> _stopDeviceCamera() async {
    final controller = _cameraController;
    setState(() {
      _cameraController = null;
      _cameraInit = null;
    });
    await controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & Payload'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: StatusPill(
                label: _recording ? 'REC 00:00' : 'Idle',
                color: _recording ? scheme.error : scheme.outline,
                leading: _recording ? Icons.fiber_manual_record : Icons.videocam_outlined,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _LiveFeedPanel(
                    source: _source,
                    cameras: _cameras,
                    selectedCamera: _selectedCamera,
                    cameraStarted: _cameraController != null,
                    cameraError: _cameraError,
                    cameraErrorText: _cameraErrorText,
                    onSourceChanged: (next) async {
                      setState(() => _source = next);
                      if (next != _CameraSource.deviceCamera) {
                        await _stopDeviceCamera();
                      }
                    },
                    onSelectedCameraChanged: (v) => setState(() => _selectedCamera = v),
                    onStartStopCamera: _cameraController == null ? _startDeviceCamera : _stopDeviceCamera,
                    buildViewport: () => _buildFeedViewport(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _GimbalPanel(
                        pitch: _pitch,
                        yaw: _yaw,
                        followMode: _followMode,
                        onPitchChanged: (v) => setState(() => _pitch = v),
                        onYawChanged: (v) => setState(() => _yaw = v),
                        onFollowChanged: (v) => setState(() => _followMode = v),
                        onRecenter: () => setState(() {
                          _pitch = 0;
                          _yaw = 0;
                        }),
                        onRoiLock: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ROI Lock (placeholder)')),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _CapturePanel(
                        burst: _burst,
                        recording: _recording,
                        onBurstChanged: (v) => setState(() => _burst = v),
                        onToggleRecording: () => setState(() => _recording = !_recording),
                        onCapturePhoto: () {},
                        onSettings: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Camera settings (placeholder)')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _LiveFeedPanel(
              source: _source,
              cameras: _cameras,
              selectedCamera: _selectedCamera,
              cameraStarted: _cameraController != null,
              cameraError: _cameraError,
              cameraErrorText: _cameraErrorText,
              onSourceChanged: (next) async {
                setState(() => _source = next);
                if (next != _CameraSource.deviceCamera) {
                  await _stopDeviceCamera();
                }
              },
              onSelectedCameraChanged: (v) => setState(() => _selectedCamera = v),
              onStartStopCamera: _cameraController == null ? _startDeviceCamera : _stopDeviceCamera,
              buildViewport: () => _buildFeedViewport(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _GimbalPanel(
              pitch: _pitch,
              yaw: _yaw,
              followMode: _followMode,
              onPitchChanged: (v) => setState(() => _pitch = v),
              onYawChanged: (v) => setState(() => _yaw = v),
              onFollowChanged: (v) => setState(() => _followMode = v),
              onRecenter: () => setState(() {
                _pitch = 0;
                _yaw = 0;
              }),
              onRoiLock: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ROI Lock (placeholder)')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _CapturePanel(
              burst: _burst,
              recording: _recording,
              onBurstChanged: (v) => setState(() => _burst = v),
              onToggleRecording: () => setState(() => _recording = !_recording),
              onCapturePhoto: () {},
              onSettings: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera settings (placeholder)')),
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFeedViewport(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (_source) {
      case _CameraSource.placeholder:
        return Center(
          child: Text(
            'Camera feed viewport\n(placeholder)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );

      case _CameraSource.networkStream:
        return Center(
          child: Text(
            'RTSP feed (placeholder)\nFuture: video_player / ffmpeg / webrtc',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );

      case _CameraSource.deviceCamera:
        final controller = _cameraController;
        final init = _cameraInit;
        if (controller == null || init == null) {
          return Center(
            child: Text(
              'Device camera not started.\nTap Start to preview.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return FutureBuilder<void>(
          future: init,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: scheme.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Camera init failed:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              );
            }
            return CameraPreview(controller);
          },
        );
    }
  }
}

class _LiveFeedPanel extends StatelessWidget {
  const _LiveFeedPanel({
    required this.source,
    required this.cameras,
    required this.selectedCamera,
    required this.cameraStarted,
    required this.cameraError,
    required this.cameraErrorText,
    required this.onSourceChanged,
    required this.onSelectedCameraChanged,
    required this.onStartStopCamera,
    required this.buildViewport,
  });

  final _CameraSource source;
  final List<CameraDescription> cameras;
  final CameraDescription? selectedCamera;
  final bool cameraStarted;
  final bool cameraError;
  final String? cameraErrorText;
  final Future<void> Function(_CameraSource next) onSourceChanged;
  final void Function(CameraDescription? v) onSelectedCameraChanged;
  final VoidCallback onStartStopCamera;
  final Widget Function() buildViewport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Live feed',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              StatusPill(
                label: 'Storage: -- GB',
                color: scheme.outline,
                leading: Icons.sd_storage_outlined,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<_CameraSource>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: _CameraSource.placeholder,
                    label: Text('Placeholder'),
                    icon: Icon(Icons.image_outlined),
                  ),
                  ButtonSegment(
                    value: _CameraSource.deviceCamera,
                    label: Text('Device cam'),
                    icon: Icon(Icons.videocam_outlined),
                  ),
                  ButtonSegment(
                    value: _CameraSource.networkStream,
                    label: Text('RTSP URL'),
                    icon: Icon(Icons.wifi_tethering_outlined),
                  ),
                ],
                selected: {source},
                onSelectionChanged: (v) async {
                  if (v.isEmpty) return;
                  await onSourceChanged(v.first);
                },
              ),
              if (source == _CameraSource.deviceCamera) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CameraDescription>(
                      value: selectedCamera,
                      hint: const Text('Select camera'),
                      isExpanded: true,
                      items: [
                        for (final c in cameras)
                          DropdownMenuItem(
                            value: c,
                            child: Text(
                              '${c.name} (${c.lensDirection.name})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onSelectedCameraChanged,
                    ),
                  ),
                ),
                GradientButton(
                  compact: true,
                  icon: cameraStarted ? Icons.stop : Icons.play_arrow_rounded,
                  label: cameraStarted ? 'Stop' : 'Start',
                  onPressed: onStartStopCamera,
                ),
              ],
              if (source == _CameraSource.networkStream)
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('RTSP input (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.link_outlined),
                  label: const Text('Set URL'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.9)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                    scheme.surface.withValues(alpha: 0.22),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned.fill(child: buildViewport()),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withValues(alpha: 0.40),
                                Colors.transparent,
                                AppColors.black.withValues(alpha: 0.34),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 12,
                      top: 10,
                      child: _OsdChip(text: 'ALT: -- m'),
                    ),
                    const Positioned(
                      right: 12,
                      top: 10,
                      child: _OsdChip(text: 'SPD: -- m/s'),
                    ),
                    const Positioned(
                      left: 12,
                      bottom: 10,
                      child: _OsdChip(text: 'GPS: --, --'),
                    ),
                    const Positioned(
                      right: 12,
                      bottom: 10,
                      child: _OsdChip(text: 'BAT: --%'),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 44,
                      child: StatusPill(
                        label: source == _CameraSource.deviceCamera
                            ? (cameraStarted ? 'Device cam: LIVE' : 'Device cam: OFF')
                            : (source == _CameraSource.networkStream ? 'RTSP: placeholder' : 'Demo feed'),
                        leading: source == _CameraSource.deviceCamera
                            ? Icons.videocam_outlined
                            : (source == _CameraSource.networkStream ? Icons.wifi_tethering_outlined : Icons.image_outlined),
                        dense: true,
                        color: cameraStarted ? AppColors.success : scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (cameraError && cameraErrorText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              cameraErrorText!,
              style: text.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _GimbalPanel extends StatelessWidget {
  const _GimbalPanel({
    required this.pitch,
    required this.yaw,
    required this.followMode,
    required this.onPitchChanged,
    required this.onYawChanged,
    required this.onFollowChanged,
    required this.onRecenter,
    required this.onRoiLock,
  });

  final double pitch;
  final double yaw;
  final bool followMode;
  final ValueChanged<double> onPitchChanged;
  final ValueChanged<double> onYawChanged;
  final ValueChanged<bool> onFollowChanged;
  final VoidCallback onRecenter;
  final VoidCallback onRoiLock;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gimbal',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              StatusPill(
                label: followMode ? 'FOLLOW' : 'FREE',
                color: followMode ? AppColors.neonCyan : scheme.outline,
                leading: followMode ? Icons.explore_outlined : Icons.open_with_outlined,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: StatusPill(
                  label: 'Pitch: ${pitch.toStringAsFixed(0)}°',
                  color: scheme.outline,
                  leading: Icons.swap_vert_rounded,
                  dense: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatusPill(
                  label: 'Yaw: ${yaw.toStringAsFixed(0)}°',
                  color: scheme.outline,
                  leading: Icons.swap_horiz_rounded,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Pitch', style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Slider(
            value: pitch,
            min: -90,
            max: 30,
            onChanged: onPitchChanged,
          ),
          Text('Yaw', style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Slider(
            value: yaw,
            min: -180,
            max: 180,
            onChanged: onYawChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onRecenter,
                icon: const Icon(Icons.center_focus_strong_outlined),
                label: const Text('Re-centre'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Follow mode'),
                  value: followMode,
                  onChanged: onFollowChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          GradientButton(
            compact: true,
            icon: Icons.gps_fixed_outlined,
            label: 'ROI Lock',
            onPressed: onRoiLock,
          ),
        ],
      ),
    );
  }
}

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({
    required this.burst,
    required this.recording,
    required this.onBurstChanged,
    required this.onToggleRecording,
    required this.onCapturePhoto,
    required this.onSettings,
  });

  final bool burst;
  final bool recording;
  final ValueChanged<bool> onBurstChanged;
  final VoidCallback onToggleRecording;
  final VoidCallback onCapturePhoto;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Capture',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              StatusPill(
                label: recording ? 'RECORDING' : 'READY',
                color: recording ? scheme.error : AppColors.success,
                leading: recording ? Icons.fiber_manual_record : Icons.check_circle_outline,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              GradientButton(
                icon: Icons.photo_camera_outlined,
                label: 'Capture Photo',
                onPressed: onCapturePhoto,
              ),
              FilterChip(
                label: const Text('Burst mode'),
                selected: burst,
                onSelected: onBurstChanged,
              ),
              GradientButton(
                icon: recording ? Icons.stop : Icons.fiber_manual_record,
                label: recording ? 'Stop Recording' : 'Start Recording',
                onPressed: onToggleRecording,
              ),
              OutlinedButton.icon(
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OsdChip extends StatelessWidget {
  const _OsdChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.75)),
        color: scheme.surface.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
        ),
      ),
    );
  }
}

