import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk/cmdk.dart';
import 'icons.dart';

class LinearCMDK extends StatefulWidget {
  const LinearCMDK({super.key});

  @override
  State<LinearCMDK> createState() => _LinearCMDKState();
}

class _LinearCMDKState extends State<LinearCMDK> {
  String _selectedValue = 'Assign to...';

  // Outer frame styler
  final outerCardStyle = BoxStyler()
      .maxWidth(640.0)
      .borderRadius(BorderRadiusGeometryMix.circular(8.0))
      .border(BorderMix.all(
        BorderSideMix(color: const Color(0xFF38393D), width: 1.0),
      ))
      .gradient(LinearGradientMix(
        begin: const Alignment(-0.8, -0.6),
        end: const Alignment(0.8, 0.6),
        colors: const [Color(0xFF27282B), Color(0xFF2D2E31)],
      ))
      .shadow(BoxShadowMix(
        color: const Color(0x66000000),
        blurRadius: 40.0,
        offset: const Offset(0, 20),
      ));

  // Badge stylers
  final badgeBoxStyle = BoxStyler()
      .height(24.0)
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 8.0))
      .color(const Color(0xFF232323))
      .borderRadius(BorderRadiusGeometryMix.circular(4.0))
      .alignment(Alignment.center);

  final badgeTextStyle = TextStyler()
      .fontSize(12.0)
      .color(const Color(0xFFA0A0A0))
      .fontWeight(FontWeight.w500);

  // Input wrapper styler
  final inputContainerStyle = BoxStyler()
      .padding(EdgeInsetsGeometryMix.all(20.0))
      .border(BorderMix.bottom(
        BorderSideMix(color: const Color(0xFF343434), width: 1.0),
      ));

  // Empty state stylers
  final emptyBoxStyle = BoxStyler().height(64.0).alignment(Alignment.center);

  final emptyTextStyle =
      TextStyler().fontSize(14.0).color(const Color(0xFFA0A0A0));

  // Item stylers
  BoxStyler itemBoxStyle(bool isSelected) => BoxStyler()
      .height(48.0)
      .color(isSelected ? const Color(0xFF232323) : const Color(0x00000000));

  final accentIndicatorStyle =
      BoxStyler().width(3.0).color(const Color(0xFF5F6AD2));

  final itemContentRowStyle = FlexBoxStyler()
      .padding(EdgeInsetsGeometryMix.symmetric(horizontal: 16.0))
      .crossAxisAlignment(CrossAxisAlignment.center);

  TextStyler itemLabelStyle(bool isSelected) => TextStyler()
      .fontSize(14.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(isSelected ? const Color(0xFFFFFFFF) : const Color(0xFFEDEDED));

  final shortcutTextStyle = TextStyler()
      .fontSize(13.0)
      .height(1.2)
      .fontWeight(FontWeight.w400)
      .color(const Color(0xFFA0A0A0));

  static final List<_LinearItemDef> _items = [
    _LinearItemDef(
      icon: (c) => CmdkIcons.assignTo(size: 16, color: c),
      label: 'Assign to...',
      shortcut: ['A'],
    ),
    _LinearItemDef(
      icon: (c) => CmdkIcons.assignToMe(size: 16, color: c),
      label: 'Assign to me',
      shortcut: ['I'],
    ),
    _LinearItemDef(
      icon: (c) => CmdkIcons.changeStatus(size: 16, color: c),
      label: 'Change status...',
      shortcut: ['S'],
    ),
    _LinearItemDef(
      icon: (c) => CmdkIcons.changePriority(size: 16, color: c),
      label: 'Change priority...',
      shortcut: ['P'],
    ),
    _LinearItemDef(
      icon: (c) => CmdkIcons.changeLabels(size: 16, color: c),
      label: 'Change labels...',
      shortcut: ['L'],
    ),
    _LinearItemDef(
      icon: (c) => CmdkIcons.removeLabel(size: 16, color: c),
      label: 'Remove label...',
      shortcut: ['⇧', 'L'],
    ),
    _LinearItemDef(
      icon: (c) => CmdkIcons.setDueDate(size: 16, color: c),
      label: 'Set due date...',
      shortcut: ['⇧', 'D'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Box(
      style: outerCardStyle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Command(
          value: _selectedValue,
          onValueChange: (v) => setState(() => _selectedValue = v ?? ''),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Badge: "Issue - FUN-343"
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Box(
                      style: badgeBoxStyle,
                      child: StyledText(
                        'Issue - FUN-343',
                        style: badgeTextStyle,
                      ),
                    ),
                  ],
                ),
              ),

              // Large 18px Input with bottom divider
              Box(
                style: inputContainerStyle,
                child: const CommandInput(
                  placeholder: 'Type a command or search...',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFFEDEDED),
                    fontWeight: FontWeight.w400,
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF707075),
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: Color(0xFF6E5ED2),
                ),
              ),

              // Item List with dynamic height and scroll
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300.0),
                child: CommandList(
                  shrinkWrap: true,
                  animateHeight: true,
                  spacing: 4.0,
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
                    ..._items.map((item) => _buildLinearItem(item)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinearItem(_LinearItemDef item) {
    return CommandItem(
      value: item.label,
      builder: (context, state) {
        final isSelected = state.isSelected;
        final iconColor =
            isSelected ? const Color(0xFFEDEDED) : const Color(0xFFA0A0A0);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Box(
            style: itemBoxStyle(isSelected),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Blue accent indicator on the very left edge when selected
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Box(style: accentIndicatorStyle),
                  ),

                // Content row strictly centered vertically across the full 48px tile
                Positioned.fill(
                  child: RowBox(
                    style: itemContentRowStyle,
                    children: [
                      SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: Center(child: item.icon(iconColor)),
                      ),
                      const SizedBox(width: 12.0),
                      StyledText(
                        item.label,
                        style: itemLabelStyle(isSelected),
                      ),
                      const Spacer(),
                      // Right shortcuts
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 6.0,
                        children: item.shortcut.map((key) {
                          return key == '⇧'
                              ? CmdkIcons.shift(
                                  size: 13.0, color: const Color(0xFFA0A0A0))
                              : StyledText(
                                  key,
                                  style: shortcutTextStyle,
                                );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LinearItemDef {
  const _LinearItemDef({
    required this.icon,
    required this.label,
    required this.shortcut,
  });

  final Widget Function(Color color) icon;
  final String label;
  final List<String> shortcut;
}
