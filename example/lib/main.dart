import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'clones/framer.dart';
import 'clones/icons.dart';
import 'clones/linear.dart';
import 'clones/raycast.dart';
import 'clones/styler_variants.dart';
import 'clones/vercel.dart';

void main() {
  runApp(const CmdkExampleApp());
}

class NextThemeIntent extends Intent {
  const NextThemeIntent();
}

class PreviousThemeIntent extends Intent {
  const PreviousThemeIntent();
}

enum CmdkTheme {
  raycast,
  linear,
  vercel,
  framer,
}

class CmdkExampleApp extends StatefulWidget {
  const CmdkExampleApp({super.key});

  @override
  State<CmdkExampleApp> createState() => _CmdkExampleAppState();
}

class _CmdkExampleAppState extends State<CmdkExampleApp> {
  CmdkTheme _currentTheme = CmdkTheme.raycast;
  bool _copied = false;

  // Header stylers
  final versionBadgeStyle = BoxStyler()
      .height(22.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .color(const Color(0xFF1E1E22))
      .borderRadius(BorderRadiusGeometryMix.circular(12.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF2C2C32), width: 1.0),
      ))
      .alignment(Alignment.center);

  final versionBadgeTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF8A8F98))
      .fontWeight(FontWeight.w500);

  final titleTextStyle = TextStyler()
      .fontSize(32.0)
      .fontWeight(FontWeight.w700)
      .color(const Color(0xFFFFFFFF))
      .letterSpacing(-1.8)
      .height(1.2);

  final subtitleTextStyle =
      TextStyler().fontSize(16.0).color(const Color(0xFF8A8F98)).height(1.4);

  final copyButtonBoxStyle = BoxStyler()
      .height(40.0)
      .padding(EdgeInsetsGeometryMix.fromLTRB(14.0, 0, 6.0, 0))
      .color(const Color(0xFF202126))
      .borderRadius(BorderRadiusGeometryMix.circular(9999.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF2E3036), width: 1.0),
      ))
      .alignment(Alignment.center);

  final copyButtonTextStyle = TextStyler()
      .fontSize(13.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w500);

  final copyIconBadgeStyle = BoxStyler()
      .size(28.0, 28.0)
      .color(const Color(0xFF2B2C33))
      .borderRadius(BorderRadiusGeometryMix.circular(14.0))
      .alignment(Alignment.center)
      .variant(copiedVariant, BoxStyler().color(const Color(0x3310B981)));

  final githubButtonBoxStyle = BoxStyler()
      .height(36.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 14.0))
      .borderRadius(BorderRadiusGeometryMix.circular(9999.0))
      .alignment(Alignment.center);

  final githubButtonTextStyle = TextStyler()
      .fontSize(14.0)
      .color(const Color(0xFF8A8F98))
      .fontWeight(FontWeight.w500);

  // Dock Switcher stylers
  final dockContainerStyle = BoxStyler()
      .height(38.0)
      .padding(EdgeInsetsGeometryMix.all(3.0))
      .color(const Color(0xFF18181C))
      .borderRadius(BorderRadiusGeometryMix.circular(9999.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF28292E), width: 1.0),
      ));

  final dockActivePillStyle = BoxStyler()
      .color(const Color(0xFF2C2D34))
      .borderRadius(BorderRadiusGeometryMix.circular(9999.0));

  final dockTabItemStyle =
      BoxStyler().size(96.0, 32.0).alignment(Alignment.center);

  final dockTabLabelStyle = TextStyler()
      .fontSize(13.0)
      .color(const Color(0xFF8A8F98))
      .fontWeight(FontWeight.w400)
      .onSelected(TextStyler().color(const Color(0xFFFFFFFF)));

  final arrowHintBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .alignment(Alignment.center);

  final arrowHintTextStyle =
      TextStyler().fontSize(14.0).color(const Color(0xFF55555A));

  @override
  void initState() {
    super.initState();
    final themeParam = Uri.base.queryParameters['theme'];
    if (themeParam != null) {
      for (final t in CmdkTheme.values) {
        if (t.name.toLowerCase() == themeParam.toLowerCase()) {
          _currentTheme = t;
          break;
        }
      }
    }
  }

  void _nextTheme() {
    final nextIndex = (_currentTheme.index + 1) % CmdkTheme.values.length;
    setState(() => _currentTheme = CmdkTheme.values[nextIndex]);
  }

  void _prevTheme() {
    final prevIndex = (_currentTheme.index - 1 + CmdkTheme.values.length) %
        CmdkTheme.values.length;
    setState(() => _currentTheme = CmdkTheme.values[prevIndex]);
  }

  void _copyInstallCommand() async {
    await Clipboard.setData(const ClipboardData(text: 'flutter pub add cmdk'));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF0E0E10),
      pageRouteBuilder: <T>(settings, builder) =>
          PageRouteBuilder<T>(pageBuilder: (ctx, _, __) => builder(ctx)),
      shortcuts: <ShortcutActivator, Intent>{
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.arrowRight, meta: true):
            const NextThemeIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            const NextThemeIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true):
            const PreviousThemeIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            const PreviousThemeIntent(),
      },
      actions: <Type, Action<Intent>>{
        ...WidgetsApp.defaultActions,
        NextThemeIntent: CallbackAction<NextThemeIntent>(
          onInvoke: (_) {
            _nextTheme();
            return null;
          },
        ),
        PreviousThemeIntent: CallbackAction<PreviousThemeIntent>(
          onInvoke: (_) {
            _prevTheme();
            return null;
          },
        ),
      },
      home: Container(
        color: const Color(0xFF0E0E10),
        child: Stack(
          children: [
            // 2. Atmospheric Multi-color Radial Glow
            Positioned.fill(
              child: CustomPaint(
                painter: _AtmosphericMeshPainter(),
              ),
            ),

            // 3. Main Foreground Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 60.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Meta Header (Asymmetric Layout)
                      _buildTopHeader(),
                      const SizedBox(height: 36.0),

                      // Stabilized 475px Palette Stage (mirrors CMDKWrapper in reference/website/pages/index.tsx)
                      SizedBox(
                        height: 475.0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.98, end: 1.0)
                                      .animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildCurrentPalette(),
                          ),
                        ),
                      ),

                      // Bottom Theme Switcher Dock with Sliding Pill
                      Center(
                        child: _buildThemeSwitcherDock(),
                      ),

                      const SizedBox(height: 24.0),

                      // Subtle Decorative Wavy Line
                      Center(
                        child: CustomPaint(
                          size: const Size(180, 12),
                          painter: _WavyLinePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Version Badge + Title + Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Box(
                    style: versionBadgeStyle,
                    child: StyledText(
                      'v0.1.0',
                      style: versionBadgeTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              StyledText(
                '⌘K',
                style: titleTextStyle,
              ),
              const SizedBox(height: 4.0),
              StyledText(
                'Fast, composable, unstyled command menu for Flutter.',
                style: subtitleTextStyle,
              ),
            ],
          ),
        ),

        const SizedBox(width: 16.0),

        // Right Column: Install Button & GitHub Link
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // "flutter pub add cmdk" Copy Pill Button
            PressableBox(
              style: copyButtonBoxStyle,
              onPress: _copyInstallCommand,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StyledText(
                    'flutter pub add cmdk',
                    style: copyButtonTextStyle,
                  ),
                  const SizedBox(width: 12.0),
                  Box(
                    style: copyIconBadgeStyle
                        .applyVariants([if (_copied) copiedVariant]),
                    child: _copied
                        ? CmdkIcons.check(
                            size: 14, color: const Color(0xFF10B981))
                        : CmdkIcons.copy(
                            size: 14, color: const Color(0xFF8A8F98)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10.0),

            // GitHub repository button
            Box(
              style: githubButtonBoxStyle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CmdkIcons.github(size: 14, color: const Color(0xFF8A8F98)),
                  const SizedBox(width: 8.0),
                  StyledText(
                    'definev/cmdk',
                    style: githubButtonTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentPalette() {
    switch (_currentTheme) {
      case CmdkTheme.raycast:
        return const RaycastCMDK(key: ValueKey('raycast'));
      case CmdkTheme.linear:
        return const LinearCMDK(key: ValueKey('linear'));
      case CmdkTheme.vercel:
        return const VercelCMDK(key: ValueKey('vercel'));
      case CmdkTheme.framer:
        return const FramerCMDK(key: ValueKey('framer'));
    }
  }

  Widget _buildThemeSwitcherDock() {
    final activeIndex = _currentTheme.index;

    return Box(
      style: dockContainerStyle,
      child: Stack(
        children: [
          // Sliding Active Pill Background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: activeIndex * 96.0,
            top: 0,
            bottom: 0,
            width: 96.0,
            child: Box(style: dockActivePillStyle),
          ),

          // Button Tabs
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDockButton(
                theme: CmdkTheme.raycast,
                icon: CmdkIcons.raycast(size: 14),
                label: 'Raycast',
              ),
              _buildDockButton(
                theme: CmdkTheme.linear,
                icon: CmdkIcons.linear(size: 14),
                label: 'Linear',
              ),
              _buildDockButton(
                theme: CmdkTheme.vercel,
                icon: CmdkIcons.vercel(size: 14),
                label: 'Vercel',
              ),
              _buildDockButton(
                theme: CmdkTheme.framer,
                icon: CmdkIcons.framer(size: 14),
                label: 'Framer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDockButton({
    required CmdkTheme theme,
    required Widget icon,
    required String label,
  }) {
    final isSelected = _currentTheme == theme;

    return WidgetStateProvider(
      states: {
        if (isSelected) WidgetState.selected,
      },
      child: PressableBox(
        style: dockTabItemStyle,
        onPress: () => setState(() => _currentTheme = theme),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6.0),
            Flexible(
              child: StyledText(
                label,
                style: dockTabLabelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Atmospheric Multi-Color Radial Mesh Glow behind Card
class _AtmosphericMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);

    // Cyan / Blue blob
    final bluePaint = Paint()
      ..color = const Color(0x1F38BDF8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90.0);
    canvas.drawCircle(
        Offset(center.dx - 180, center.dy - 60), 160.0, bluePaint);

    // Purple / Indigo blob
    final purplePaint = Paint()
      ..color = const Color(0x22818CF8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100.0);
    canvas.drawCircle(
        Offset(center.dx + 160, center.dy - 40), 170.0, purplePaint);

    // Pink / Magenta blob
    final pinkPaint = Paint()
      ..color = const Color(0x1CEC4899)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 110.0);
    canvas.drawCircle(Offset(center.dx + 40, center.dy + 80), 180.0, pinkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Decorative wavy footer line
class _WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x208A8F98)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const count = 12;
    final step = size.width / count;
    path.moveTo(0, size.height * 0.5);

    for (int i = 0; i < count; i++) {
      final x1 = (i * step) + (step * 0.25);
      final y1 = (i % 2 == 0) ? 0.0 : size.height;
      final x2 = (i + 1) * step;
      final y2 = size.height * 0.5;
      path.quadraticBezierTo(x1, y1, x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
