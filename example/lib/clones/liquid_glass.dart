import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:easing_gradient/easing_gradient.dart';
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:mix/mix.dart';

import 'gpu_support.dart';
import 'icons.dart';
import 'styler_variants.dart';

class ToggleLiquidGlassActionsIntent extends Intent {
  const ToggleLiquidGlassActionsIntent();
}

class CloseLiquidGlassActionsIntent extends Intent {
  const CloseLiquidGlassActionsIntent();
}

class _CloseLiquidGlassActionsAction
    extends Action<CloseLiquidGlassActionsIntent> {
  _CloseLiquidGlassActionsAction(this.isOpen, this.onClose);
  final bool isOpen;
  final VoidCallback onClose;

  @override
  bool isEnabled(CloseLiquidGlassActionsIntent intent) => isOpen;

  @override
  Object? invoke(CloseLiquidGlassActionsIntent intent) {
    onClose();
    return null;
  }
}

const _primary = Color(0xFFF4F4F4);
const _secondary = Color(0xFFA4A4A4);
const _muted = Color(0xFF737373);
const _separator = Color(0x18FFFFFF);

class _LauncherEntry {
  const _LauncherEntry(
    this.name,
    this.icon, {
    this.subtitle = '',
    this.application = false,
    this.running = false,
    this.disabled = false,
  });

  final String name;
  final String icon;
  final String subtitle;
  final bool application;
  final bool running;
  final bool disabled;
  String get category => application ? 'Application' : 'Command';
  String get deeplink =>
      'cmdk://command/${name.toLowerCase().replaceAll(' ', '-')}';
}

const _suggestions = [
  _LauncherEntry('Disk Usage', 'disk', subtitle: 'Analyze disk space'),
  _LauncherEntry('Ghostty', 'ghostty', application: true),
  _LauncherEntry('Dia', 'dia', application: true, running: true),
  _LauncherEntry('ChatGPT', 'chatgpt', application: true, running: true),
  _LauncherEntry('Figma', 'figma', application: true, running: true),
  _LauncherEntry('Linear', 'linear', application: true),
  _LauncherEntry('Slack', 'slack', application: true, running: true),
  _LauncherEntry('YouTube', 'youtube', application: true),
  _LauncherEntry('Raycast', 'raycast', application: true, running: true),
  _LauncherEntry(
    'Toggle System Appearance',
    'appearance',
    subtitle: 'System Actions',
  ),
  _LauncherEntry('System Settings', 'settings', subtitle: 'macOS Preferences'),
];
const _commands = [
  _LauncherEntry('Get Remaining Time', 'session', subtitle: 'Amphetamine'),
  _LauncherEntry('Start New Session', 'session', subtitle: 'Amphetamine'),
  _LauncherEntry('Search Files & Folders', 'finder', subtitle: 'System Finder'),
  _LauncherEntry(
    'Clipboard History',
    'clipboard_cmd',
    subtitle: 'Raycast clipboard manager',
  ),
  _LauncherEntry('Import Extension', 'hammer', subtitle: 'Developer Tools'),
  _LauncherEntry('Manage Extensions', 'hammer', subtitle: 'Extensions Manager'),
  _LauncherEntry('Network Speed Test', 'network', subtitle: 'Developer Tools'),
  _LauncherEntry('Color Picker', 'palette', subtitle: 'Design Tools'),
  _LauncherEntry('Configure New Session', 'session', subtitle: 'Amphetamine'),
  _LauncherEntry(
    'End Current Session',
    'session',
    subtitle: 'Amphetamine',
    disabled: true,
  ),
];

/// A launcher with refractive glass controls and a contextual glass popover.
class LiquidGlassCMDK extends StatefulWidget {
  const LiquidGlassCMDK({super.key, this.onCommandSelect});

  /// Receives demo command activation; the showcase never launches OS processes.
  final ValueChanged<String>? onCommandSelect;

  @override
  State<LiquidGlassCMDK> createState() => _LiquidGlassCMDKState();
}

