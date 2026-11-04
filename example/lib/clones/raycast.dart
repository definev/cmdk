import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk_ui/cmdk_ui.dart';

import 'icons.dart';
import 'styler_variants.dart';

class ToggleRaycastActionsIntent extends Intent {
  const ToggleRaycastActionsIntent();
}

class CloseRaycastActionsIntent extends Intent {
  const CloseRaycastActionsIntent();
}

class _CloseRaycastActionsAction extends Action<CloseRaycastActionsIntent> {
  _CloseRaycastActionsAction(this.isOpen, this.onClose);
  final bool isOpen;
  final VoidCallback onClose;

  @override
  bool isEnabled(CloseRaycastActionsIntent intent) => isOpen;

  @override
  Object? invoke(CloseRaycastActionsIntent intent) {
    onClose();
    return null;
  }
}

class _RaycastEntry {
  const _RaycastEntry(this.value, this.keywords, {this.isCommand = false});

  final String value;
  final List<String> keywords;
  final bool isCommand;
}

const _raycastCatalog = [
  _RaycastEntry('Linear', ['issue', 'sprint']),
  _RaycastEntry('Figma', ['design', 'ui', 'ux']),
  _RaycastEntry('Slack', ['chat', 'team']),
  _RaycastEntry('YouTube', ['video', 'stream']),
  _RaycastEntry('Raycast', ['productivity', 'tools']),
  _RaycastEntry('Clipboard History', ['copy', 'paste'], isCommand: true),
  _RaycastEntry('Import Extension', ['import', 'plugin'], isCommand: true),
  _RaycastEntry('Manage Extensions', ['manage', 'plugin'], isCommand: true),
];

// Simulated remote search: shorter queries take longer, so rapid edits can
// finish out of order. This demonstrates async I/O, not background CPU work.
Future<List<String>> _searchRaycast(String query) async {
  await Future<void>.delayed(
    Duration(milliseconds: query.length < 3 ? 900 : 450),
  );
  final matches =
      [
        for (final (index, entry) in _raycastCatalog.indexed)
          (
            entry: entry,
            order: index,
            score: commandScore(entry.value, query.trim(), entry.keywords),
          ),
      ].where((match) => match.score > 0).toList()..sort((a, b) {
        final comparison = b.score.compareTo(a.score);
        return comparison == 0 ? a.order.compareTo(b.order) : comparison;
      });
  return [for (final match in matches) match.entry.value];
}

class RaycastCMDK extends StatefulWidget {
  const RaycastCMDK({super.key, this.search, this.onCommandSelect});

  /// App-owned search returning matching names from the demo catalog.
  /// Defaults to a simulated remote source.
  final Future<List<String>> Function(String query)? search;

  /// Receives demo activation without launching an OS application.
  final ValueChanged<String>? onCommandSelect;

  @override
  State<RaycastCMDK> createState() => _RaycastCMDKState();
}

