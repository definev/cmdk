import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk/cmdk.dart';
import 'icons.dart';

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
  final emptyBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.all(32.0))
      .alignment(Alignment.center);

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
      .margin(EdgeInsetsGeometryMix.only(bottom: 4.0))
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
      .width(260.0)
      .color(const Color(0xFF1E1E22))
      .borderRadius(BorderRadiusGeometryMix.circular(10.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF333338), width: 1.0),
      ))
      .shadow(BoxShadowMix(
        color: const Color(0xAA000000),
        blurRadius: 30.0,
        offset: const Offset(0, 10),
      ))
      .padding(EdgeInsetsGeometryMix.all(6.0));

  final submenuItemBoxStyle = BoxStyler()
      .height(34.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 10.0))
      .borderRadius(BorderRadiusGeometryMix.circular(6.0));

  final submenuItemLabelStyle = TextStyler()
      .fontSize(13.0)
      .color(const Color(0xFFEDEDED))
      .fontWeight(FontWeight.w400);

  final submenuItemShortcutStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF707075))
      .fontWeight(FontWeight.w500);

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
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.keyK &&
                        HardwareKeyboard.instance.isMetaPressed) {
                      _toggleActionsMenu();
                      return KeyEventResult.handled;
                    }
                    if (_isActionsMenuOpen &&
                        event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.escape) {
                      setState(() => _isActionsMenuOpen = false);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
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

                      // Command List with bottom clearance for pinned footer
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 335.0),
                        child: CommandList(
                          shrinkWrap: true,
                          animateHeight: true,
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
                              children: [
                                _buildRaycastItem(
                                  value: 'Linear',
                                  keywords: const ['issue', 'sprint'],
                                  icon: CmdkIcons.linear(size: 16),
                                  label: 'Linear',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'Figma',
                                  keywords: const ['design', 'ui', 'ux'],
                                  icon: CmdkIcons.figma(size: 16),
                                  label: 'Figma',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'Slack',
                                  keywords: const ['chat', 'team'],
                                  icon: CmdkIcons.slack(size: 16),
                                  label: 'Slack',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'YouTube',
                                  keywords: const ['video', 'stream'],
                                  icon: CmdkIcons.youtube(size: 16),
                                  label: 'YouTube',
                                  isCommand: false,
                                ),
                                _buildRaycastItem(
                                  value: 'Raycast',
                                  keywords: const ['productivity', 'tools'],
                                  icon: CmdkIcons.raycast(size: 16),
                                  label: 'Raycast',
                                  isCommand: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            CommandGroup(
                              heading: _buildGroupHeading('Commands'),
                              children: [
                                _buildRaycastItem(
                                  value: 'Clipboard History',
                                  keywords: const ['copy', 'paste'],
                                  icon: CmdkIcons.clipboardGradient(size: 20),
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
                            const SizedBox(height: 8.0),
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
                        // Raycast grayscale logo
                        Opacity(
                          opacity: 0.5,
                          child: CmdkIcons.raycast(
                              size: 16, color: const Color(0xFFEDEDED)),
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
                            child: Row(
                              children: [
                                StyledText(
                                  'Actions',
                                  style: footerActionTextStyle,
                                ),
                                const SizedBox(width: 6.0),
                                _buildKeyCap('⌘'),
                                const SizedBox(width: 3.0),
                                _buildKeyCap('K'),
                              ],
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
                    right: 12.0,
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

  Widget _buildKeyCap(String text) {
    return Box(
      style: keycapBoxStyle,
      child: StyledText(
        text,
        style: keycapTextStyle,
      ),
    );
  }

  Widget _buildActionsSubmenu() {
    return Box(
      style: submenuBoxStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSubmenuItem(
            label: 'Open in Browser',
            shortcut: '↵',
            onTap: () {
              setState(() => _isActionsMenuOpen = false);
            },
          ),
          _buildSubmenuItem(
            label: 'Copy Application URL',
            shortcut: '⌘C',
            onTap: () {
              setState(() => _isActionsMenuOpen = false);
            },
          ),
          _buildSubmenuItem(
            label: 'Show in Finder',
            shortcut: '⌘O',
            onTap: () {
              setState(() => _isActionsMenuOpen = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmenuItem({
    required String label,
    required String shortcut,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Box(
          style: submenuItemBoxStyle,
          child: RowBox(
            style: itemContentRowStyle,
            children: [
              StyledText(
                label,
                style: submenuItemLabelStyle,
              ),
              const Spacer(),
              StyledText(
                shortcut,
                style: submenuItemShortcutStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
