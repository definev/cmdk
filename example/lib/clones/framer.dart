import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk/cmdk.dart';
import 'icons.dart';
import 'styler_variants.dart';

class FramerCMDK extends StatefulWidget {
  const FramerCMDK({super.key});

  @override
  State<FramerCMDK> createState() => _FramerCMDKState();
}

class _FramerCMDKState extends State<FramerCMDK> {
  String _selectedValue = 'Button';

  // Outer frame styler
  final outerCardStyle = BoxStyler()
      .maxWidth(640.0)
      .padding(EdgeInsetsGeometryMix.all(8.0))
      .color(const Color(0xFF161618))
      .borderRadius(BorderRadiusGeometryMix.circular(16.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF2C2C30), width: 1.0),
      ))
      .shadow(BoxShadowMix(
        color: const Color(0x7F000000),
        blurRadius: 40.0,
        offset: const Offset(0, 20),
      ));

  // Header styler
  final headerBoxStyle = BoxStyler()
      .height(48.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .border(BorderMix.bottom(
        BorderSideMix(color: const Color(0xFF28282C), width: 1.0),
      ));

  // Separator styler
  final separatorStyle = BoxStyler().width(1.0).color(const Color(0xFF2C2C30));

  // Empty state stylers
  final emptyBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.all(24.0))
      .alignment(Alignment.center);

  final emptyTextStyle =
      TextStyler().fontSize(13.0).color(const Color(0xFF707075));

  // Group heading stylers
  final headingBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0, vertical: 6.0));

  final headingTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFF707075))
      .fontWeight(FontWeight.w500);

  // Item stylers
  final itemBoxStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.all(8.0))
      .borderRadius(BorderRadiusGeometryMix.circular(12.0))
      .color(const Color(0x00000000))
      .onSelected(BoxStyler().color(const Color(0xFF0091FF)));

  final itemRowStyle =
      FlexBoxStyler().crossAxisAlignment(CrossAxisAlignment.center);

  final iconWrapperStyle = BoxStyler()
      .size(32.0, 32.0)
      .color(const Color(0xFFFF7A00))
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .alignment(Alignment.center);

  final itemTitleStyle = TextStyler()
      .fontSize(14.0)
      .height(1.2)
      .fontWeight(FontWeight.w500)
      .color(const Color(0xFFEDEDED))
      .onSelected(TextStyler().color(const Color(0xFFFFFFFF)));

  final itemSubtitleStyle = TextStyler()
      .fontSize(12.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(const Color(0xFF707075))
      .onSelected(TextStyler().color(const Color(0xFFFFFFFF)));

  // Preview component stylers
  final previewButtonStyle = BoxStyler()
      .size(120.0, 40.0)
      .color(const Color(0xFF0091FF))
      .borderRadius(BorderRadiusGeometryMix.circular(6.0))
      .shadow(BoxShadowMix(
        color: const Color(0x330091FF),
        blurRadius: 12.0,
        offset: const Offset(0, 4),
      ))
      .alignment(Alignment.center);

  final previewButtonTextStyle = TextStyler()
      .fontSize(14.0)
      .fontWeight(FontWeight.w500)
      .color(const Color(0xFFFFFFFF));

  final previewInputStyle = BoxStyler()
      .size(160.0, 40.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 12.0))
      .borderRadius(BorderRadiusGeometryMix.circular(6.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF333338), width: 1.0),
      ))
      .color(const Color(0xFF1E1E22))
      .shadow(BoxShadowMix(
        color: const Color(0x1A000000),
        blurRadius: 6.0,
        offset: const Offset(0, 2),
      ))
      .alignment(Alignment.centerLeft);

  final previewInputTextStyle =
      TextStyler().fontSize(14.0).color(const Color(0xFF707075));

  final previewBadgeStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 12.0, vertical: 6.0))
      .borderRadius(BorderRadiusGeometryMix.circular(9999.0))
      .color(const Color(0x2A0091FF));

  final previewBadgeTextStyle = TextStyler()
      .fontSize(14.0)
      .fontWeight(FontWeight.w500)
      .color(const Color(0xFF0091FF));

  final previewContainerStyle = BoxStyler()
      .size(100.0, 100.0)
      .color(const Color(0xFF0091FF))
      .borderRadius(BorderRadiusGeometryMix.circular(16.0))
      .shadow(BoxShadowMix(
        color: const Color(0x400091FF),
        blurRadius: 20.0,
        offset: const Offset(0, 8),
      ));

  final previewAvatarStyle = BoxStyler()
      .size(44.0, 44.0)
      .borderRadius(BorderRadiusGeometryMix.circular(22.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF38383E), width: 1.5),
      ))
      .color(const Color(0xFF26262A))
      .alignment(Alignment.center);

  static final List<_FramerItemDef> _items = [
    _FramerItemDef(
      value: 'Button',
      subtitle: 'Trigger actions',
      icon: CmdkIcons.framerButton(size: 16),
    ),
    _FramerItemDef(
      value: 'Input',
      subtitle: 'Retrieve user input',
      icon: CmdkIcons.framerInput(size: 16),
    ),
    _FramerItemDef(
      value: 'Radio',
      subtitle: 'Single choice input',
      icon: CmdkIcons.framerRadio(size: 16),
    ),
    _FramerItemDef(
      value: 'Badge',
      subtitle: 'Annotate context',
      icon: CmdkIcons.framerBadge(size: 16),
    ),
    _FramerItemDef(
      value: 'Slider',
      subtitle: 'Free range picker',
      icon: CmdkIcons.framerSlider(size: 16),
    ),
    _FramerItemDef(
      value: 'Avatar',
      subtitle: 'Illustrate the user',
      icon: CmdkIcons.framerAvatar(size: 16),
    ),
    _FramerItemDef(
      value: 'Container',
      subtitle: 'Lay out items',
      icon: CmdkIcons.framerContainer(size: 16),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Box(
      style: outerCardStyle,
      child: Command(
        value: _selectedValue,
        onValueChange: (v) => setState(() => _selectedValue = v ?? ''),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Search Icon & Bottom Line
            Box(
              style: headerBoxStyle,
              child: Row(
                children: [
                  CmdkIcons.search(size: 20, color: const Color(0xFF707075)),
                  const SizedBox(width: 8.0),
                  const Expanded(
                    child: CommandInput(
                      placeholder:
                          'Find components, packages, and interactions...',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFFEDEDED),
                        fontWeight: FontWeight.w400,
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF707075),
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: Color(0xFF0091FF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8.0),

            // Split View Layout with compact 325px height
            SizedBox(
              height: 325.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column (40% width)
                  Expanded(
                    flex: 4,
                    child: CommandList(
                      padding: const EdgeInsets.only(right: 8.0),
                      children: [
                        CommandEmpty(
                          child: Box(
                            style: emptyBoxStyle,
                            child: StyledText(
                              'No components found.',
                              style: emptyTextStyle,
                            ),
                          ),
                        ),
                        CommandGroup(
                          heading: _buildGroupHeading('Components'),
                          spacing: 4.0,
                          children: _items
                              .map((item) => _buildFramerItem(item))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Separator Line
                  Box(style: separatorStyle),

                  // Right Column (60% width) Live Interactive Component Preview
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey(_selectedValue),
                          child: _buildComponentPreview(_selectedValue),
                        ),
                      ),
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

  Widget _buildGroupHeading(String text) {
    return Box(
      style: headingBoxStyle,
      child: StyledText(
        text,
        style: headingTextStyle,
      ),
    );
  }

  Widget _buildFramerItem(_FramerItemDef item) {
    return CommandItem(
      value: item.value,
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
                  // Orange square icon wrapper
                  Box(
                    style: iconWrapperStyle,
                    child: item.icon,
                  ),
                  const SizedBox(width: 12.0),
                  // Meta column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StyledText(
                          item.value,
                          style: itemTitleStyle,
                        ),
                        const SizedBox(height: 2.0),
                        StyledText(
                          item.subtitle,
                          style: itemSubtitleStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComponentPreview(String value) {
    switch (value) {
      case 'Button':
        return Box(
          style: previewButtonStyle,
          child: StyledText(
            'Primary',
            style: previewButtonTextStyle,
          ),
        );

      case 'Input':
        return Box(
          style: previewInputStyle,
          child: StyledText(
            'Placeholder',
            style: previewInputTextStyle,
          ),
        );

      case 'Radio':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Box(
              style: BoxStyler()
                  .size(20.0, 20.0)
                  .borderRadius(BorderRadiusGeometryMix.circular(10.0))
                  .border(BorderMix.all(
                    BorderSideMix(color: const Color(0xFF0091FF), width: 2.0),
                  ))
                  .alignment(Alignment.center),
              child: Box(
                style: BoxStyler()
                    .size(10.0, 10.0)
                    .borderRadius(BorderRadiusGeometryMix.circular(5.0))
                    .color(const Color(0xFF0091FF)),
              ),
            ),
            const SizedBox(width: 8.0),
            StyledText(
              'Radio Button',
              style: TextStyler()
                  .fontSize(14.0)
                  .fontWeight(FontWeight.w500)
                  .color(const Color(0xFFEDEDED)),
            ),
          ],
        );

      case 'Badge':
        return Box(
          style: previewBadgeStyle,
          child: StyledText(
            'Badge',
            style: previewBadgeTextStyle,
          ),
        );

      case 'Slider':
        return Container(
          width: 200.0,
          height: 20.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999.0),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0091FF),
                Color(0xFF0091FF),
                Color(0xFF28282C),
                Color(0xFF28282C),
              ],
              stops: [0.0, 0.45, 0.45, 1.0],
            ),
          ),
          child: Align(
            alignment: const Alignment(-0.1, 0.0),
            child: Box(
              style: BoxStyler()
                  .size(20.0, 20.0)
                  .borderRadius(BorderRadiusGeometryMix.circular(10.0))
                  .color(const Color(0xFFFFFFFF))
                  .shadow(BoxShadowMix(
                    color: const Color(0x40000000),
                    blurRadius: 4.0,
                    offset: const Offset(0, 1),
                  )),
            ),
          ),
        );

      case 'Avatar':
        return Box(
          style: previewAvatarStyle,
          child:
              CmdkIcons.framerAvatar(size: 24, color: const Color(0xFFEDEDED)),
        );

      case 'Container':
        return Box(style: previewContainerStyle);

      default:
        return const SizedBox.shrink();
    }
  }
}

class _FramerItemDef {
  const _FramerItemDef({
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String value;
  final String subtitle;
  final Widget icon;
}
