import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'command_menu.dart';

/// Runnable examples of the three modal presentation helpers in cmdk_ui.
class CommandDialogExamples extends StatefulWidget {
  const CommandDialogExamples({super.key});

  @override
  State<CommandDialogExamples> createState() => _CommandDialogExamplesState();
}

class _CommandDialogExamplesState extends State<CommandDialogExamples> {
  String? _result;
  int _activePresentation = 0;

  Future<void> _showMaterial() async {
    final selected = await showMaterialCommandDialog<String>(
      context: context,
      builder: (dialogContext) => const Dialog(
        backgroundColor: Color(0x00000000),
        elevation: 0,
        child: CommandMenu(),
      ),
    );
    _recordResult(selected);
  }

  Future<void> _showCupertino() async {
    final selected = await showCupertinoCommandDialog<String>(
      context: context,
      builder: (dialogContext) => Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(dialogContext).bottom,
          ),
          child: const CommandMenu(),
        ),
      ),
    );
    _recordResult(selected);
  }

  Future<void> _showBottomSheet() async {
    final selected = await showCommandModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E1E20),
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) => const CommandMenu(),
    );
    _recordResult(selected);
  }

  void _recordResult(String? selected) {
    if (!mounted) return;
    setState(() {
      _result = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            MediaQuery.sizeOf(context).width < 560 ||
            constraints.maxWidth < 320;
        final itemWidth = compact ? 44.0 : 104.0;
        final itemHeight = compact ? 38.0 : 32.0;
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        final presentations = [
          (
            label: 'Material',
            semanticLabel: 'Material dialog',
            icon: Icons.web_asset_outlined,
            open: _showMaterial,
          ),
          (
            label: 'Cupertino',
            semanticLabel: 'Cupertino dialog',
            icon: Icons.apple,
            open: _showCupertino,
          ),
          (
            label: 'Sheet',
            semanticLabel: 'Bottom sheet',
            icon: Icons.vertical_align_bottom_rounded,
            open: _showBottomSheet,
          ),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF18181C),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFF28292E)),
              ),
              child: SizedBox(
                width: itemWidth * presentations.length,
                height: itemHeight,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: reduceMotion ? 0 : 220),
                      curve: Curves.easeOutCubic,
                      left: _activePresentation * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2D34),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (index, presentation)
                            in presentations.indexed)
                          Semantics(
                            key: ValueKey(presentation.semanticLabel),
                            label: presentation.semanticLabel,
                            child: SizedBox(
                              width: itemWidth,
                              height: itemHeight,
                              child: TextButton(
                                onPressed: () {
                                  setState(() => _activePresentation = index);
                                  presentation.open();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: _activePresentation == index
                                      ? const Color(0xFFF4F4F4)
                                      : const Color(0xFF8A8F98),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                child: ExcludeSemantics(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(presentation.icon, size: 15),
                                      if (!compact) ...[
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            presentation.label,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: _result == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 12,
                          color: Color(0xFF8A8F98),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _result!,
                          style: const TextStyle(
                            color: Color(0xFF8A8F98),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
