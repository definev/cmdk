import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk/cmdk.dart';
import 'icons.dart';

class VercelCMDK extends StatefulWidget {
  const VercelCMDK({super.key});

  @override
  State<VercelCMDK> createState() => _VercelCMDKState();
}

class _VercelCMDKState extends State<VercelCMDK>
    with SingleTickerProviderStateMixin {
  final List<String> _pages = ['Home'];
  String _selectedValue = 'Search Projects...';
  String _currentSearch = '';
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.96)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.96, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.forward(from: 0.0);
  }

  void _pushPage(String page) {
    _triggerBounce();
    setState(() {
      _pages.add(page);
      _currentSearch = '';
      if (page == 'Projects') {
        _selectedValue = 'vercel/website';
      }
    });
  }

  void _popPage() {
    if (_pages.length > 1) {
      _triggerBounce();
      setState(() {
        _pages.removeLast();
        _currentSearch = '';
        _selectedValue = 'Search Projects...';
      });
    }
  }

  // Outer frame styler
  final outerCardStyle = BoxStyler()
      .maxWidth(640.0)
      .padding(EdgeInsetsGeometryMix.all(8.0))
      .color(const Color(0xFF161616))
      .borderRadius(BorderRadiusGeometryMix.circular(12.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF333333), width: 1.0),
      ))
      .shadow(BoxShadowMix(
        color: const Color(0x99000000),
        blurRadius: 40.0,
        offset: const Offset(0, 20),
      ));

  // Breadcrumb badge stylers
  final breadcrumbBadgeStyle = BoxStyler()
      .height(20.0)
      .margin(EdgeInsetsGeometryMix.only(right: 6.0))
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .color(const Color(0xFF222222))
      .borderRadius(BorderRadiusGeometryMix.circular(4.0))
      .alignment(Alignment.center);

  final breadcrumbTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF888888))
      .fontWeight(FontWeight.w500);

  // Search input wrapper styler
  final searchInputContainerStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.fromLTRB(8.0, 4.0, 8.0, 16.0))
      .border(BorderMix.bottom(
        BorderSideMix(color: const Color(0xFF333333), width: 1.0),
      ));

  // Empty state stylers
  final emptyBoxStyle = BoxStyler().height(64.0).alignment(Alignment.center);

  final emptyTextStyle =
      TextStyler().fontSize(14.0).color(const Color(0xFF888888));

  // Group heading stylers
  final headingBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0, vertical: 6.0));

  final headingTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF888888))
      .fontWeight(FontWeight.w500);

  // Item stylers
  BoxStyler itemBoxStyle(bool isSelected) => BoxStyler()
      .height(48.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 16.0))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .color(isSelected ? const Color(0xFF222222) : const Color(0x00000000));

  final itemRowStyle =
      FlexBoxStyler().crossAxisAlignment(CrossAxisAlignment.center);

  TextStyler itemLabelStyle(bool isSelected) => TextStyler()
      .fontSize(14.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(isSelected ? const Color(0xFFEDEDED) : const Color(0xFF888888));

  final shortcutKeycapStyle = BoxStyler()
      .height(20.0)
      .minWidth(20.0)
      .margin(EdgeInsetsGeometryMix.only(left: 6.0))
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 4.0))
      .color(const Color(0xFF282828))
      .borderRadius(BorderRadiusGeometryMix.circular(4.0))
      .alignment(Alignment.center);

  final shortcutTextStyle = TextStyler()
      .fontSize(12.0)
      .height(1.1)
      .color(const Color(0xFFA0A0A0))
      .fontWeight(FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    final activePage = _pages.last;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Box(
        style: outerCardStyle,
        child: Command(
          value: _selectedValue,
          onValueChange: (v) => setState(() => _selectedValue = v ?? ''),
          onSearchChange: (s) => setState(() => _currentSearch = s),
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                _currentSearch.isEmpty &&
                _pages.length > 1) {
              _popPage();
              return KeyEventResult.handled;
            }
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              if (_selectedValue == 'Search Projects...') {
                _pushPage('Projects');
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Breadcrumb Badges
              Padding(
                padding:
                    const EdgeInsets.only(left: 4.0, top: 4.0, bottom: 4.0),
                child: Row(
                  children: _pages.map((p) {
                    return Box(
                      style: breadcrumbBadgeStyle,
                      child: StyledText(
                        p,
                        style: breadcrumbTextStyle,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Search Input with bottom border line
              Box(
                style: searchInputContainerStyle,
                child: const CommandInput(
                  placeholder: 'What do you need?',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Color(0xFFEDEDED),
                    fontWeight: FontWeight.w400,
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 17.0,
                    color: Color(0xFF707075),
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: Color(0xFFEDEDED),
                ),
              ),

              const SizedBox(height: 8.0),

              // Command List with dynamic animated height
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 330.0),
                child: CommandList(
                  shrinkWrap: true,
                  animateHeight: true,
                  padding: EdgeInsets.zero,
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
                    if (activePage == 'Home') ..._buildHomeGroups(),
                    if (activePage == 'Projects') ..._buildProjectsGroup(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHomeGroups() {
    return [
      CommandGroup(
        heading: _buildGroupHeading('Projects'),
        children: [
          _buildVercelItem(
            value: 'Search Projects...',
            icon: CmdkIcons.projects(size: 18),
            label: 'Search Projects...',
            shortcuts: ['S', 'P'],
            onSelect: () => _pushPage('Projects'),
          ),
          _buildVercelItem(
            value: 'Create New Project...',
            icon: CmdkIcons.plus(size: 18),
            label: 'Create New Project...',
            shortcuts: [],
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      CommandGroup(
        heading: _buildGroupHeading('Teams'),
        children: [
          _buildVercelItem(
            value: 'Search Teams...',
            icon: CmdkIcons.teams(size: 18),
            label: 'Search Teams...',
            shortcuts: ['⇧', 'P'],
          ),
          _buildVercelItem(
            value: 'Create New Team...',
            icon: CmdkIcons.plus(size: 18),
            label: 'Create New Team...',
            shortcuts: [],
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      CommandGroup(
        heading: _buildGroupHeading('Help'),
        children: [
          _buildVercelItem(
            value: 'Search Docs...',
            icon: CmdkIcons.docs(size: 18),
            label: 'Search Docs...',
            shortcuts: ['⇧', 'D'],
          ),
          _buildVercelItem(
            value: 'Send Feedback...',
            icon: CmdkIcons.feedback(size: 18),
            label: 'Send Feedback...',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'Contact Support',
            icon: CmdkIcons.support(size: 18),
            label: 'Contact Support',
            shortcuts: [],
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildProjectsGroup() {
    return [
      CommandGroup(
        heading: _buildGroupHeading('Projects'),
        children: [
          _buildVercelItem(
            value: 'vercel/website',
            icon: CmdkIcons.projects(size: 18),
            label: 'vercel/website',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'vercel/next.js',
            icon: CmdkIcons.projects(size: 18),
            label: 'vercel/next.js',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'pacocoursey/cmdk',
            icon: CmdkIcons.projects(size: 18),
            label: 'pacocoursey/cmdk',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'vercel/hyper',
            icon: CmdkIcons.projects(size: 18),
            label: 'vercel/hyper',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'vercel/swr',
            icon: CmdkIcons.projects(size: 18),
            label: 'vercel/swr',
            shortcuts: [],
          ),
        ],
      ),
    ];
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

  Widget _buildVercelItem({
    required String value,
    required Widget icon,
    required String label,
    required List<String> shortcuts,
    VoidCallback? onSelect,
  }) {
    return CommandItem(
      value: value,
      onSelect: onSelect,
      builder: (context, state) {
        final isSelected = state.isSelected;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Box(
            style: itemBoxStyle(isSelected),
            child: RowBox(
              style: itemRowStyle,
              children: [
                SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: Center(child: icon),
                ),
                const SizedBox(width: 12.0),
                StyledText(
                  label,
                  style: itemLabelStyle(isSelected),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: shortcuts.map((key) {
                    return Box(
                      style: shortcutKeycapStyle,
                      child: key == '⇧'
                          ? CmdkIcons.shift(
                              size: 11.0, color: const Color(0xFFA0A0A0))
                          : StyledText(
                              key,
                              style: shortcutTextStyle,
                            ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
