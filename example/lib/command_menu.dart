import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'clones/icons.dart';

/// A Raycast-styled command menu that returns its selection from a modal route.
class CommandMenu extends StatelessWidget {
  const CommandMenu({super.key});

  static const _commands = [
    (value: 'Create Project', icon: Icons.add, keywords: ['new', 'workspace']),
    (value: 'Search Files', icon: Icons.search, keywords: ['find', 'folder']),
    (value: 'Open Settings', icon: Icons.settings, keywords: ['preferences']),
  ];

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 360),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C2C30)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x7F000000),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Color(0xFFEDEDED),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            child: Command(
              label: 'Commands',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x0038BDF8),
                          Color(0x4438BDF8),
                          Color(0xCCEC4899),
                          Color(0x00EC4899),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: AdaptiveCommandInput(
                            placeholder: 'Search for apps and commands…',
                            style: TextStyle(
                              color: Color(0xFFEDEDED),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            placeholderStyle: TextStyle(
                              color: Color(0xFF707075),
                              fontSize: 15,
                            ),
                            cursorColor: Color(0xFFFF6363),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close command menu',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF707075),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFF26262A)),
                  Flexible(
                    child: CommandList(
                      animateHeight: true,
                      padding: const EdgeInsets.all(8),
                      scrollbarBuilder: rawCommandScrollbarBuilder(
                        thumbColor: const Color(0xFF2C2C32),
                        thickness: 4,
                        radius: const Radius.circular(2),
                      ),
                      children: [
                        const CommandEmpty(
                          child: SizedBox(
                            height: 64,
                            child: Center(
                              child: Text(
                                'No commands found.',
                                style: TextStyle(color: Color(0xFF707075)),
                              ),
                            ),
                          ),
                        ),
                        CommandGroup(
                          heading: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              'Commands',
                              style: TextStyle(
                                color: Color(0xFF707075),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          children: [
                            for (final command in _commands)
                              CommandItem(
                                value: command.value,
                                keywords: command.keywords,
                                onSelect: () =>
                                    Navigator.of(context).pop(command.value),
                                builder: (context, state) => Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.isSelected
                                        ? const Color(0xFF28282C)
                                        : state.isHovered
                                        ? const Color(0xFF242427)
                                        : const Color(0x00000000),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        command.icon,
                                        size: 20,
                                        color: const Color(0xFFB8B8C0),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          command.value,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: state.isSelected
                                                ? const Color(0xFFFFFFFF)
                                                : const Color(0xFFEDEDED),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Command',
                                        style: TextStyle(
                                          color: Color(0xFF707075),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF18181A),
                      border: Border(top: BorderSide(color: Color(0xFF26262A))),
                    ),
                    child: Row(
                      children: [
                        CmdkIcons.raycast(
                          size: 16,
                          color: const Color(0xFF8E8E93),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _keycap('↑'),
                                  const SizedBox(width: 3),
                                  _keycap('↓'),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Navigate',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Open Command',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _keycap('↵'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _keycap(String label) => Container(
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFF26262A),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF333338)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}