class _RaycastCMDKState extends State<RaycastCMDK>
    with TickerProviderStateMixin {
  String _selectedValue = 'Linear';
  String _query = '';
  List<_RaycastEntry> _displayedEntries = _raycastCatalog;
  Timer? _searchDebounce;
  int _searchGeneration = 0;
  bool _isSearching = false;
  bool _searchFailed = false;
  bool _isActionsMenuOpen = false;
  late AnimationController _shimmerController;
  late AnimationController _actionsAnimController;
  late Animation<double> _actionsAnimation;
  late final FocusNode _mainInputFocusNode;
  late final FocusNode _actionsInputFocusNode;

  bool get _resultsAreCurrent => !_isSearching && !_searchFailed;
  bool get _canUseSelection => _resultsAreCurrent && _selectedValue.isNotEmpty;
  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _mainInputFocusNode = FocusNode(debugLabel: 'RaycastMainInput');
    _actionsInputFocusNode = FocusNode(debugLabel: 'RaycastActionsInput');
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _actionsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _actionsAnimation = CurvedAnimation(
      parent: _actionsAnimController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSearchAnimation();
  }

  void _syncSearchAnimation() {
    if (_isSearching && !_reduceMotion) {
      if (!_shimmerController.isAnimating) {
        _shimmerController.value = 0.25;
        _shimmerController.repeat();
      }
    } else {
      _shimmerController.stop();
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final generation = ++_searchGeneration;
    _query = query;
    if (_isActionsMenuOpen) _closeActionsMenu();
    if (query.trim().isEmpty) {
      _publishResults(_raycastCatalog);
      return;
    }
    // Lock stale results immediately, including the debounce window.
    setState(() {
      _isSearching = true;
      _searchFailed = false;
    });
    _syncSearchAnimation();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      _runSearch(query, generation);
    });
  }

  Future<void> _runSearch(String query, int generation) async {
    try {
      final names = await (widget.search ?? _searchRaycast)(query);
      if (!mounted || generation != _searchGeneration) return;
      final catalog = {for (final entry in _raycastCatalog) entry.value: entry};
      _publishResults([
        for (final name in names.toSet())
          if (catalog[name] case final entry?) entry,
      ]);
    } catch (_) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _isSearching = false;
        _searchFailed = true;
      });
      _syncSearchAnimation();
    }
  }

  void _publishResults(List<_RaycastEntry> entries) {
    // Match the presentation order: applications, then commands.
    final ordered = [
      ...entries.where((entry) => !entry.isCommand),
      ...entries.where((entry) => entry.isCommand),
    ];
    setState(() {
      _displayedEntries = entries;
      _isSearching = false;
      _searchFailed = false;
      _selectedValue = ordered.firstOrNull?.value ?? '';
    });
    _syncSearchAnimation();
  }

  void _activateSelected() {
    if (!_canUseSelection) return;
    widget.onCommandSelect?.call(_selectedValue);
    _closeActionsMenu();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchGeneration++;
    _shimmerController.dispose();
    _actionsAnimController.dispose();
    _mainInputFocusNode.dispose();
    _actionsInputFocusNode.dispose();
    super.dispose();
  }

  void _openActionsMenu() {
    if (!_canUseSelection || _isActionsMenuOpen) return;
    setState(() {
      _isActionsMenuOpen = true;
    });
    _mainInputFocusNode.unfocus();
    _actionsAnimController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isActionsMenuOpen) {
        FocusScope.of(context).requestFocus(_actionsInputFocusNode);
        _actionsInputFocusNode.requestFocus();
      }
    });
  }

  void _closeActionsMenu() {
    if (!_isActionsMenuOpen) return;
    setState(() {
      _isActionsMenuOpen = false;
    });
    _actionsInputFocusNode.unfocus();
    FocusScope.of(context).requestFocus(_mainInputFocusNode);
    _mainInputFocusNode.requestFocus();

    _actionsAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {});
        FocusScope.of(context).requestFocus(_mainInputFocusNode);
        _mainInputFocusNode.requestFocus();
      }
    });
  }

  void _toggleActionsMenu() {
    if (_isActionsMenuOpen) {
      _closeActionsMenu();
    } else {
      _openActionsMenu();
    }
  }

  // Outer frame styler
  final outerCardStyle = BoxStyler()
      .maxWidth(640.0)
      .color(const Color(0xFF1E1E20))
      .borderRadius(BorderRadiusGeometryMix.circular(12.0))
      .border(
        BorderMix.all(
          BorderSideMix(color: const Color(0xFF2C2C30), width: 1.0),
        ),
      )
      .shadow(
        BoxShadowMix(
          color: const Color(0x7F000000),
          blurRadius: 40.0,
          offset: const Offset(0, 20),
        ),
      );

  // Top delicate shine gradient styler
  final topShineStyle = BoxStyler()
      .height(1.0)
      .gradient(
        LinearGradientMix(
          colors: const [
            Color(0x0038BDF8),
            Color(0x4438BDF8),
            Color(0xCCEC4899),
            Color(0x00EC4899),
          ],
        ),
      );

  // Input wrapper styler
  final inputWrapStyle = BoxStyler().padding(
    EdgeInsetsGeometryMix.symmetric(horizontal: 16.0, vertical: 12.0),
  );

  // Loader stylers
  final loaderBaseStyle = BoxStyler()
      .height(1.0)
      .color(const Color(0xFF26262A));

  final loaderShimmerStyle = BoxStyler().gradient(
    LinearGradientMix(
      colors: const [Color(0x00FF6363), Color(0xFFFF6363), Color(0x00FF6363)],
    ),
  );

  // Empty state stylers
  final emptyBoxStyle = BoxStyler().height(64.0).alignment(Alignment.center);

  final emptyTextStyle = TextStyler()
      .fontSize(14.0)
      .color(const Color(0xFF707075));

  // Group heading stylers
  final headingBoxStyle = BoxStyler().padding(
    EdgeInsetsGeometryMix.symmetric(horizontal: 8.0, vertical: 6.0),
  );

  final headingTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF707075))
      .fontWeight(FontWeight.w500);

  // Item stylers
  final itemBoxStyle = BoxStyler()
      .height(40.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .color(const Color(0x00000000))
      .onHovered(BoxStyler().color(const Color(0xFF242427)))
      .onSelected(BoxStyler().color(const Color(0xFF28282C)));

  final itemContentRowStyle = FlexBoxStyler().crossAxisAlignment(
    CrossAxisAlignment.center,
  );

  final itemLabelStyle = TextStyler()
      .fontSize(14.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(const Color(0xFFEDEDED))
      .onSelected(TextStyler().color(const Color(0xFFFFFFFF)));

  final itemMetaStyle = TextStyler()
      .fontSize(13.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(const Color(0xFF707075));

  // Keycap stylers
  final keycapBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 5.0, vertical: 2.0))
      .color(const Color(0xFF26262A))
      .borderRadius(BorderRadiusGeometryMix.circular(4.0))
      .border(
        BorderMix.all(
          BorderSideMix(color: const Color(0xFF333338), width: 1.0),
        ),
      );

  final keycapTextStyle = TextStyler()
      .fontSize(11.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w600);

  // Footer stylers
  final footerStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 12.0, vertical: 8.0))
      .border(
        BorderMix.top(
          BorderSideMix(color: const Color(0xFF26262A), width: 1.0),
        ),
      )
      .color(const Color(0xFF18181A))
      .borderRadius(
        BorderRadiusGeometryMix.only(
          bottomLeft: const Radius.circular(12.0),
          bottomRight: const Radius.circular(12.0),
        ),
      );

  final footerHintTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF8E8E93))
      .fontWeight(FontWeight.w500);

  final footerActionTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w500);

  final footerDividerStyle = BoxStyler()
      .size(1.0, 12.0)
      .color(const Color(0xFF2C2C32));

  // Submenu stylers
  final submenuBoxStyle = BoxStyler()
      .width(320.0)
      .color(const Color(0xFF1E1E22))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .border(
        BorderMix.all(
          BorderSideMix(color: const Color(0xFF2C2C30), width: 1.0),
        ),
      )
      .shadow(
        BoxShadowMix(
          color: const Color(0x7F000000),
          blurRadius: 30.0,
          offset: const Offset(0, 10),
        ),
      );

  final submenuItemBoxStyle = BoxStyler()
      .height(40.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .color(const Color(0x00000000))
      .onHovered(BoxStyler().color(const Color(0xFF242427)))
      .onSelected(BoxStyler().color(const Color(0xFF28282C)));

  final submenuItemLabelStyle = TextStyler()
      .fontSize(13.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w400);

  final submenuKeycapBoxStyle = BoxStyler()
      .size(20.0, 20.0)
      .alignment(Alignment.center)
      .borderRadius(BorderRadiusGeometryMix.circular(4.0))
      .color(const Color(0xFF28282C))
      .onHovered(BoxStyler().color(const Color(0xFF323236)))
      .onSelected(BoxStyler().color(const Color(0xFF38383E)));

  final submenuKeycapTextStyle = TextStyler()
      .fontSize(12.0)
      .fontWeight(FontWeight.w500)
      .color(const Color(0xFF88888E))
      .onSelected(TextStyler().color(const Color(0xFFEDEDED)));

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Box(
          style: outerCardStyle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              children: [
                Command(
                  // Search, ranking and request freshness belong to this demo.
                  shouldFilter: false,
                  search: _query,
                  onSearchChange: _onSearchChanged,
                  disablePointerSelection: true,
                  value: _selectedValue,
                  onValueChange: (v) {
                    if (_resultsAreCurrent) {
                      setState(() => _selectedValue = v ?? '');
                    }
                  },
                  shortcuts: {
                    ...CommandKeyboardShortcuts.defaults(),
                    const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                        const ToggleRaycastActionsIntent(),
                    const SingleActivator(LogicalKeyboardKey.escape):
                        const CloseRaycastActionsIntent(),
                  },
                  actions: {
                    ToggleRaycastActionsIntent:
                        CallbackAction<ToggleRaycastActionsIntent>(
                          onInvoke: (_) {
                            _toggleActionsMenu();
                            return null;
                          },
                        ),
                    CloseRaycastActionsIntent: _CloseRaycastActionsAction(
                      _isActionsMenuOpen,
                      _closeActionsMenu,
                    ),
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Delicate Shine Gradient
                      Box(style: topShineStyle),

                      // Search Input
                      Box(
                        style: inputWrapStyle,
                        child: CommandInput(
                          focusNode: _mainInputFocusNode,
                          autofocus: true,
                          placeholder: 'Search for apps and commands...',
                          style: const TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFFEDEDED),
                            fontWeight: FontWeight.w400,
                          ),
                          placeholderStyle: const TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF707075),
                            fontWeight: FontWeight.w400,
                          ),
                          cursorColor: const Color(0xFFFF6363),
                        ),
                      ),

                      // Shimmer Loader Line
                      _buildAnimatedLoader(),

                      // Command List with fixed 393px height (stable Raycast palette)
                      SizedBox(
                        height: 393.0,
                        child: CommandList(
                          shrinkWrap: false,
                          animateHeight: false,
                          physics: const ClampingScrollPhysics(),
                          scrollbarBuilder: rawCommandScrollbarBuilder(
                            thumbColor: const Color(0xFF2C2C32),
                            thickness: 4.0,
                            radius: const Radius.circular(2.0),
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            8.0,
                            0.0,
                            8.0,
                            52.0,
                          ),
                          children: [
                            if (_searchFailed)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Couldn’t search. Try again.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8E8E93),
                                        ),
                                      ),
                                    ),
                                    PressableBox(
                                      onPress: () => _onSearchChanged(_query),
                                      style: BoxStyler().padding(
                                        EdgeInsetsGeometryMix.all(8),
                                      ),
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFF6363),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Read the app-owned snapshot, not a catalog that
                            // registers new rows during the following frame.
                            if (_resultsAreCurrent && _displayedEntries.isEmpty)
                              Box(
                                style: emptyBoxStyle,
                                child: StyledText(
                                  'No results found.',
                                  style: emptyTextStyle,
                                ),
                              ),
                            for (final isCommand in [false, true])
                              if (_displayedEntries.any(
                                (entry) => entry.isCommand == isCommand,
                              ))
                                CommandGroup(
                                  key: ValueKey(
                                    isCommand
                                        ? 'raycast-commands'
                                        : 'raycast-suggestions',
                                  ),
                                  heading: _buildGroupHeading(
                                    isCommand ? 'Commands' : 'Suggestions',
                                  ),
                                  spacing: 4.0,
                                  topSpacing: 8.0,
                                  children: [
                                    for (final entry in _displayedEntries)
                                      if (entry.isCommand == isCommand)
                                        _buildRaycastItem(entry),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pinned Footer Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Box(
                    style: footerStyle,
                    child: RowBox(
                      style: itemContentRowStyle,
                      children: [
                        // Raycast grayscale logo (20x20)
                        CmdkIcons.raycastDark(
                          size: 20,
                          color: const Color(0xFF8E8E93),
                        ),
                        const Spacer(),

                        // "Open Application ↵"
                        StyledText(
                          'Open Application',
                          style: footerHintTextStyle,
                        ),
                        const SizedBox(width: 6.0),
                        _buildKeyCap('↵'),

                        const SizedBox(width: 12.0),
                        Box(style: footerDividerStyle),
                        const SizedBox(width: 12.0),

                        // "Actions ⌘K"
                        TapRegion(
                          groupId: 'raycast_actions',
                          child: Semantics(
                            button: true,
                            enabled: _canUseSelection,
                            child: Opacity(
                              opacity: _canUseSelection ? 1 : 0.5,
                              child: GestureDetector(
                                onTap: _canUseSelection
                                    ? _toggleActionsMenu
                                    : null,
                                behavior: HitTestBehavior.opaque,
                                child: MouseRegion(
                                  cursor: _canUseSelection
                                      ? SystemMouseCursors.click
                                      : SystemMouseCursors.basic,
                                  child: Container(
                                    height: 28.0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isActionsMenuOpen
                                          ? const Color(0xFF28282C)
                                          : const Color(0x00000000),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        StyledText(
                                          'Actions',
                                          style: footerActionTextStyle,
                                        ),
                                        const SizedBox(width: 6.0),
                                        _buildKeyCap(
                                          '⌘',
                                          isHighlighted: _isActionsMenuOpen,
                                        ),
                                        const SizedBox(width: 3.0),
                                        _buildKeyCap(
                                          'K',
                                          isHighlighted: _isActionsMenuOpen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions Popover Submenu
                if (_isActionsMenuOpen ||
                    _actionsAnimController.value > 0 ||
                    _actionsAnimController.isAnimating)
                  Positioned(
                    right: 8.0,
                    bottom: 48.0,
                    child: _buildActionsSubmenu(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLoader() => Box(
    style: loaderBaseStyle,
    child: !_isSearching
        ? null
        : Semantics(
            container: true,
            liveRegion: true,
            child: CommandLoading(
              key: const ValueKey('raycast-search-loading'),
              label: 'Searching apps and commands',
              child: RepaintBoundary(
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final barWidth = width * 0.35;
                      final gradient = Box(
                        key: const ValueKey('raycast-search-gradient'),
                        style: loaderShimmerStyle,
                      );
                      if (_reduceMotion) {
                        return Align(
                          child: SizedBox(width: barWidth, child: gradient),
                        );
                      }
                      // Only translate the painted bar; do not relayout the palette
                      // or rebuild the results on every animation tick.
                      return Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: barWidth,
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              child: gradient,
                              builder: (context, child) => Transform.translate(
                                key: const ValueKey(
                                  'raycast-search-gradient-motion',
                                ),
                                offset: Offset(
                                  (width + barWidth) *
                                          _shimmerController.value -
                                      barWidth,
                                  0,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
  );

  Widget _buildGroupHeading(String text) {
    return Box(
      style: headingBoxStyle,
      child: StyledText(text, style: headingTextStyle),
    );
  }

  Widget _buildRaycastItem(_RaycastEntry entry) {
    final value = entry.value;
    final icon = switch (value) {
      'Linear' => CmdkLogo(child: CmdkIcons.linear(size: 12)),
      'Figma' => CmdkLogo(child: CmdkIcons.figma(size: 14)),
      'Slack' => CmdkLogo(child: CmdkIcons.slack(size: 14)),
      'YouTube' => CmdkLogo(child: CmdkIcons.youtube(size: 14)),
      'Raycast' => CmdkLogo(child: CmdkIcons.raycast(size: 14)),
      'Clipboard History' => CmdkLogo(
        child: CmdkIcons.clipboardGradient(size: 20),
      ),
      _ => CmdkIcons.hammerGradient(size: 20),
    };
    return CommandItem(
      key: ValueKey(value),
      value: value,
      keywords: entry.keywords,
      disabled: !_resultsAreCurrent,
      onSelect: _activateSelected,
      builder: (context, state) {
        return CommandItemStateProvider(
          state: state,
          child: MouseRegion(
            cursor: _resultsAreCurrent
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Opacity(
              opacity: _resultsAreCurrent ? 1 : 0.5,
              child: Box(
                style: itemBoxStyle,
                child: RowBox(
                  style: itemContentRowStyle,
                  children: [
                    SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: Center(child: icon),
                    ),
                    const SizedBox(width: 10.0),
                    StyledText(value, style: itemLabelStyle),
                    const Spacer(),
                    StyledText(
                      entry.isCommand ? 'Command' : 'Application',
                      style: itemMetaStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyCap(String text, {bool isHighlighted = false}) {
    return Container(
      width: 20.0,
      height: 20.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF38383E)
            : const Color(0xFF26262A),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF484850)
              : const Color(0xFF333338),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.0,
          color: isHighlighted
              ? const Color(0xFFFFFFFF)
              : const Color(0xFFEDEDED),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionsSubmenu() {
    return AnimatedBuilder(
      animation: _actionsAnimation,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: !_isActionsMenuOpen,
          child: Transform.scale(
            scale: 0.96 + (0.04 * _actionsAnimation.value),
            alignment: Alignment.bottomRight,
            child: Opacity(
              opacity: _actionsAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: _RaycastActionsSubmenu(
        selectedValue: _selectedValue,
        focusNode: _actionsInputFocusNode,
        onClose: _closeActionsMenu,
        onActivate: _activateSelected,
        submenuBoxStyle: submenuBoxStyle,
        emptyBoxStyle: emptyBoxStyle,
        emptyTextStyle: emptyTextStyle,
        submenuItemBoxStyle: submenuItemBoxStyle,
        submenuItemLabelStyle: submenuItemLabelStyle,
        submenuKeycapBoxStyle: submenuKeycapBoxStyle,
        submenuKeycapTextStyle: submenuKeycapTextStyle,
        itemContentRowStyle: itemContentRowStyle,
      ),
    );
  }
}

class _RaycastActionsSubmenu extends StatefulWidget {
  const _RaycastActionsSubmenu({
    required this.selectedValue,
    required this.focusNode,
    required this.onClose,
    required this.onActivate,
    required this.submenuBoxStyle,
    required this.emptyBoxStyle,
    required this.emptyTextStyle,
    required this.submenuItemBoxStyle,
    required this.submenuItemLabelStyle,
    required this.submenuKeycapBoxStyle,
    required this.submenuKeycapTextStyle,
    required this.itemContentRowStyle,
  });

  final String selectedValue;
  final FocusNode focusNode;
  final VoidCallback onClose;
  final VoidCallback onActivate;
  final BoxStyler submenuBoxStyle;
  final BoxStyler emptyBoxStyle;
  final TextStyler emptyTextStyle;
  final BoxStyler submenuItemBoxStyle;
  final TextStyler submenuItemLabelStyle;
  final BoxStyler submenuKeycapBoxStyle;
  final TextStyler submenuKeycapTextStyle;
  final FlexBoxStyler itemContentRowStyle;

  @override
  State<_RaycastActionsSubmenu> createState() => _RaycastActionsSubmenuState();
}

class _RaycastActionsSubmenuState extends State<_RaycastActionsSubmenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(widget.focusNode);
        widget.focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: 'raycast_actions',
      onTapOutside: (_) => widget.onClose(),
      child: Box(
        style: widget.submenuBoxStyle,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Command(
            disablePointerSelection: true,
            shortcuts: {
              ...CommandKeyboardShortcuts.defaults(),
              const SingleActivator(LogicalKeyboardKey.escape):
                  const CloseRaycastActionsIntent(),
              const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                  const ToggleRaycastActionsIntent(),
            },
            actions: {
              CloseRaycastActionsIntent:
                  CallbackAction<CloseRaycastActionsIntent>(
                    onInvoke: (_) {
                      widget.onClose();
                      return null;
                    },
                  ),
              ToggleRaycastActionsIntent:
                  CallbackAction<ToggleRaycastActionsIntent>(
                    onInvoke: (_) {
                      widget.onClose();
                      return null;
                    },
                  ),
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommandList(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    CommandEmpty(
                      child: Box(
                        style: widget.emptyBoxStyle,
                        child: StyledText(
                          'No results found.',
                          style: widget.emptyTextStyle,
                        ),
                      ),
                    ),
                    CommandGroup(
                      heading: Box(
                        style: BoxStyler().padding(
                          EdgeInsetsGeometryMix.only(
                            left: 4.0,
                            top: 4.0,
                            bottom: 8.0,
                          ),
                        ),
                        child: StyledText(
                          widget.selectedValue,
                          style: TextStyler()
                              .fontSize(12.0)
                              .fontWeight(FontWeight.w500)
                              .color(const Color(0xFF88888E)),
                        ),
                      ),
                      children: [
                        _buildSubItem(
                          value: 'Open Application',
                          icon: CmdkIcons.window(size: 16),
                          label: 'Open Application',
                          shortcut: const ['↵'],
                          onSelect: widget.onActivate,
                        ),
                        _buildSubItem(
                          value: 'Show in Finder',
                          icon: CmdkIcons.finder(size: 16),
                          label: 'Show in Finder',
                          shortcut: const ['⌘', '↵'],
                          onSelect: widget.onClose,
                        ),
                        _buildSubItem(
                          value: 'Show Info in Finder',
                          icon: CmdkIcons.finder(size: 16),
                          label: 'Show Info in Finder',
                          shortcut: const ['⌘', 'I'],
                          onSelect: widget.onClose,
                        ),
                        _buildSubItem(
                          value: 'Add to Favorites',
                          icon: CmdkIcons.star(size: 16),
                          label: 'Add to Favorites',
                          shortcut: const ['⌘', '⇧', 'F'],
                          onSelect: widget.onClose,
                        ),
                      ],
                    ),
                  ],
                ),
                CommandInput(
                  focusNode: widget.focusNode,
                  autofocus: true,
                  placeholder: 'Search for actions...',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF2C2C30), width: 1.0),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFFEDEDED),
                    fontWeight: FontWeight.w400,
                  ),
                  placeholderStyle: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF88888E),
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: const Color(0xFFFF6363),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem({
    required String value,
    required Widget icon,
    required String label,
    required List<String> shortcut,
    required VoidCallback onSelect,
  }) {
    return CommandItem(
      value: value,
      onSelect: onSelect,
      builder: (context, state) {
        return CommandItemStateProvider(
          state: state,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Box(
              style: widget.submenuItemBoxStyle,
              child: RowBox(
                style: widget.itemContentRowStyle,
                children: [
                  SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: StyledText(
                      label,
                      style: widget.submenuItemLabelStyle,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < shortcut.length; i++) ...[
                        if (i > 0) const SizedBox(width: 2.0),
                        _buildSubmenuKeyCap(shortcut[i]),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmenuKeyCap(String text) {
    return Box(
      style: widget.submenuKeycapBoxStyle,
      child: StyledText(text, style: widget.submenuKeycapTextStyle),
    );
  }
}
