import 'dart:math' as math;

/// Function signature for command filtering.
/// Returns a score between 0.0 (no match / hidden) and 1.0 (exact match).
typedef CommandFilter =
    double Function(
      String value,
      String search, [
      List<String>? keywords,
    ]);

const double scoreContinueMatch = 1.0;
const double scoreSpaceWordJump = 0.9;
const double scoreNonSpaceWordJump = 0.8;
const double scoreCharacterJump = 0.17;
const double scoreTransposition = 0.1;
const double penaltySkipped = 0.999;
const double penaltyCaseMismatch = 0.9999;
const double penaltyDistanceFromStart = 0.9;
const double penaltyNotComplete = 0.99;

final RegExp _countSpaceRegExp = RegExp(r'[\s-]');

@pragma('vm:prefer-inline')
bool _isGapCode(int code) {
  // [\\\/_+.#"@\[\(\{&]
  return code == 92 || // \
      code == 47 || // /
      code == 95 || // _
      code == 43 || // +
      code == 46 || // .
      code == 35 || // #
      code == 34 || // "
      code == 64 || // @
      code == 91 || // [
      code == 40 || // (
      code == 123 || // {
      code == 38; // &
}

@pragma('vm:prefer-inline')
bool _isSpaceCode(int code) {
  // space, hyphen, tab, newline, carriage return
  return code == 32 || code == 45 || code == 9 || code == 10 || code == 13;
}

/// Default command scoring algorithm ported directly from cmdk.
/// Matches abbreviations and strings with fuzzy scoring, transpositions,
/// word breaks, and keyword alias handling.
double commandScore(
  String string,
  String abbreviation, [
  List<String>? aliases,
]) {
  if (abbreviation.isEmpty) return 1.0;
  if (string.isEmpty) return 0.0;

  var fullString = (aliases != null && aliases.isNotEmpty)
      ? '$string ${aliases.join(' ')}'
      : string;

  return _commandScoreInner(
    fullString,
    abbreviation,
    _formatInput(fullString),
    _formatInput(abbreviation),
    0,
    0,
    <int, double>{},
  );
}

String _formatInput(String string) {
  return string.toLowerCase().replaceAll(_countSpaceRegExp, ' ');
}

double _commandScoreInner(
  String string,
  String abbreviation,
  String lowerString,
  String lowerAbbreviation,
  int stringIndex,
  int abbreviationIndex,
  Map<int, double> memoizedResults,
) {
  if (abbreviationIndex == abbreviation.length) {
    if (stringIndex == string.length) {
      return scoreContinueMatch;
    }
    return penaltyNotComplete;
  }

  // Fast integer memoization key (up to 65535 length)
  final memoizeKey = (stringIndex << 16) | abbreviationIndex;
  final cached = memoizedResults[memoizeKey];
  if (cached != null) {
    return cached;
  }

  final abbreviationChar = lowerAbbreviation[abbreviationIndex];
  var index = lowerString.indexOf(abbreviationChar, stringIndex);
  var highScore = 0.0;

  while (index >= 0) {
    var score = _commandScoreInner(
      string,
      abbreviation,
      lowerString,
      lowerAbbreviation,
      index + 1,
      abbreviationIndex + 1,
      memoizedResults,
    );

    if (score > highScore) {
      if (index == stringIndex) {
        score *= scoreContinueMatch;
      } else if (index > 0 && _isGapCode(string.codeUnitAt(index - 1))) {
        score *= scoreNonSpaceWordJump;
        if (index - 1 > stringIndex) {
          var wordBreaks = 0;
          for (var i = stringIndex; i < index - 1; i++) {
            if (_isGapCode(string.codeUnitAt(i))) wordBreaks++;
          }
          if (wordBreaks > 0 && stringIndex > 0) {
            score *= math.pow(penaltySkipped, wordBreaks);
          }
        }
      } else if (index > 0 && _isSpaceCode(string.codeUnitAt(index - 1))) {
        score *= scoreSpaceWordJump;
        if (index - 1 > stringIndex) {
          var spaceBreaks = 0;
          for (var i = stringIndex; i < index - 1; i++) {
            if (_isSpaceCode(string.codeUnitAt(i))) spaceBreaks++;
          }
          if (spaceBreaks > 0 && stringIndex > 0) {
            score *= math.pow(penaltySkipped, spaceBreaks);
          }
        }
      } else {
        score *= scoreCharacterJump;
        if (stringIndex > 0) {
          score *= math.pow(penaltySkipped, index - stringIndex);
        }
      }

      if (string[index] != abbreviation[abbreviationIndex]) {
        score *= penaltyCaseMismatch;
      }
    }

    final hasNextAbbr = abbreviationIndex + 1 < lowerAbbreviation.length;
    final prevChar = index > 0 ? lowerString[index - 1] : '';

    if (hasNextAbbr &&
        ((score < scoreTransposition &&
                prevChar == lowerAbbreviation[abbreviationIndex + 1]) ||
            (lowerAbbreviation[abbreviationIndex + 1] ==
                    lowerAbbreviation[abbreviationIndex] &&
                prevChar != lowerAbbreviation[abbreviationIndex]))) {
      final transposedScore = _commandScoreInner(
        string,
        abbreviation,
        lowerString,
        lowerAbbreviation,
        index + 1,
        abbreviationIndex + 2,
        memoizedResults,
      );

      if (transposedScore * scoreTransposition > score) {
        score = transposedScore * scoreTransposition;
      }
    }

    if (score > highScore) {
      highScore = score;
    }

    index = lowerString.indexOf(abbreviationChar, index + 1);
  }

  memoizedResults[memoizeKey] = highScore;
  return highScore;
}
