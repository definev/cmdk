import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk_ui/cmdk_ui.dart';

import 'icons.dart';
import 'styler_variants.dart';

class VercelPopPageIntent extends Intent {
  const VercelPopPageIntent();
}

class _VercelDeleteCharacterAction extends Action<DeleteCharacterIntent> {
  _VercelDeleteCharacterAction(this.canPop, this.onPop);
  final ValueGetter<bool> canPop;
  final VoidCallback onPop;

  @override
  Object? invoke(DeleteCharacterIntent intent) {
    if (!intent.forward && canPop()) {
      onPop();
      return null;
    }
    return callingAction?.invoke(intent);
  }
}

class VercelCMDK extends StatefulWidget {
  const VercelCMDK({super.key});

  @override
  State<VercelCMDK> createState() => _VercelCMDKState();
}

class _VercelCMDKState extends State<VercelCMDK>
    with SingleTickerProviderStateMixin {
  final List<String> _pages = ['Home'];
  String _selectedValue = 'Search Projects...';
  late final TextEditingController _searchController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.96,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.96,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  bool _canPop() => _searchController.text.isEmpty && _pages.length > 1;

  void _triggerBounce() {
    _bounceController.forward(from: 0.0);
  }

  void _pushPage(String page) {
    _triggerBounce();
    setState(() {
      _pages.add(page);
      _searchController.clear();
      if (page == 'Projects') {
        _selectedValue = 'flutter/website';
      }
    });
  }

  void _popPage() {
    if (_pages.length > 1) {
      _triggerBounce();
      setState(() {
        _pages.removeLast();
        _searchController.clear();
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
      .border(
        BorderMix.all(
          BorderSideMix(color: const Color(0xFF333333), width: 1.0),
        ),
      )
      .shadow(
        BoxShadowMix(
          color: const Color(0x99000000),
          blurRadius: 40.0,
          offset: const Offset(0, 20),
        ),
      );

  // Breadcrumb badge stylers
  final breadcrumbBadgeStyle = BoxStyler()
      .height(20.0)
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
      .border(
        BorderMix.bottom(
          BorderSideMix(color: const Color(0xFF333333), width: 1.0),
        ),
      );

  // Empty state stylers
  final emptyBoxStyle = BoxStyler().height(64.0).alignment(Alignment.center);

  final emptyTextStyle = TextStyler()
      .fontSize(14.0)
      .color(const Color(0xFF888888));

  // Group heading stylers
  final headingBoxStyle = BoxStyler().padding(
    EdgeInsetsGeometryMix.symmetric(horizontal: 8.0, vertical: 6.0),
  );

  final headingTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF888888))
      .fontWeight(FontWeight.w500);

  // Item stylers
  final itemBoxStyle = BoxStyler()
      .height(48.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 16.0))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .color(const Color(0x00000000))
      .onSelected(BoxStyler().color(const Color(0xFF222222)));

  final itemRowStyle = FlexBoxStyler().crossAxisAlignment(
    CrossAxisAlignment.center,
  );

  final itemLabelStyle = TextStyler()
      .fontSize(14.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(const Color(0xFF888888))
      .onSelected(TextStyler().color(const Color(0xFFEDEDED)));

  final shortcutKeycapStyle = BoxStyler()
      .height(20.0)
      .minWidth(20.0)
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
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Box(
        style: outerCardStyle,
        child: Command(
          value: _selectedValue,
          onValueChange: (v) => setState(() => _selectedValue = v ?? ''),
          shortcuts: {
            ...CommandKeyboardShortcuts.defaults(),
            const SingleActivator(LogicalKeyboardKey.backspace):
                const DeleteCharacterIntent(forward: false),
          },
          actions: {
            VercelPopPageIntent: CallbackAction<VercelPopPageIntent>(
              onInvoke: (_) {
                if (_canPop()) _popPage();
                return null;
              },
            ),
            DeleteCharacterIntent: _VercelDeleteCharacterAction(
              _canPop,
              _popPage,
            ),
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Breadcrumb Badges
              Padding(
                padding: const EdgeInsets.only(
                  left: 4.0,
                  top: 4.0,
                  bottom: 4.0,
                ),
                child: Row(
                  spacing: 6.0,
                  children: _pages.map((p) {
                    return Box(
                      style: breadcrumbBadgeStyle,
                      child: StyledText(p, style: breadcrumbTextStyle),
                    );
                  }).toList(),
                ),
              ),

              // Search Input with bottom border line
              Box(
                style: searchInputContainerStyle,
                child: CommandInput(
                  controller: _searchController,
                  placeholder: 'What do you need?',
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: Color(0xFFEDEDED),
                    fontWeight: FontWeight.w400,
                  ),
                  placeholderStyle: const TextStyle(
                    fontSize: 17.0,
                    color: Color(0xFF707075),
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: const Color(0xFFEDEDED),
                ),
              ),

              const SizedBox(height: 8.0),

              // Command List with dynamic animated height
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 330.0),
                child: CommandList(
                  shrinkWrap: true,
                  animateHeight: true,
                  physics: const ClampingScrollPhysics(),
                  scrollbarBuilder: rawCommandScrollbarBuilder(
                    thumbColor: const Color(0x22FFFFFF),
                    thickness: 4.0,
                    radius: const Radius.circular(2.0),
                  ),
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
        spacing: 4.0,
        topSpacing: 8.0,
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
      CommandGroup(
        heading: _buildGroupHeading('Teams'),
        spacing: 4.0,
        topSpacing: 8.0,
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
      CommandGroup(
        heading: _buildGroupHeading('Help'),
        spacing: 4.0,
        topSpacing: 8.0,
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
        spacing: 4.0,
        children: [
          _buildVercelItem(
            value: 'flutter/website',
            icon: CmdkIcons.projects(size: 18),
            label: 'flutter/website',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'flutter/flutter',
            icon: CmdkIcons.projects(size: 18),
            label: 'flutter/flutter',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'definev/zenrouter',
            icon: CmdkIcons.projects(size: 18),
            label: 'definev/zenrouter',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'definev/zentoast',
            icon: CmdkIcons.projects(size: 18),
            label: 'definev/zentoast',
            shortcuts: [],
          ),
          _buildVercelItem(
            value: 'definev/cmdk',
            icon: CmdkIcons.projects(size: 18),
            label: 'definev/cmdk',
            shortcuts: [],
          ),
        ],
      ),
    ];
  }

  Widget _buildGroupHeading(String text) {
    return Box(
      style: headingBoxStyle,
      child: StyledText(text, style: headingTextStyle),
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
        return CommandItemStateProvider(
          state: state,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Box(
              style: itemBoxStyle,
              child: RowBox(
                style: itemRowStyle,
                children: [
                  SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: 12.0),
                  StyledText(label, style: itemLabelStyle),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 6.0,
                    children: shortcuts.map((key) {
                      return Box(
                        style: shortcutKeycapStyle,
                        child: key == '⇧'
                            ? CmdkIcons.shift(
                                size: 11.0,
                                color: const Color(0xFFA0A0A0),
                              )
                            : StyledText(key, style: shortcutTextStyle),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