class _LiquidGlassCMDKState extends State<LiquidGlassCMDK>
    with SingleTickerProviderStateMixin {
  static const _headerHeight = 62.0;
  static const _footerHeight = 48.0;
  static const _maxResultsHeight = 300.0;

  String _selectedValue = 'Disk Usage';
  bool _isActionsMenuOpen = false;
  final _favorites = <String>{};
  final _mainInputFocusNode = FocusNode(debugLabel: 'LiquidGlassMainInput');
  final _actionsInputFocusNode = FocusNode(
    debugLabel: 'LiquidGlassActionsInput',
  );
  final _actionsRegion = Object();
  late final AnimationController _actionsController;
  late final CurvedAnimation _actionsAnimation;
  bool _animateActions = false;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _actionsController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 160),
          reverseDuration: const Duration(milliseconds: 120),
        )..addStatusListener((status) {
          if (status == AnimationStatus.dismissed && mounted) setState(() {});
        });
    _actionsAnimation = CurvedAnimation(
      parent: _actionsController,
      curve: const Cubic(0.22, 1, 0.36, 1),
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _actionsController.duration = Duration(
      milliseconds: _reduceMotion ? 100 : 160,
    );
    _actionsController.reverseDuration = Duration(
      milliseconds: _reduceMotion ? 100 : 120,
    );
  }

  static final _panelSettings = LiquidGlassSettings.ios27RegularDark(
    tintAmount: 0.15,
  );
  static final _controlSettings = LiquidGlassSettings.ios27RegularDark(
    tintAmount: 0.35,
  );
  static const _panelAppearance = LiquidGlassAppearance.ios27RegularDark(
    tint: Color(0x99141413),
  );
  static const _controlAppearance = LiquidGlassAppearance.ios27RegularDark();
  static const _shadows = [
    BoxShadow(color: Color(0x50000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  final _rowStyle = BoxStyler()
      .height(38)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8))
      .borderRadius(BorderRadiusGeometryMix.circular(10))
      .color(const Color(0x00000000))
      .onHovered(BoxStyler().color(const Color(0x0FFFFFFF)))
      .onSelected(BoxStyler().color(const Color(0x20FFFFFF)));

  _LauncherEntry? get _selectedEntry {
    for (final entry in [..._suggestions, ..._commands]) {
      if (entry.name == _selectedValue) return entry;
    }
    return null;
  }

  @override
  void dispose() {
    _actionsAnimation.dispose();
    _actionsController.dispose();
    _mainInputFocusNode.dispose();
    _actionsInputFocusNode.dispose();
    super.dispose();
  }

  void _openActionsMenu({bool animate = false}) {
    if (_isActionsMenuOpen || _selectedEntry == null) return;
    setState(() => _isActionsMenuOpen = true);
    _animateActions = animate;
    if (animate) {
      _actionsController.forward();
    } else {
      _actionsController.value = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isActionsMenuOpen) _actionsInputFocusNode.requestFocus();
    });
  }

  void _closeActionsMenu({bool animate = true}) {
    if (!_isActionsMenuOpen) return;
    setState(() => _isActionsMenuOpen = false);
    if (animate && _animateActions) {
      _actionsController.reverse();
    } else {
      _actionsController.value = 0;
    }
    _mainInputFocusNode.requestFocus();
  }

  void _toggleActionsMenu({bool animate = false}) => _isActionsMenuOpen
      ? _closeActionsMenu(animate: animate)
      : _openActionsMenu(animate: animate);

  void _activateSelected() {
    final selected = _selectedEntry;
    if (selected == null || selected.disabled) return;
    widget.onCommandSelect?.call(selected.name);
    _closeActionsMenu();
  }

  void _toggleFavorite() {
    if (_selectedEntry == null) return;
    setState(() {
      if (!_favorites.remove(_selectedValue)) _favorites.add(_selectedValue);
    });
    _closeActionsMenu();
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) _closeActionsMenu();
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.maybeOf(context)?.highContrast ?? false;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          meta: true,
          shift: true,
          includeRepeats: false,
        ): _toggleFavorite,
        const SingleActivator(
          LogicalKeyboardKey.keyC,
          meta: true,
          shift: true,
          includeRepeats: false,
        ): () {
          final entry = _selectedEntry;
          if (entry != null) _copy(entry.deeplink);
        },
      },
      child: Command(
        label: 'Apps and commands',
        disablePointerSelection: true,
        value: _selectedValue,
        onValueChange: (value) => setState(() => _selectedValue = value ?? ''),
        shortcuts: {
          ...CommandKeyboardShortcuts.defaults(),
          const SingleActivator(
            LogicalKeyboardKey.keyK,
            meta: true,
            includeRepeats: false,
          ): const ToggleLiquidGlassActionsIntent(),
          const SingleActivator(
            LogicalKeyboardKey.keyK,
            control: true,
            includeRepeats: false,
          ): const ToggleLiquidGlassActionsIntent(),
          const SingleActivator(LogicalKeyboardKey.escape):
              const CloseLiquidGlassActionsIntent(),
        },
        actions: {
          ToggleLiquidGlassActionsIntent:
              CallbackAction<ToggleLiquidGlassActionsIntent>(
                onInvoke: (_) {
                  _toggleActionsMenu();
                  return null;
                },
              ),
          CloseLiquidGlassActionsIntent: _CloseLiquidGlassActionsAction(
            _isActionsMenuOpen,
            () => _closeActionsMenu(animate: false),
          ),
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _glass(
                    highContrast: highContrast,
                    radius: 28,
                    panel: true,
                    child: _buildContent(constraints.maxWidth),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _buildFooter(highContrast, constraints.maxWidth),
                  ),
                  if (_isActionsMenuOpen || !_actionsController.isDismissed)
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 8,
                      bottom: 8,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: _animatedActionsMenu(highContrast),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glass({
    required Widget child,
    required bool highContrast,
    required double radius,
    bool panel = false,
  }) {
    if (highContrast) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: _secondary, width: 0.5),
        ),
        child: child,
      );
    }
    // When running on a platform without Flutter GPU (e.g. Web / non-Impeller),
    // use a flat solid surface without an outer border so inner FakeGlass pills
    // stand out cleanly without nesting issues.
    if (panel && !isFlutterGpuSupported) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
    }
    final shape = LiquidRoundedSuperellipse(borderRadius: radius);
    final settings = panel ? _panelSettings : _controlSettings;
    final appearance = panel ? _panelAppearance : _controlAppearance;
    if (!isFlutterGpuSupported) {
      return FakeGlass(
        settings: settings,
        appearance: appearance,
        shape: shape,
        shadows: _shadows,
        child: child,
      );
    }
    return LiquidGlass.withOwnLayer(
      settings: settings,
      appearance: appearance,
      shape: shape,
      shadows: _shadows,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildContent(double width) => Stack(
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: _headerHeight + _maxResultsHeight + _footerHeight,
        ),
        child: CommandList(
          shrinkWrap: true,
          animateHeight: !_reduceMotion,
          animationDuration: const Duration(milliseconds: 160),
          animationCurve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(
            8,
            _headerHeight,
            8,
            _footerHeight + 4,
          ),
          scrollbarBuilder: (context, child, controller) => _ScrollEdgeFade(
            topInset: _headerHeight,
            bottomInset: _footerHeight,
            child: rawCommandScrollbarBuilder(
              thumbColor: const Color(0x50FFFFFF),
              thickness: 3,
              radius: const Radius.circular(2),
              padding: const EdgeInsets.only(
                top: _headerHeight,
                bottom: _footerHeight,
              ),
            )(context, child, controller),
          ),
          children: [
            const CommandEmpty(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No commands found',
                    style: TextStyle(fontSize: 14, color: _secondary),
                  ),
                ),
              ),
            ),
            if (_favorites.isNotEmpty)
              CommandGroup(
                heading: _heading('Favorites'),
                children: [
                  for (final entry in [..._suggestions, ..._commands])
                    if (_favorites.contains(entry.name)) _item(entry, width),
                ],
              ),
            CommandGroup(
              heading: _heading('Suggestions'),
              topSpacing: _favorites.isNotEmpty ? 8 : 0,
              children: [
                for (final entry in _suggestions)
                  if (!_favorites.contains(entry.name)) _item(entry, width),
              ],
            ),
            CommandGroup(
              heading: _heading('Commands'),
              topSpacing: 8,
              children: [
                for (final entry in _commands)
                  if (!_favorites.contains(entry.name)) _item(entry, width),
              ],
            ),
          ],
        ),
      ),
      Positioned(left: 0, right: 0, top: 0, child: _buildSearch(width)),
    ],
  );

  Widget _buildSearch(double width) => SizedBox(
    height: _headerHeight,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CmdkIcons.raycast(size: 23, color: _muted),
          const SizedBox(width: 12),
          Expanded(
            child: CommandInput(
              focusNode: _mainInputFocusNode,
              placeholder: 'Search for apps or commands…',
              style: const TextStyle(fontSize: 19, color: _primary),
              placeholderStyle: const TextStyle(fontSize: 19, color: _muted),
              cursorColor: _primary,
              keyboardAppearance: Brightness.dark,
            ),
          ),
          if (width >= 580) ...[
            const SizedBox(width: 20),
            const Text(
              'Quick AI',
              style: TextStyle(fontSize: 13, color: _muted),
            ),
            const SizedBox(width: 8),
            _keyHint('⇥', size: 18),
          ],
        ],
      ),
    ),
  );

  Widget _heading(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
    child: Text(label, style: const TextStyle(fontSize: 12, color: _secondary)),
  );

  Widget _item(_LauncherEntry entry, double width) => CommandItem(
    value: entry.name,
    keywords: [entry.category, entry.subtitle],
    disabled: entry.disabled,
    onSelect: _activateSelected,
    builder: (context, state) => CommandItemStateProvider(
      state: state,
      child: Opacity(
        opacity: entry.disabled ? 0.35 : 1,
        child: Box(
          style: _rowStyle,
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _entryIcon(entry),
                    if (entry.running)
                      const Positioned(
                        bottom: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _muted,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(dimension: 3.5),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: _primary),
                      ),
                    ),
                    if (!entry.application &&
                        entry.subtitle.isNotEmpty &&
                        width >= 580) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          entry.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _secondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (width >= 440) ...[
                const SizedBox(width: 16),
                Text(
                  entry.category,
                  style: const TextStyle(fontSize: 14, color: _secondary),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  Widget _entryIcon(_LauncherEntry entry) {
    const iconDimension = 20.0;
    if (entry.application) {
      if (entry.icon == 'figma') {
        return CmdkLogo(size: iconDimension, child: CmdkIcons.figma(size: 15));
      }
      if (entry.icon == 'linear') {
        return CmdkLogo(size: iconDimension, child: CmdkIcons.linear(size: 15));
      }
      if (entry.icon == 'slack') {
        return CmdkLogo(size: iconDimension, child: CmdkIcons.slack(size: 15));
      }
      if (entry.icon == 'youtube') {
        return CmdkLogo(
          size: iconDimension,
          child: CmdkIcons.youtube(size: 15),
        );
      }
      if (entry.icon == 'raycast') {
        return CmdkLogo(
          size: iconDimension,
          child: CmdkIcons.raycast(size: 15),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(5.5),
        child: Image.asset(
          'assets/launcher/' + entry.icon + '.png',
          width: iconDimension,
          height: iconDimension,
          fit: BoxFit.cover,
        ),
      );
    }
    if (entry.icon == 'finder') {
      return CmdkLogo(
        size: iconDimension,
        child: CmdkIcons.finder(size: 14, color: _primary),
      );
    }
    if (entry.icon == 'clipboard_cmd') {
      return CmdkIcons.clipboardGradient(size: iconDimension);
    }
    if (entry.icon == 'hammer') {
      return CmdkIcons.hammerGradient(size: iconDimension);
    }
    final disk = entry.icon == 'disk';
    final session = entry.icon == 'session';
    final network = entry.icon == 'network';
    final palette = entry.icon == 'palette';
    final settings = entry.icon == 'settings';

    List<Color> gradientColors;
    IconData iconData;
    Color iconColor;

    if (disk) {
      gradientColors = const [Color(0xFF71EEA8), Color(0xFF218E82)];
      iconData = Icons.save_outlined;
      iconColor = _primary;
    } else if (session) {
      gradientColors = const [Color(0xFFFFC6A0), Color(0xFFEFAD62)];
      iconData = Icons.bedtime_rounded;
      iconColor = const Color(0xFFFFEFAB);
    } else if (network) {
      gradientColors = const [Color(0xFF38EF7D), Color(0xFF11998E)];
      iconData = Icons.wifi_rounded;
      iconColor = _primary;
    } else if (palette) {
      gradientColors = const [Color(0xFFF093FB), Color(0xFFF5576C)];
      iconData = Icons.palette_rounded;
      iconColor = _primary;
    } else if (settings) {
      gradientColors = const [Color(0xFF8E9EAB), Color(0xFF5A6B7C)];
      iconData = Icons.settings_rounded;
      iconColor = _primary;
    } else {
      gradientColors = const [Color(0xFF8D8E95), Color(0xFF4B4D55)];
      iconData = Icons.contrast_rounded;
      iconColor = const Color(0xFFDEDFE3);
    }

    return Container(
      width: iconDimension,
      height: iconDimension,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: const Color(0x30FFFFFF), width: 0.5),
      ),
      child: Icon(iconData, size: 15.0, color: iconColor),
    );
  }

  Widget _buildFooter(bool highContrast, double width) {
    final content = Row(
      key: const ValueKey('liquid-glass-footer'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _controlGlass(
          highContrast: highContrast,
          round: true,
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Icon(
                Icons.short_text_rounded,
                size: 22,
                color: _secondary,
              ),
            ),
          ),
        ),
        if (!_isActionsMenuOpen)
          TapRegion(
            groupId: _actionsRegion,
            child: _controlGlass(
              highContrast: highContrast,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (width >= 440)
                    _button(
                      label: _selectedEntry?.application == true
                          ? 'Open Application'
                          : 'Open Command',
                      onPress: _activateSelected,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedEntry?.application == true
                                ? 'Open Application'
                                : 'Open Command',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _keyHint('↵'),
                        ],
                      ),
                    ),
                  _button(
                    label: 'Actions',
                    onPress: () => _toggleActionsMenu(animate: true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Actions',
                          style: TextStyle(fontSize: 12, color: _secondary),
                        ),
                        const SizedBox(width: 8),
                        _keyHint('⌘'),
                        const SizedBox(width: 3),
                        _keyHint('K'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    if (highContrast) return content;
    if (!isFlutterGpuSupported) return content;
    return LiquidGlassCapture(
      child: LiquidGlassLayer(
        settings: _controlSettings,
        defaultAppearance: _controlAppearance,
        child: content,
      ),
    );
  }

  Widget _controlGlass({
    required Widget child,
    required bool highContrast,
    bool round = false,
  }) {
    if (highContrast) {
      return _glass(child: child, highContrast: true, radius: 24);
    }
    final shape = round
        ? const LiquidOval()
        : const LiquidRoundedSuperellipse(borderRadius: 24);
    const shadows = [
      BoxShadow(color: Color(0x28000000), blurRadius: 8, offset: Offset(0, 2)),
    ];
    if (!isFlutterGpuSupported) {
      // Standalone FakeGlass pill works cleanly when the outer container is solid.
      return FakeGlass(
        settings: _controlSettings,
        appearance: _controlAppearance,
        shape: shape,
        shadows: shadows,
        child: child,
      );
    }
    return LiquidGlass(shape: shape, shadows: shadows, child: child);
  }

  Widget _button({
    required String label,
    required Widget child,
    required VoidCallback onPress,
    double? width,
  }) => PressableBox(
    semanticsLabel: width == null ? null : label,
    onPress: onPress,
    style: BoxStyler()
        .height(36)
        .constraints(
          .new(minWidth: width ?? 0, maxWidth: width ?? double.infinity),
        )
        .padding(
          EdgeInsetsGeometryMix.symmetric(horizontal: width == null ? 12 : 0),
        )
        .alignment(Alignment.center)
        .borderRadius(BorderRadiusGeometryMix.circular(24))
        .onHovered(BoxStyler().color(const Color(0x0FFFFFFF)))
        .onPressed(BoxStyler().color(const Color(0x18FFFFFF)))
        .animate(AnimationConfig.ease(const Duration(milliseconds: 120))),
    child: Builder(
      builder: (context) {
        final pressed = WidgetStateProvider.hasStateOf(
          context,
          WidgetState.pressed,
        );
        return AnimatedScale(
          scale: pressed && !_reduceMotion ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: child,
        );
      },
    ),
  );

  Widget _animatedActionsMenu(bool highContrast) => AnimatedBuilder(
    animation: _actionsAnimation,
    child: _buildActionsMenu(highContrast),
    builder: (context, child) {
      final progress = _actionsAnimation.value;
      return IgnorePointer(
        ignoring: !_isActionsMenuOpen,
        child: ExcludeFocus(
          excluding: !_isActionsMenuOpen,
          child: ExcludeSemantics(
            excluding: !_isActionsMenuOpen,
            child: Transform.scale(
              key: const ValueKey('liquid-glass-actions-motion'),
              alignment: Alignment.bottomRight,
              scale: _reduceMotion ? 1 : 0.97 + 0.03 * progress,
              child: Opacity(opacity: progress, child: child),
            ),
          ),
        ),
      );
    },
  );

  Widget _buildActionsMenu(bool highContrast) {
    final entry = _selectedEntry;
    final child = TapRegion(
      groupId: _actionsRegion,
      onTapOutside: (_) => _closeActionsMenu(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320,
          maxWidth: 350,
          maxHeight: 340,
        ),
        child: _glass(
          highContrast: highContrast,
          radius: 18,
          child: Command(
            label: 'Actions for $_selectedValue',
            disablePointerSelection: true,
            shortcuts: {
              ...CommandKeyboardShortcuts.defaults(),
              const SingleActivator(LogicalKeyboardKey.escape):
                  const CloseLiquidGlassActionsIntent(),
              const SingleActivator(
                LogicalKeyboardKey.keyK,
                meta: true,
                includeRepeats: false,
              ): const CloseLiquidGlassActionsIntent(),
              const SingleActivator(
                LogicalKeyboardKey.keyK,
                control: true,
                includeRepeats: false,
              ): const CloseLiquidGlassActionsIntent(),
            },
            actions: {
              CloseLiquidGlassActionsIntent:
                  CallbackAction<CloseLiquidGlassActionsIntent>(
                    onInvoke: (_) {
                      _closeActionsMenu(animate: false);
                      return null;
                    },
                  ),
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Text(
                    _selectedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _secondary),
                  ),
                ),
                Flexible(
                  child: CommandList(
                    shrinkWrap: true,
                    animateHeight: false,
                    animationDuration: const Duration(milliseconds: 160),
                    animationCurve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      const CommandEmpty(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 36),
                            child: Text(
                              'No actions found',
                              style: TextStyle(fontSize: 13, color: _secondary),
                            ),
                          ),
                        ),
                      ),
                      _action(
                        entry?.application == true
                            ? 'Open Application'
                            : 'Open Command',
                        Icons.article_outlined,
                        const ['↵'],
                        _activateSelected,
                      ),
                      const CommandSeparator(
                        color: _separator,
                        height: 0.5,
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      _action(
                        _favorites.contains(_selectedValue)
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                        Icons.star_border_rounded,
                        const ['⇧', '⌘', 'F'],
                        _toggleFavorite,
                      ),
                      const CommandSeparator(
                        color: _separator,
                        height: 0.5,
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      _action(
                        'Copy Deeplink',
                        Icons.content_paste_outlined,
                        const ['⇧', '⌘', 'C'],
                        () => _copy(entry?.deeplink ?? ''),
                      ),
                      const CommandSeparator(
                        color: _separator,
                        height: 0.5,
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      _action(
                        'Copy Name',
                        Icons.copy_outlined,
                        const [],
                        () => _copy(_selectedValue),
                      ),
                    ],
                  ),
                ),
                CommandInput(
                  focusNode: _actionsInputFocusNode,
                  placeholder: 'Search for actions…',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _separator, width: 0.5),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: _primary),
                  placeholderStyle: const TextStyle(
                    fontSize: 14,
                    color: _muted,
                  ),
                  cursorColor: _primary,
                  keyboardAppearance: Brightness.dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return highContrast || !isFlutterGpuSupported
        ? child
        : LiquidGlassCapture(child: child);
  }

  Widget _action(
    String label,
    IconData icon,
    List<String> keys,
    VoidCallback onSelect,
  ) => CommandItem(
    value: label,
    onSelect: onSelect,
    builder: (context, state) => CommandItemStateProvider(
      state: state,
      child: Box(
        style: _rowStyle,
        child: Row(
          children: [
            Icon(icon, size: 17, color: _primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: _primary),
              ),
            ),
            for (final key in keys)
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: _keyHint(key),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _keyHint(String label, {double size = 17}) => Container(
    height: size,
    constraints: BoxConstraints(minWidth: size),
    padding: const EdgeInsets.symmetric(horizontal: 3),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: const Color(0x38FFFFFF), width: 0.8),
    ),
    child: Text(label, style: const TextStyle(fontSize: 11, color: _secondary)),
  );
}

/// Masks the full-height list beneath the overlaid input and footer. The ramps
/// extend deep under the input and footer overlays while preserving readability
/// by reaching full opacity right as items enter the active viewport.
class _ScrollEdgeFade extends StatelessWidget {
  const _ScrollEdgeFade({
    required this.topInset,
    required this.bottomInset,
    required this.child,
  });

  final double topInset;
  final double bottomInset;
  final Widget child;
  static const _topRamp = 82.0;
  static const _topOvershoot = 12.0;
  static const _bottomRamp = 48.0;

  // Sample once; painting only creates shaders for the current list bounds.
  // Multi-stop eased gradient for top edge: extends a longer, deeper transition zone
  // behind the input so items dissolve softly and gradually across the glass header.
  static final _topFade = EasingLinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: const [Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0xFFFFFFFF)],
    stops: const [0.0, 0.35, 1.0],
    curve: Curves.easeInCubic,
  );
  // Multi-stop eased gradient for bottom edge: retains full legibility until
  // reaching near the very bottom edge of the panel, then dissolves cleanly.
  static final _bottomFade = EasingLinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    // Keep overlay content clear in high contrast, with effectively hard edges.
    if (MediaQuery.highContrastOf(context)) return child;

    return ShaderMask(
      key: const ValueKey('liquid-glass-input-edge-fade'),
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => _topFade.createShader(
        Rect.fromLTWH(
          bounds.left,
          bounds.top + topInset - _topRamp + _topOvershoot,
          bounds.width,
          _topRamp,
        ),
      ),
      child: ShaderMask(
        key: const ValueKey('liquid-glass-bottom-edge-fade'),
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return _bottomFade.createShader(
            Rect.fromLTWH(
              bounds.left,
              bounds.bottom - _bottomRamp,
              bounds.width,
              _bottomRamp,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
