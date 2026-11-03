import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk/cmdk.dart';
import 'icons.dart';

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

class RaycastCMDK extends StatefulWidget {
  const RaycastCMDK({super.key});

  @override
  State<RaycastCMDK> createState() => _RaycastCMDKState();
}

class _RaycastCMDKState extends State<RaycastCMDK>
    with SingleTickerProviderStateMixin {
  String _selectedValue = 'Linear';
  bool _isActionsMenuOpen = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _toggleActionsMenu() {
    setState(() {
      _isActionsMenuOpen = !_isActionsMenuOpen;
    });
  }

  // Outer frame styler
  final outerCardStyle = BoxStyler()
      .maxWidth(640.0)
      .color(const Color(0xFF1E1E20))
      .borderRadius(BorderRadiusGeometryMix.circular(12.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF2C2C30), width: 1.0),
      ))
      .shadow(BoxShadowMix(
        color: const Color(0x7F000000),
        blurRadius: 40.0,
        offset: const Offset(0, 20),
      ));

  // Top delicate shine gradient styler
  final topShineStyle = BoxStyler().height(1.0).gradient(LinearGradientMix(
        colors: const [
          Color(0x0038BDF8),
          Color(0x4438BDF8),
          Color(0xCCEC4899),
          Color(0x00EC4899),
        ],
      ));

  // Input wrapper styler
  final inputWrapStyle = BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(horizontal: 16.0, vertical: 12.0));

  // Loader stylers
  final loaderBaseStyle =
      BoxStyler().height(1.0).color(const Color(0xFF26262A));

  final loaderShimmerStyle = BoxStyler().gradient(LinearGradientMix(
    colors: const [
      Color(0x00FF6363),
      Color(0xFFFF6363),
      Color(0x00FF6363),
    ],
  ));

  // Empty state stylers
  final emptyBoxStyle = BoxStyler().height(64.0).alignment(Alignment.center);

  final emptyTextStyle =
      TextStyler().fontSize(14.0).color(const Color(0xFF707075));

  // Group heading stylers
  final headingBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0, vertical: 6.0));

  final headingTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF707075))
      .fontWeight(FontWeight.w500);

  // Item stylers
  BoxStyler itemBoxStyle(bool isSelected) => BoxStyler()
      .height(40.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .color(isSelected ? const Color(0xFF28282C) : const Color(0x00000000));

  final itemContentRowStyle =
      FlexBoxStyler().crossAxisAlignment(CrossAxisAlignment.center);

  TextStyler itemLabelStyle(bool isSelected) => TextStyler()
      .fontSize(14.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(isSelected ? const Color(0xFFFFFFFF) : const Color(0xFFEDEDED));

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
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF333338), width: 1.0),
      ));

  final keycapTextStyle = TextStyler()
      .fontSize(11.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w600);

  // Footer stylers
  final footerStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 12.0, vertical: 8.0))
      .border(BorderMix.top(
        BorderSideMix(color: const Color(0xFF26262A), width: 1.0),
      ))
      .color(const Color(0xFF18181A))
      .borderRadius(BorderRadiusGeometryMix.only(
        bottomLeft: const Radius.circular(12.0),
        bottomRight: const Radius.circular(12.0),
      ));

  final footerHintTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF8E8E93))
      .fontWeight(FontWeight.w500);

  final footerActionTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w500);

  final footerDividerStyle =
      BoxStyler().size(1.0, 12.0).color(const Color(0xFF2C2C32));

  // Submenu stylers
  final submenuBoxStyle = BoxStyler()
      .width(320.0)
      .color(const Color(0xFF1E1E22))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF2C2C30), width: 1.0),
      ))
      .shadow(BoxShadowMix(
        color: const Color(0x7F000000),
        blurRadius: 30.0,
        offset: const Offset(0, 10),
      ));

  BoxStyler submenuItemBoxStyle(bool isSelected) => BoxStyler()
      .height(40.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .color(isSelected ? const Color(0xFF28282C) : const Color(0x00000000));

  TextStyler submenuItemLabelStyle(bool isSelected) => TextStyler()
      .fontSize(13.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w400);

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
                  value: _selectedValue,
                  onValueChange: (v) =>
                      setState(() => _selectedValue = v ?? ''),
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
                      () => setState(() => _isActionsMenuOpen = false),
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
                        child: const CommandInput(
                          placeholder: 'Search for apps and commands...',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFFEDEDED),
                            fontWeight: FontWeight.w400,
                          ),
                          placeholderStyle: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF707075),
                            fontWeight: FontWeight.w400,
                          ),
                          cursorColor: Color(0xFFFF6363),
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
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 44.0),
                          children: [
                            CommandEmpty(
                              child: Box(
                                style: emptyBoxStyle,
                                child: StyledText(
                                  'No results found.',
                                  style: emptyTextStyle,
                                ),
                              ),
                            ),
                            CommandGroup(
                              heading: _buildGroupHeading('Suggestions'),
                              spacing: 4.0,
                              topSpacing: 8.0,
                              children: [
                                _buildRaycastItem(
                                  value: 'Linear',
                                  keywords: const ['issue', 'sprint'],
                                  icon: CmdkLogo(
                                      child: CmdkIcons.linear(size: 12)),
                                  label: 'Linear',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'Figma',
                                  keywords: const ['design', 'ui', 'ux'],
                                  icon: CmdkLogo(
                                      child: CmdkIcons.figma(size: 14)),
                                  label: 'Figma',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'Slack',
                                  keywords: const ['chat', 'team'],
                                  icon: CmdkLogo(
                                      child: CmdkIcons.slack(size: 14)),
                                  label: 'Slack',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'YouTube',
                                  keywords: const ['video', 'stream'],
                                  icon: CmdkLogo(
                                      child: CmdkIcons.youtube(size: 14)),
                                  label: 'YouTube',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'Raycast',
                                  keywords: const ['productivity', 'tools'],
                                  icon: CmdkLogo(
                                      child: CmdkIcons.raycast(size: 14)),
                                  label: 'Raycast',
                                  isCommand: false,
                                ),
                              ],
                            ),
                            CommandGroup(
                              heading: _buildGroupHeading('Commands'),
                              spacing: 4.0,
                              topSpacing: 8.0,
                              children: [
                                _buildRaycastItem(
                                  value: 'Clipboard History',
                                  keywords: const ['copy', 'paste'],
                                  icon: CmdkLogo(
                                      child: CmdkIcons.clipboardGradient(
                                          size: 20)),
                                  label: 'Clipboard History',
                                  isCommand: true,
                                ),
                                _buildRaycastItem(
                                  value: 'Import Extension',
                                  keywords: const ['import', 'plugin'],
                                  icon: CmdkIcons.hammerGradient(size: 20),
                                  label: 'Import Extension',
                                  isCommand: true,
                                ),
                                _buildRaycastItem(
                                  value: 'Manage Extensions',
                                  keywords: const ['manage', 'plugin'],
                                  icon: CmdkIcons.hammerGradient(size: 20),
                                  label: 'Manage Extensions',
                                  isCommand: true,
                                ),
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
                        GestureDetector(
                          onTap: _toggleActionsMenu,
                          behavior: HitTestBehavior.opaque,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              height: 28.0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
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
                                  _buildKeyCap('⌘',
                                      isHighlighted: _isActionsMenuOpen),
                                  const SizedBox(width: 3.0),
                                  _buildKeyCap('K',
                                      isHighlighted: _isActionsMenuOpen),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions Popover Submenu
                if (_isActionsMenuOpen)
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

  Widget _buildAnimatedLoader() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Box(
          style: loaderBaseStyle,
          child: FractionallySizedBox(
            alignment: Alignment(-1.0 + (_shimmerController.value * 2.0), 0.0),
            widthFactor: 0.35,
            child: Box(style: loaderShimmerStyle),
          ),
        );
      },
    );
  }

  Widget _buildGroupHeading(String text) {
    return Box(
      style: headingBoxStyle,
      child: StyledText(
        text,
        style: headingTextStyle,
      ),
    );
  }

  Widget _buildRaycastItem({
    required String value,
    required List<String> keywords,
    required Widget icon,
    required String label,
    required bool isCommand,
  }) {
    return CommandItem(
      value: value,
      keywords: keywords,
      builder: (context, state) {
        final isSelected = state.isSelected;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Box(
            style: itemBoxStyle(isSelected),
            child: RowBox(
              style: itemContentRowStyle,
              children: [
                SizedBox(width: 20.0, height: 20.0, child: Center(child: icon)),
                const SizedBox(width: 10.0),
                StyledText(
                  label,
                  style: itemLabelStyle(isSelected),
                ),
                const Spacer(),
                StyledText(
                  isCommand ? 'Command' : 'Application',
                  style: itemMetaStyle,
                ),
              ],
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
        color:
            isHighlighted ? const Color(0xFF38383E) : const Color(0xFF26262A),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color:
              isHighlighted ? const Color(0xFF484850) : const Color(0xFF333338),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.0,
          color:
              isHighlighted ? const Color(0xFFFFFFFF) : const Color(0xFFEDEDED),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionsSubmenu() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.96 + (0.04 * value),
          alignment: Alignment.bottomRight,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Box(
        style: submenuBoxStyle,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Command(
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
                  setState(() => _isActionsMenuOpen = false);
                  return null;
                },
              ),
              ToggleRaycastActionsIntent:
                  CallbackAction<ToggleRaycastActionsIntent>(
                onInvoke: (_) {
                  setState(() => _isActionsMenuOpen = false);
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
                        style: emptyBoxStyle,
                        child: StyledText(
                          'No results found.',
                          style: emptyTextStyle,
                        ),
                      ),
                    ),
                    CommandGroup(
                      heading: Box(
                        style: BoxStyler().padding(
                          EdgeInsetsGeometryMix.only(
                              left: 4.0, top: 4.0, bottom: 8.0),
                        ),
                        child: StyledText(
                          _selectedValue,
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
                          onSelect: () =>
                              setState(() => _isActionsMenuOpen = false),
                        ),
                        _buildSubItem(
                          value: 'Show in Finder',
                          icon: CmdkIcons.finder(size: 16),
                          label: 'Show in Finder',
                          shortcut: const ['⌘', '↵'],
                          onSelect: () =>
                              setState(() => _isActionsMenuOpen = false),
                        ),
                        _buildSubItem(
                          value: 'Show Info in Finder',
                          icon: CmdkIcons.finder(size: 16),
                          label: 'Show Info in Finder',
                          shortcut: const ['⌘', 'I'],
                          onSelect: () =>
                              setState(() => _isActionsMenuOpen = false),
                        ),
                        _buildSubItem(
                          value: 'Add to Favorites',
                          icon: CmdkIcons.star(size: 16),
                          label: 'Add to Favorites',
                          shortcut: const ['⌘', '⇧', 'F'],
                          onSelect: () =>
                              setState(() => _isActionsMenuOpen = false),
                        ),
                      ],
                    ),
                  ],
                ),
                const CommandInput(
                  placeholder: 'Search for actions...',
                  autofocus: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF2C2C30), width: 1.0),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFFEDEDED),
                    fontWeight: FontWeight.w400,
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF88888E),
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: Color(0xFFFF6363),
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
        final isSelected = state.isSelected;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Box(
            style: submenuItemBoxStyle(isSelected),
            child: RowBox(
              style: itemContentRowStyle,
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
                    style: submenuItemLabelStyle(isSelected),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < shortcut.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2.0),
                      _buildSubmenuKeyCap(shortcut[i], isSelected: isSelected),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmenuKeyCap(String text, {required bool isSelected}) {
    return Container(
      width: 20.0,
      height: 20.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF38383E) : const Color(0xFF28282C),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.0,
          color: isSelected ? const Color(0xFFEDEDED) : const Color(0xFF88888E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
