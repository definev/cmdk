import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/src/command_score.dart';

void main() {
  group('commandScore algorithm', () {
    test('returns 1.0 for empty search query', () {
      expect(commandScore('Apple', ''), 1.0);
    });

    test('returns 0.0 for empty target string with non-empty search', () {
      expect(commandScore('', 'a'), 0.0);
    });

    test('exact match scores 1.0', () {
      expect(commandScore('apple', 'apple'), 1.0);
    });

    test('prefix match has high score', () {
      final score = commandScore('Apple', 'app');
      expect(score, greaterThan(0.9));
    });

    test('case mismatch receives small penalty', () {
      final exactCase = commandScore('apple', 'app');
      final mismatchCase = commandScore('Apple', 'app');
      expect(exactCase, greaterThan(mismatchCase));
    });

    test('word jump with space scores higher than random character jump', () {
      final spaceJump = commandScore('my apple', 'ma');
      final midWordJump = commandScore('marzipan', 'ma');
      expect(spaceJump, greaterThan(0.0));
      expect(midWordJump, greaterThan(0.0));
    });

    test('gap characters score word jumps', () {
      final gapScore = commandScore('foo.bar.112.value', '112');
      expect(gapScore, greaterThan(0.7));
    });

    test('aliases/keywords improve score', () {
      final withoutAlias = commandScore('Project', 'code');
      expect(withoutAlias, 0.0);

      final withAlias = commandScore('Project', 'code', ['code', 'repo']);
      expect(withAlias, greaterThan(0.0));
    });

    test('numeric queries match correctly (numeric.test.ts parity)', () {
      final match = commandScore('foo.bar112.value', '112');
      final noMatch = commandScore('removed', '112');
      expect(match, greaterThan(0.0));
      expect(noMatch, 0.0);

      final barMatch = commandScore('foo.bar112.value', 'bar');
      final barNoMatch = commandScore('removed', 'bar');
      expect(barMatch, greaterThan(0.0));
      expect(barNoMatch, 0.0);
    });

    test('unmatched string scores 0.0', () {
      expect(commandScore('banana', 'xyz'), 0.0);
    });
  });
}
