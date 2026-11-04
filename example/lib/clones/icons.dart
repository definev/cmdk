import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Wraps an icon with a subtle diffused background blur glow,
/// matching the original cmdk Logo wrapper component from the web.
class CmdkLogo extends StatelessWidget {
  const CmdkLogo({super.key, required this.child, this.size = 20.0});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 1.5,
            child: Opacity(
              opacity: 0.4,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: child,
              ),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}

/// Exact vector icons matching the original web cmdk implementation 100%.
class CmdkIcons {
  // ==================== APP & BRAND LOGOS ====================

  /// Raycast default mark (28x28 viewBox).
  static Widget raycast({double size = 16.0, Color? color}) {
    return _svg(_rawRaycast, size: size, color: color);
  }

  /// Raycast dark mode detailed footer mark (1024x1024 viewBox).
  static Widget raycastDark({double size = 20.0, Color? color}) {
    return _svg(_rawRaycastDark, size: size, color: color);
  }

  /// Raycast light mode detailed footer mark (1024x1024 viewBox).
  static Widget raycastLight({double size = 20.0, Color? color}) {
    return _svg(_rawRaycastLight, size: size, color: color);
  }

  /// Linear brand mark (64x64 viewBox).
  static Widget linear({double size = 16.0, Color? color}) {
    return _svg(_rawLinear, size: size, color: color);
  }

  /// Vercel triangle mark (75x65 viewBox).
  static Widget vercel({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawVercel, size: size, color: color);
  }

  /// Framer geometric mark (16x24 viewBox).
  static Widget framer({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramer, size: size, color: color);
  }

  /// Liquid Glass refractive lens / droplet mark.
  static Widget liquidGlass({double size = 16.0, Color? color}) {
    return _svg(_rawLiquidGlass, size: size, color: color);
  }

  /// Figma multi-color logo (48x48 viewBox).
  static Widget figma({double size = 16.0}) {
    return _svg(_rawFigma, size: size);
  }

  /// Slack multi-color logo (48x48 viewBox).
  static Widget slack({double size = 16.0}) {
    return _svg(_rawSlack, size: size);
  }

  /// YouTube red & white logo (48x48 viewBox).
  static Widget youtube({double size = 16.0}) {
    return _svg(_rawYouTube, size: size);
  }

  /// GitHub mark (14x14 viewBox).
  static Widget github({
    double size = 14.0,
    Color color = const Color(0xFFEDEDED),
  }) {
    return _svg(_rawGitHub, size: size, color: color);
  }

  // ==================== COMMON UTILITY ICONS ====================

  /// Copy icon (24x24 viewBox).
  static Widget copy({
    double size = 14.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawCopy, size: size, color: color);
  }

  /// Check / Copied icon (24x24 viewBox).
  static Widget check({
    double size = 14.0,
    Color color = const Color(0xFF10B981),
  }) {
    return _svg(_rawCheck, size: size, color: color);
  }

  /// Search magnifying glass icon (24x24 viewBox).
  static Widget search({
    double size = 18.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawSearch, size: size, color: color);
  }

  /// Shift key arrow icon (12x12 viewBox).
  static Widget shift({
    double size = 12.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawShift, size: size, color: color);
  }

  /// Terminal prompt icon (24x24 viewBox).
  static Widget terminal({
    double size = 16.0,
    Color color = const Color(0xFFEDEDED),
  }) {
    return _svg(_rawTerminal, size: size, color: color);
  }

  // ==================== RAYCAST CLONE ICONS ====================

  /// Raycast SubCommand Window icon (16x16 viewBox).
  static Widget window({
    double size = 16.0,
    Color color = const Color(0xFFEDEDED),
  }) {
    return _svg(_rawWindow, size: size, color: color);
  }

  /// Raycast SubCommand Finder icon (16x16 viewBox).
  static Widget finder({
    double size = 16.0,
    Color color = const Color(0xFFEDEDED),
  }) {
    return _svg(_rawFinder, size: size, color: color);
  }

  /// Raycast SubCommand Star icon (16x16 viewBox).
  static Widget star({
    double size = 16.0,
    Color color = const Color(0xFFEDEDED),
  }) {
    return _svg(_rawStar, size: size, color: color);
  }

  /// Raw Clipboard outline icon (16x16 viewBox).
  static Widget clipboard({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawClipboard, size: size, color: color);
  }

  /// Raw Hammer outline icon (16x16 viewBox).
  static Widget hammer({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawHammer, size: size, color: color);
  }

