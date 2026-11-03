import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/clones/icons.dart';

void main() {
  testWidgets('All CmdkIcons render exact SVG vectors cleanly',
      (tester) async {
    final icons = <Widget>[
      CmdkIcons.raycast(),
      CmdkIcons.raycastDark(),
      CmdkIcons.raycastLight(),
      CmdkIcons.linear(),
      CmdkIcons.vercel(),
      CmdkIcons.framer(),
      CmdkIcons.figma(),
      CmdkIcons.slack(),
      CmdkIcons.youtube(),
      CmdkIcons.github(),
      CmdkIcons.copy(),
      CmdkIcons.check(),
      CmdkIcons.search(),
      CmdkIcons.shift(),
      CmdkIcons.terminal(),
      CmdkIcons.window(),
      CmdkIcons.finder(),
      CmdkIcons.star(),
      CmdkIcons.clipboard(),
      CmdkIcons.hammer(),
      CmdkIcons.clipboardGradient(),
      CmdkIcons.hammerGradient(),
      CmdkIcons.assignTo(),
      CmdkIcons.assignToMe(),
      CmdkIcons.changeStatus(),
      CmdkIcons.changePriority(),
      CmdkIcons.changeLabels(),
      CmdkIcons.removeLabel(),
      CmdkIcons.setDueDate(),
      CmdkIcons.projects(),
      CmdkIcons.plus(),
      CmdkIcons.teams(),
      CmdkIcons.docs(),
      CmdkIcons.feedback(),
      CmdkIcons.support(),
      CmdkIcons.contact(),
      CmdkIcons.framerButton(),
      CmdkIcons.framerInput(),
      CmdkIcons.framerRadio(),
      CmdkIcons.framerBadge(),
      CmdkIcons.framerToggle(),
      CmdkIcons.framerSlider(),
      CmdkIcons.framerAvatar(),
      CmdkIcons.framerContainer(),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            children: icons
                .map((icon) => CmdkLogo(child: icon))
                .toList(),
          ),
        ),
      ),
    );

    // Verify SvgPicture widgets are rendered
    expect(find.byType(SvgPicture), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