  /// Raycast Clipboard icon badge with red gradient.
  static Widget clipboardGradient({double size = 20.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF55354), Color(0xFFEB4646)],
        ),
      ),
      alignment: Alignment.center,
      child: CmdkIcons.clipboard(size: 14.0, color: const Color(0xFFFFFFFF)),
    );
  }

  /// Raycast Hammer icon badge with teal gradient.
  static Widget hammerGradient({double size = 20.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6CB9A3), Color(0xFF2C6459)],
        ),
      ),
      alignment: Alignment.center,
      child: CmdkIcons.hammer(size: 14.0, color: const Color(0xFFFFFFFF)),
    );
  }

  // ==================== LINEAR CLONE ICONS ====================

  static Widget assignTo({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawAssignTo, size: size, color: color);
  }

  static Widget assignToMe({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawAssignToMe, size: size, color: color);
  }

  static Widget changeStatus({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawChangeStatus, size: size, color: color);
  }

  static Widget changePriority({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawChangePriority, size: size, color: color);
  }

  static Widget changeLabels({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawChangeLabels, size: size, color: color);
  }

  static Widget removeLabel({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawChangeLabels, size: size, color: color);
  }

  static Widget setDueDate({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawSetDueDate, size: size, color: color);
  }

  // ==================== VERCEL CLONE ICONS ====================

  static Widget projects({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawProjects, size: size, color: color);
  }

  static Widget plus({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawPlus, size: size, color: color);
  }

  static Widget teams({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawTeams, size: size, color: color);
  }

  static Widget docs({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawDocs, size: size, color: color);
  }

  static Widget feedback({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawFeedback, size: size, color: color);
  }

  static Widget support({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawSupport, size: size, color: color);
  }

  static Widget contact({
    double size = 16.0,
    Color color = const Color(0xFF888888),
  }) {
    return _svg(_rawSupport, size: size, color: color);
  }

  // ==================== FRAMER CLONE ICONS ====================

  static Widget framerButton({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerButton, size: size, color: color);
  }

  static Widget framerInput({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerInput, size: size, color: color);
  }

  static Widget framerRadio({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerRadio, size: size, color: color);
  }

  static Widget framerBadge({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerBadge, size: size, color: color);
  }

  static Widget framerToggle({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerToggle, size: size, color: color);
  }

  static Widget framerSlider({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerSlider, size: size, color: color);
  }

  static Widget framerAvatar({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerAvatar, size: size, color: color);
  }

  static Widget framerContainer({
    double size = 16.0,
    Color color = const Color(0xFFFFFFFF),
  }) {
    return _svg(_rawFramerContainer, size: size, color: color);
  }

  // ==================== SVG HELPER ====================

  static Widget _svg(String raw, {required double size, Color? color}) {
    return SvgPicture.string(
      raw,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}

// ==================== RAW SVG DEFINITIONS (EXACT FROM WEB) ====================

const String _rawFigma = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <path fill="#e64a19" d="M26,17h-8c-3.866,0-7-3.134-7-7v0c0-3.866,3.134-7,7-7h8V17z" />
  <path fill="#7c4dff" d="M25,31h-7c-3.866,0-7-3.134-7-7v0c0-3.866,3.134-7,7-7h7V31z" />
  <path fill="#66bb6a" d="M18,45L18,45c-3.866,0-7-3.134-7-7v0c0-3.866,3.134-7,7-7h7v7C25,41.866,21.866,45,18,45z" />
  <path fill="#ff7043" d="M32,17h-7V3h7c3.866,0,7,3.134,7,7v0C39,13.866,35.866,17,32,17z" />
  <circle cx="32" cy="24" r="7" fill="#29b6f6" />
</svg>
''';

const String _rawRaycast = '''
<svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M7 18.073V20.994L0 13.994L1.46 12.534L7 18.075V18.073ZM9.921 20.994H7L14 27.994L15.46 26.534L9.921 20.994V20.994ZM26.535 15.456L27.996 13.994L13.996 -0.00598145L12.538 1.46002L18.077 6.99802H14.73L10.864 3.14002L9.404 4.60002L11.809 7.00402H10.129V17.87H20.994V16.19L23.399 18.594L24.859 17.134L20.994 13.268V9.92102L26.534 15.456H26.535ZM7.73 6.27002L6.265 7.73202L7.833 9.29802L9.294 7.83802L7.73 6.27002ZM20.162 18.702L18.702 20.164L20.268 21.732L21.73 20.27L20.162 18.702V18.702ZM4.596 9.40402L3.134 10.866L7 14.732V11.809L4.596 9.40402ZM16.192 21H13.268L17.134 24.866L18.596 23.404L16.192 21Z"
    fill="#FF6363"
  />
</svg>
''';

const String _rawRaycastDark = '''
<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M301.144 634.799V722.856L90 511.712L134.244 467.804L301.144 634.799ZM389.201 722.856H301.144L512.288 934L556.34 889.996L389.201 722.856ZM889.996 555.956L934 511.904L512.096 90L468.092 134.052L634.799 300.952H534.026L417.657 184.679L373.605 228.683L446.065 301.144H395.631V628.561H723.048V577.934L795.509 650.395L839.561 606.391L723.048 489.878V389.105L889.996 555.956ZM323.17 278.926L279.166 322.978L326.385 370.198L370.39 326.145L323.17 278.926ZM697.855 653.61L653.994 697.615L701.214 744.834L745.218 700.782L697.855 653.61ZM228.731 373.413L184.679 417.465L301.144 533.93V445.826L228.731 373.413ZM578.174 722.856H490.07L606.535 839.321L650.587 795.269L578.174 722.856Z"
    fill="#FF6363"
  />
</svg>
''';

const String _rawRaycastLight = '''
<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M934.302 511.971L890.259 556.017L723.156 388.902V300.754L934.302 511.971ZM511.897 89.5373L467.854 133.583L634.957 300.698H723.099L511.897 89.5373ZM417.334 184.275L373.235 228.377L445.776 300.923H533.918L417.334 184.275ZM723.099 490.061V578.209L795.641 650.755L839.74 606.652L723.099 490.061ZM697.868 653.965L723.099 628.732H395.313V300.754L370.081 325.987L322.772 278.675L278.56 322.833L325.869 370.146L300.638 395.379V446.071L228.097 373.525L183.997 417.627L300.638 534.275V634.871L133.59 467.925L89.4912 512.027L511.897 934.461L555.996 890.359L388.892 723.244H489.875L606.516 839.892L650.615 795.79L578.074 723.244H628.762L653.994 698.011L701.303 745.323L745.402 701.221L697.868 653.965Z"
    fill="#FF6363"
  />
</svg>
''';

const String _rawYouTube = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <path
    fill="#FF3D00"
    d="M43.2,33.9c-0.4,2.1-2.1,3.7-4.2,4c-3.3,0.5-8.8,1.1-15,1.1c-6.1,0-11.6-0.6-15-1.1c-2.1-0.3-3.8-1.9-4.2-4C4.4,31.6,4,28.2,4,24c0-4.2,0.4-7.6,0.8-9.9c0.4-2.1,2.1-3.7,4.2-4C12.3,9.6,17.8,9,24,9c6.2,0,11.6,0.6,15,1.1c2.1,0.3,3.8,1.9,4.2,4c0.4,2.3,0.9,5.7,0.9,9.9C44,28.2,43.6,31.6,43.2,33.9z"
  />
  <path fill="#FFF" d="M20 31L20 17 32 24z" />
</svg>
''';

const String _rawSlack = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <path
    fill="#33d375"
    d="M33,8c0-2.209-1.791-4-4-4s-4,1.791-4,4c0,1.254,0,9.741,0,11c0,2.209,1.791,4,4,4s4-1.791,4-4	C33,17.741,33,9.254,33,8z"
  />
  <path
    fill="#33d375"
    d="M43,19c0,2.209-1.791,4-4,4c-1.195,0-4,0-4,0s0-2.986,0-4c0-2.209,1.791-4,4-4S43,16.791,43,19z"
  />
  <path
    fill="#40c4ff"
    d="M8,14c-2.209,0-4,1.791-4,4s1.791,4,4,4c1.254,0,9.741,0,11,0c2.209,0,4-1.791,4-4s-1.791-4-4-4	C17.741,14,9.254,14,8,14z"
  />
  <path
    fill="#40c4ff"
    d="M19,4c2.209,0,4,1.791,4,4c0,1.195,0,4,0,4s-2.986,0-4,0c-2.209,0-4-1.791-4-4S16.791,4,19,4z"
  />
  <path
    fill="#e91e63"
    d="M14,39.006C14,41.212,15.791,43,18,43s4-1.788,4-3.994c0-1.252,0-9.727,0-10.984	c0-2.206-1.791-3.994-4-3.994s-4,1.788-4,3.994C14,29.279,14,37.754,14,39.006z"
  />
  <path
    fill="#e91e63"
    d="M4,28.022c0-2.206,1.791-3.994,4-3.994c1.195,0,4,0,4,0s0,2.981,0,3.994c0,2.206-1.791,3.994-4,3.994	S4,30.228,4,28.022z"
  />
  <path
    fill="#ffc107"
    d="M39,33c2.209,0,4-1.791,4-4s-1.791-4-4-4c-1.254,0-9.741,0-11,0c-2.209,0-4,1.791-4,4s1.791,4,4,4	C29.258,33,37.746,33,39,33z"
  />
  <path
    fill="#ffc107"
    d="M28,43c-2.209,0-4-1.791-4-4c0-1.195,0-4,0-4s2.986,0,4,0c2.209,0,4,1.791,4,4S30.209,43,28,43z"
  />
</svg>
''';

const String _rawVercel = '''
<svg xmlns="http://www.w3.org/2000/svg" aria-label="Vercel Logo" fill="#FFFFFF" viewBox="0 0 75 65">
  <path d="M37.59.25l36.95 64H.64l36.95-64z"></path>
</svg>
''';

const String _rawLinear = '''
<svg width="64" height="64" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M0.403013 37.3991L26.6009 63.597C13.2225 61.3356 2.66442 50.7775 0.403013 37.3991Z"
    fill="#5E6AD2"
  ></path>
  <path
    d="M0 30.2868L33.7132 64C35.7182 63.8929 37.6742 63.6013 39.5645 63.142L0.85799 24.4355C0.398679 26.3259 0.10713 28.2818 0 30.2868Z"
    fill="#5E6AD2"
  ></path>
  <path
    d="M2.53593 19.4042L44.5958 61.4641C46.1277 60.8066 47.598 60.0331 48.9956 59.1546L4.84543 15.0044C3.96691 16.402 3.19339 17.8723 2.53593 19.4042Z"
    fill="#5E6AD2"
  ></path>
  <path
    d="M7.69501 11.1447C13.5677 4.32093 22.2677 0 31.9769 0C49.6628 0 64 14.3372 64 32.0231C64 41.7323 59.6791 50.4323 52.8553 56.305L7.69501 11.1447Z"
    fill="#5E6AD2"
  ></path>
</svg>
''';

const String _rawFramer = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 24">
  <path
    d="M 16 0 L 16 8 L 8 8 L 0 0 Z M 0 8 L 8 8 L 16 16 L 8 16 L 8 24 L 0 16 Z"
    fill="#FFFFFF"
  ></path>
</svg>
''';

const String _rawCopy = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M19.4 20H9.6C9.26863 20 9 19.7314 9 19.4V9.6C9 9.26863 9.26863 9 9.6 9H19.4C19.7314 9 20 9.26863 20 9.6V19.4C20 19.7314 19.7314 20 19.4 20Z"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
  <path
    d="M15 9V4.6C15 4.26863 14.7314 4 14.4 4H4.6C4.26863 4 4 4.26863 4 4.6V14.4C4 14.7314 4.26863 15 4.6 15H9"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

const String _rawCheck = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M5 13L9 17L19 7" stroke="#FFFFFF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
</svg>
''';

const String _rawGitHub = '''
<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M7 0.175049C3.128 0.175049 0 3.30305 0 7.17505C0 10.259 2.013 12.885 4.79 13.825C5.14 13.891 5.272 13.672 5.272 13.497V12.316C3.325 12.731 2.909 11.375 2.909 11.375C2.581 10.565 2.122 10.347 2.122 10.347C1.488 9.90905 2.166 9.93105 2.166 9.93105C2.866 9.97505 3.237 10.653 3.237 10.653C3.872 11.725 4.878 11.419 5.272 11.243C5.338 10.784 5.512 10.478 5.709 10.303C4.156 10.128 2.516 9.51605 2.516 6.84705C2.516 6.08105 2.778 5.46905 3.237 4.96605C3.172 4.79105 2.931 4.06905 3.303 3.10605C3.303 3.10605 3.893 2.90905 5.228 3.82805C5.79831 3.67179 6.38668 3.5911 6.978 3.58805C7.568 3.58805 8.181 3.67505 8.728 3.82805C10.063 2.93105 10.653 3.10605 10.653 3.10605C11.025 4.06905 10.784 4.79105 10.719 4.96605C11.179 5.44605 11.441 6.08105 11.441 6.84605C11.441 9.53705 9.8 10.128 8.247 10.303C8.487 10.522 8.728 10.937 8.728 11.593V13.519C8.728 13.716 8.859 13.934 9.209 13.847C11.988 12.884 14 10.259 14 7.17505C14 3.30305 10.872 0.175049 7 0.175049V0.175049Z"
    fill="#FFFFFF"
  />
</svg>
''';

const String _rawTerminal = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <polyline points="4 17 10 11 4 5"></polyline>
  <line x1="12" y1="19" x2="20" y2="19"></line>
</svg>
''';

const String _rawWindow = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M14.25 4.75V3.75C14.25 2.64543 13.3546 1.75 12.25 1.75H3.75C2.64543 1.75 1.75 2.64543 1.75 3.75V4.75M14.25 4.75V12.25C14.25 13.3546 13.3546 14.25 12.25 14.25H3.75C2.64543 14.25 1.75 13.3546 1.75 12.25V4.75M14.25 4.75H1.75"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

const String _rawFinder = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M5 4.75V6.25M11 4.75V6.25M8.75 1.75H3.75C2.64543 1.75 1.75 2.64543 1.75 3.75V12.25C1.75 13.3546 2.64543 14.25 3.75 14.25H8.75M8.75 1.75H12.25C13.3546 1.75 14.25 2.64543 14.25 3.75V12.25C14.25 13.3546 13.3546 14.25 12.25 14.25H8.75M8.75 1.75L7.08831 7.1505C6.9202 7.69686 7.32873 8.25 7.90037 8.25C8.36961 8.25 8.75 8.63039 8.75 9.09963V14.25M5 10.3203C5 10.3203 5.95605 11.25 8 11.25C10.0439 11.25 11 10.3203 11 10.3203"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

const String _rawStar = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M7.43376 2.17103C7.60585 1.60966 8.39415 1.60966 8.56624 2.17103L9.61978 5.60769C9.69652 5.85802 9.92611 6.02873 10.186 6.02873H13.6562C14.2231 6.02873 14.4665 6.75397 14.016 7.10088L11.1582 9.3015C10.9608 9.45349 10.8784 9.71341 10.9518 9.95262L12.0311 13.4735C12.2015 14.0292 11.5636 14.4777 11.1051 14.1246L8.35978 12.0106C8.14737 11.847 7.85263 11.847 7.64022 12.0106L4.89491 14.1246C4.43638 14.4777 3.79852 14.0292 3.96889 13.4735L5.04824 9.95262C5.12157 9.71341 5.03915 9.45349 4.84178 9.3015L1.98404 7.10088C1.53355 6.75397 1.77692 6.02873 2.34382 6.02873H5.81398C6.07389 6.02873 6.30348 5.85802 6.38022 5.60769L7.43376 2.17103Z"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

const String _rawClipboard = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M6.07512 2.75H4.75C3.64543 2.75 2.75 3.64543 2.75 4.75V12.25C2.75 13.3546 3.64543 14.25 4.75 14.25H11.25C12.3546 14.25 13.25 13.3546 13.25 12.25V4.75C13.25 3.64543 12.3546 2.75 11.25 2.75H9.92488M9.88579 3.02472L9.5934 4.04809C9.39014 4.75952 8.73989 5.25 8 5.25V5.25C7.26011 5.25 6.60986 4.75952 6.4066 4.04809L6.11421 3.02472C5.93169 2.38591 6.41135 1.75 7.07573 1.75H8.92427C9.58865 1.75 10.0683 2.3859 9.88579 3.02472Z"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

const String _rawHammer = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M6.73762 6.19288L2.0488 11.2217C1.6504 11.649 1.6504 12.3418 2.0488 12.769L3.13083 13.9295C3.52923 14.3568 4.17515 14.3568 4.57355 13.9295L9.26238 8.90071M6.73762 6.19288L7.0983 5.80605C7.4967 5.37877 7.4967 4.686 7.0983 4.25872L6.01627 3.09822L6.37694 2.71139C7.57213 1.42954 9.50991 1.42954 10.7051 2.71139L13.9512 6.19288C14.3496 6.62017 14.3496 7.31293 13.9512 7.74021L12.8692 8.90071C12.4708 9.328 11.8248 9.328 11.4265 8.90071L11.0658 8.51388C10.6674 8.0866 10.0215 8.0866 9.62306 8.51388L9.26238 8.90071M6.73762 6.19288L9.26238 8.90071"
    stroke="#FFFFFF"
    stroke-width="1.5"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
''';

const String _rawSearch = '''
<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="#FFFFFF" stroke-width="1.5">
  <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
</svg>
''';

const String _rawShift = '''
<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M6 1.5L2 6H4.5V10.5H7.5V6H10L6 1.5Z" fill="#FFFFFF"/>
</svg>
''';

const String _rawAssignTo = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 7a2.5 2.5 0 10.001-4.999A2.5 2.5 0 007 7zm0 1c-1.335 0-4 .893-4 2.667v.666c0 .367.225.667.5.667h2.049c.904-.909 2.417-1.911 4.727-2.009v-.72a.27.27 0 01.007-.063C9.397 8.404 7.898 8 7 8zm4.427 2.028a.266.266 0 01.286.032l2.163 1.723a.271.271 0 01.013.412l-2.163 1.97a.27.27 0 01-.452-.2v-.956c-3.328.133-5.282 1.508-5.287 1.535a.27.27 0 01-.266.227h-.022a.27.27 0 01-.249-.271c0-.046 1.549-3.328 5.824-3.509v-.72a.27.27 0 01.153-.243z" />
</svg>
''';

const String _rawAssignToMe = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg">
  <path d="M7.00003 7C8.38128 7 9.50003 5.88125 9.50003 4.5C9.50003 3.11875 8.38128 2 7.00003 2C5.61878 2 4.50003 3.11875 4.50003 4.5C4.50003 5.88125 5.61878 7 7.00003 7Z" />
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M7.00005 8C5.66505 8 3.00006 8.89333 3.00006 10.6667V11.3333C3.00006 11.7 3.22506 12 3.50006 12H3.98973C4.01095 11.9415 4.04535 11.8873 4.09266 11.8425L7.21783 8.88444C7.28966 8.81658 7.38297 8.77917 7.4796 8.77949C7.69459 8.78018 7.86826 8.96356 7.86753 9.1891L7.86214 10.629C9.00553 10.5858 10.0366 10.4354 10.9441 10.231C10.5539 8.74706 8.22087 8 7.00005 8Z"
  />
  <path d="M6.72511 14.718C6.80609 14.7834 6.91767 14.7955 7.01074 14.749C7.10407 14.7036 7.16321 14.6087 7.16295 14.5047L7.1605 13.7849C11.4352 13.5894 12.9723 10.3023 12.9722 10.2563C12.9722 10.1147 12.8634 9.9971 12.7225 9.98626L12.7009 9.98634C12.5685 9.98689 12.4561 10.0833 12.4351 10.2142C12.4303 10.2413 10.4816 11.623 7.15364 11.7666L7.1504 10.8116C7.14981 10.662 7.02829 10.5412 6.87896 10.5418C6.81184 10.5421 6.74721 10.5674 6.69765 10.6127L4.54129 12.5896C4.43117 12.6906 4.42367 12.862 4.52453 12.9723C4.53428 12.9829 4.54488 12.9928 4.55621 13.0018L6.72511 14.718Z" />
</svg>
''';

const String _rawChangeStatus = '''
<svg width="16" height="16" viewBox="-1 -1 15 15" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg">
  <path d="M10.5714 7C10.5714 8.97245 8.97245 10.5714 7 10.5714L6.99975 3.42857C8.9722 3.42857 10.5714 5.02755 10.5714 7Z" />
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M7 12.5C10.0376 12.5 12.5 10.0376 12.5 7C12.5 3.96243 10.0376 1.5 7 1.5C3.96243 1.5 1.5 3.96243 1.5 7C1.5 10.0376 3.96243 12.5 7 12.5ZM7 14C10.866 14 14 10.866 14 7C14 3.13401 10.866 0 7 0C3.13401 0 0 3.13401 0 7C0 10.866 3.13401 14 7 14Z"
  />
</svg>
''';

const String _rawChangePriority = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg">
  <rect x="1" y="8" width="3" height="6" rx="1"></rect>
  <rect x="6" y="5" width="3" height="9" rx="1"></rect>
  <rect x="11" y="2" width="3" height="12" rx="1"></rect>
</svg>
''';

const String _rawChangeLabels = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg">
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M10.2105 4C10.6337 4 11.0126 4.18857 11.24 4.48L14 8L11.24 11.52C11.0126 11.8114 10.6337 12 10.2105 12L3.26316 11.9943C2.56842 11.9943 2 11.4857 2 10.8571V5.14286C2 4.51429 2.56842 4.00571 3.26316 4.00571L10.2105 4ZM11.125 9C11.6773 9 12.125 8.55228 12.125 8C12.125 7.44772 11.6773 7 11.125 7C10.5727 7 10.125 7.44772 10.125 8C10.125 8.55228 10.5727 9 11.125 9Z"
  />
</svg>
''';

const String _rawSetDueDate = '''
<svg width="16" height="16" viewBox="0 0 16 16" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg">
  <path
    fill-rule="evenodd"
    clip-rule="evenodd"
    d="M15 5C15 2.79086 13.2091 1 11 1H5C2.79086 1 1 2.79086 1 5V11C1 13.2091 2.79086 15 5 15H6.25C6.66421 15 7 14.6642 7 14.25C7 13.8358 6.66421 13.5 6.25 13.5H5C3.61929 13.5 2.5 12.3807 2.5 11V6H13.5V6.25C13.5 6.66421 13.8358 7 14.25 7C14.6642 7 15 6.66421 15 6.25V5ZM11.5001 8C11.9143 8 12.2501 8.33579 12.2501 8.75V10.75L14.2501 10.75C14.6643 10.75 15.0001 11.0858 15.0001 11.5C15.0001 11.9142 14.6643 12.25 14.2501 12.25L12.2501 12.25V14.25C12.2501 14.6642 11.9143 15 11.5001 15C11.0859 15 10.7501 14.6642 10.7501 14.25V12.25H8.75C8.33579 12.25 8 11.9142 8 11.5C8 11.0858 8.33579 10.75 8.75 10.75L10.7501 10.75V8.75C10.7501 8.33579 11.0859 8 11.5001 8Z"
  />
</svg>
''';

const String _rawProjects = '''
<svg fill="none" height="24" stroke="#FFFFFF" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 3h7v7H3z"></path>
  <path d="M14 3h7v7h-7z"></path>
  <path d="M14 14h7v7h-7z"></path>
  <path d="M3 14h7v7H3z"></path>
</svg>
''';

const String _rawPlus = '''
<svg fill="none" height="24" stroke="#FFFFFF" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 5v14"></path>
  <path d="M5 12h14"></path>
</svg>
''';

const String _rawTeams = '''
<svg fill="none" height="24" stroke="#FFFFFF" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"></path>
  <circle cx="9" cy="7" r="4"></circle>
  <path d="M23 21v-2a4 4 0 00-3-3.87"></path>
  <path d="M16 3.13a4 4 0 010 7.75"></path>
</svg>
''';

const String _rawDocs = '''
<svg fill="none" height="24" stroke="#FFFFFF" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"></path>
  <path d="M14 2v6h6"></path>
  <path d="M16 13H8"></path>
  <path d="M16 17H8"></path>
  <path d="M10 9H8"></path>
</svg>
''';

const String _rawFeedback = '''
<svg fill="none" height="24" stroke="#FFFFFF" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z"></path>
</svg>
''';

const String _rawSupport = '''
<svg fill="none" height="24" stroke="#FFFFFF" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
  <path d="M22 6l-10 7L2 6"></path>
</svg>
''';

const String _rawFramerButton = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M2 5H13C13.5523 5 14 5.44772 14 6V9C14 9.55228 13.5523 10 13 10H2C1.44772 10 1 9.55228 1 9V6C1 5.44772 1.44772 5 2 5ZM0 6C0 4.89543 0.895431 4 2 4H13C14.1046 4 15 4.89543 15 6V9C15 10.1046 14.1046 11 13 11H2C0.89543 11 0 10.1046 0 9V6ZM4.5 6.75C4.08579 6.75 3.75 7.08579 3.75 7.5C3.75 7.91421 4.08579 8.25 4.5 8.25C4.91421 8.25 5.25 7.91421 5.25 7.5C5.25 7.08579 4.91421 6.75 4.5 6.75ZM6.75 7.5C6.75 7.08579 7.08579 6.75 7.5 6.75C7.91421 6.75 8.25 7.08579 8.25 7.5C8.25 7.91421 7.91421 8.25 7.5 8.25C7.08579 8.25 6.75 7.91421 6.75 7.5ZM10.5 6.75C10.0858 6.75 9.75 7.08579 9.75 7.5C9.75 7.91421 10.0858 8.25 10.5 8.25C10.9142 8.25 11.25 7.91421 11.25 7.5C11.25 7.08579 10.9142 6.75 10.5 6.75Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerInput = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M6.5 1C6.22386 1 6 1.22386 6 1.5C6 1.77614 6.22386 2 6.5 2C7.12671 2 7.45718 2.20028 7.65563 2.47812C7.8781 2.78957 8 3.28837 8 4V11C8 11.7116 7.8781 12.2104 7.65563 12.5219C7.45718 12.7997 7.12671 13 6.5 13C6.22386 13 6 13.2239 6 13.5C6 13.7761 6.22386 14 6.5 14C7.37329 14 8.04282 13.7003 8.46937 13.1031C8.47976 13.0886 8.48997 13.0739 8.5 13.0591C8.51003 13.0739 8.52024 13.0886 8.53063 13.1031C8.95718 13.7003 9.62671 14 10.5 14C10.7761 14 11 13.7761 11 13.5C11 13.2239 10.7761 13 10.5 13C9.87329 13 9.54282 12.7997 9.34437 12.5219C9.1219 12.2104 9 11.7116 9 11V4C9 3.28837 9.1219 2.78957 9.34437 2.47812C9.54282 2.20028 9.87329 2 10.5 2C10.7761 2 11 1.77614 11 1.5C11 1.22386 10.7761 1 10.5 1C9.62671 1 8.95718 1.29972 8.53063 1.89688C8.52024 1.91143 8.51003 1.92611 8.5 1.9409C8.48997 1.92611 8.47976 1.91143 8.46937 1.89688C8.04282 1.29972 7.37329 1 6.5 1ZM14 5H11V4H14C14.5523 4 15 4.44772 15 5V10C15 10.5523 14.5523 11 14 11H11V10H14V5ZM6 4V5H1L1 10H6V11H1C0.447715 11 0 10.5523 0 10V5C0 4.44772 0.447715 4 1 4H6Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerRadio = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M7.49985 0.877045C3.84216 0.877045 0.877014 3.84219 0.877014 7.49988C0.877014 11.1575 3.84216 14.1227 7.49985 14.1227C11.1575 14.1227 14.1227 11.1575 14.1227 7.49988C14.1227 3.84219 11.1575 0.877045 7.49985 0.877045ZM1.82701 7.49988C1.82701 4.36686 4.36683 1.82704 7.49985 1.82704C10.6328 1.82704 13.1727 4.36686 13.1727 7.49988C13.1727 10.6329 10.6328 13.1727 7.49985 13.1727C4.36683 13.1727 1.82701 10.6329 1.82701 7.49988ZM7.49999 9.49999C8.60456 9.49999 9.49999 8.60456 9.49999 7.49999C9.49999 6.39542 8.60456 5.49999 7.49999 5.49999C6.39542 5.49999 5.49999 6.39542 5.49999 7.49999C5.49999 8.60456 6.39542 9.49999 7.49999 9.49999Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerBadge = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M3.5 6H11.5C12.3284 6 13 6.67157 13 7.5C13 8.32843 12.3284 9 11.5 9H3.5C2.67157 9 2 8.32843 2 7.5C2 6.67157 2.67157 6 3.5 6ZM1 7.5C1 6.11929 2.11929 5 3.5 5H11.5C12.8807 5 14 6.11929 14 7.5C14 8.88071 12.8807 10 11.5 10H3.5C2.11929 10 1 8.88071 1 7.5ZM4.5 7C4.22386 7 4 7.22386 4 7.5C4 7.77614 4.22386 8 4.5 8H10.5C10.7761 8 11 7.77614 11 7.5C11 7.22386 10.7761 7 10.5 7H4.5Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerToggle = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M10.5 4C8.567 4 7 5.567 7 7.5C7 9.433 8.567 11 10.5 11C12.433 11 14 9.433 14 7.5C14 5.567 12.433 4 10.5 4ZM7.67133 11C6.65183 10.175 6 8.91363 6 7.5C6 6.08637 6.65183 4.82498 7.67133 4H4.5C2.567 4 1 5.567 1 7.5C1 9.433 2.567 11 4.5 11H7.67133ZM0 7.5C0 5.01472 2.01472 3 4.5 3H10.5C12.9853 3 15 5.01472 15 7.5C15 9.98528 12.9853 12 10.5 12H4.5C2.01472 12 0 9.98528 0 7.5Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerSlider = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M10.3004 7.49991C10.3004 8.4943 9.49426 9.30041 8.49988 9.30041C7.50549 9.30041 6.69938 8.4943 6.69938 7.49991C6.69938 6.50553 7.50549 5.69942 8.49988 5.69942C9.49426 5.69942 10.3004 6.50553 10.3004 7.49991ZM11.205 8C10.9699 9.28029 9.84816 10.2504 8.49988 10.2504C7.1516 10.2504 6.0299 9.28029 5.79473 8H0.5C0.223858 8 0 7.77614 0 7.5C0 7.22386 0.223858 7 0.5 7H5.7947C6.0298 5.71962 7.15154 4.74942 8.49988 4.74942C9.84822 4.74942 10.97 5.71962 11.2051 7H14.5C14.7761 7 15 7.22386 15 7.5C15 7.77614 14.7761 8 14.5 8H11.205Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerAvatar = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M0.877014 7.49988C0.877014 3.84219 3.84216 0.877045 7.49985 0.877045C11.1575 0.877045 14.1227 3.84219 14.1227 7.49988C14.1227 11.1575 11.1575 14.1227 7.49985 14.1227C3.84216 14.1227 0.877014 11.1575 0.877014 7.49988ZM7.49985 1.82704C4.36683 1.82704 1.82701 4.36686 1.82701 7.49988C1.82701 8.97196 2.38774 10.3131 3.30727 11.3213C4.19074 9.94119 5.73818 9.02499 7.50023 9.02499C9.26206 9.02499 10.8093 9.94097 11.6929 11.3208C12.6121 10.3127 13.1727 8.97172 13.1727 7.49988C13.1727 4.36686 10.6328 1.82704 7.49985 1.82704ZM10.9818 11.9787C10.2839 10.7795 8.9857 9.97499 7.50023 9.97499C6.01458 9.97499 4.71624 10.7797 4.01845 11.9791C4.97952 12.7272 6.18765 13.1727 7.49985 13.1727C8.81227 13.1727 10.0206 12.727 10.9818 11.9787ZM5.14999 6.50487C5.14999 5.207 6.20212 4.15487 7.49999 4.15487C8.79786 4.15487 9.84999 5.207 9.84999 6.50487C9.84999 7.80274 8.79786 8.85487 7.49999 8.85487C6.20212 8.85487 5.14999 7.80274 5.14999 6.50487ZM7.49999 5.10487C6.72679 5.10487 6.09999 5.73167 6.09999 6.50487C6.09999 7.27807 6.72679 7.90487 7.49999 7.90487C8.27319 7.90487 8.89999 7.27807 8.89999 6.50487C8.89999 5.73167 8.27319 5.10487 7.49999 5.10487Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawFramerContainer = '''
<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path
    d="M2 1.5C2 1.77614 1.77614 2 1.5 2C1.22386 2 1 1.77614 1 1.5C1 1.22386 1.22386 1 1.5 1C1.77614 1 2 1.22386 2 1.5ZM5 13H10V2L5 2L5 13ZM4 13C4 13.5523 4.44772 14 5 14H10C10.5523 14 11 13.5523 11 13V2C11 1.44772 10.5523 1 10 1H5C4.44772 1 4 1.44771 4 2V13ZM13.5 2C13.7761 2 14 1.77614 14 1.5C14 1.22386 13.7761 1 13.5 1C13.2239 1 13 1.22386 13 1.5C13 1.77614 13.2239 2 13.5 2ZM2 3.5C2 3.77614 1.77614 4 1.5 4C1.22386 4 1 3.77614 1 3.5C1 3.22386 1.22386 3 1.5 3C1.77614 3 2 3.22386 2 3.5ZM13.5 4C13.7761 4 14 3.77614 14 3.5C14 3.22386 13.7761 3 13.5 3C13.2239 3 13 3.22386 13 3.5C13 3.77614 13.2239 4 13.5 4ZM2 5.5C2 5.77614 1.77614 6 1.5 6C1.22386 6 1 5.77614 1 5.5C1 5.22386 1.22386 5 1.5 5C1.77614 5 2 5.22386 2 5.5ZM13.5 6C13.7761 6 14 5.77614 14 5.5C14 5.22386 13.7761 5 13.5 5C13.2239 5 13 5.22386 13 5.5C13 5.77614 13.2239 6 13.5 6ZM2 7.5C2 7.77614 1.77614 8 1.5 8C1.22386 8 1 7.77614 1 7.5C1 7.22386 1.22386 7 1.5 7C1.77614 7 2 7.22386 2 7.5ZM13.5 8C13.7761 8 14 7.77614 14 7.5C14 7.22386 13.7761 7 13.5 7C13.2239 7 13 7.22386 13 7.5ZM2 9.5C2 9.77614 1.77614 10 1.5 10C1.22386 10 1 9.77614 1 9.5C1 9.22386 1.22386 9 1.5 9C1.77614 9 2 9.22386 2 9.5ZM13.5 10C13.7761 10 14 9.77614 14 9.5C14 9.22386 13.7761 9 13.5 9C13.2239 9 13 9.22386 13 9.5C13 13 13 9.77614 13 9.5ZM2 11.5C2 11.7761 1.77614 12 1.5 12C1.22386 12 1 11.7761 1 11.5C1 11.2239 1.22386 11 1.5 11C1.77614 11 2 11.2239 2 11.5ZM13.5 12C13.7761 12 14 11.7761 14 11.5C14 11.2239 13.7761 11 13.5 11C13.2239 11 13 11.2239 13 11.5C13 11.7761 13.2239 12 13.5 12ZM2 13.5C2 13.7761 1.77614 14 1.5 14C1.22386 14 1 13.7761 1 13.5C1 13.2239 1.22386 13 1.5 13C1.77614 13 2 13.2239 2 13.5ZM13.5 14C13.7761 14 14 13.7761 14 13.5C14 13.2239 13.7761 13 13.5 13C13.2239 13 13 13.2239 13 13.5C13 13.7761 13.2239 14 13.5 14Z"
    fill="#FFFFFF"
    fill-rule="evenodd"
    clip-rule="evenodd"
  ></path>
</svg>
''';

const String _rawLiquidGlass = '''
<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" width="814" height="1000">
  <path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76.5 0-103.7 40.8-165.9 40.8s-105.6-57-155.5-127C46.7 790.7 0 663 0 541.8c0-194.4 126.4-297.5 250.8-297.5 66.1 0 121.2 43.4 162.7 43.4 39.5 0 101.1-46 176.3-46 28.5 0 130.9 2.6 198.3 99.2zm-234-181.5c31.1-36.9 53.1-88.1 53.1-139.3 0-7.1-.6-14.3-1.9-20.1-50.6 1.9-110.8 33.7-147.1 75.8-28.5 32.4-55.1 83.6-55.1 135.5 0 7.8 1.3 15.6 1.9 18.1 3.2.6 8.4 1.3 13.6 1.3 45.4 0 102.5-30.4 135.5-71.3z"/>
</svg>
''';
