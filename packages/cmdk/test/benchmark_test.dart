import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  test('Performance: score and filter 5,000 items in under 80ms (JIT)', () {
    final items = List.generate(
      5000,
      (i) => 'Command Menu Option item_$i with prefix keywords and descriptors',
    );

    // Warm-up JIT
    for (var i = 0; i < 50; i++) {
      commandScore(items[i], 'opt');
    }

    final stopwatch = Stopwatch()..start();

    const query = 'opt item_42';
    var matchCount = 0;

    for (final item in items) {
      final score = commandScore(item, query);
      if (score > 0) matchCount++;
    }

    stopwatch.stop();

    // Verify correct matching
    expect(matchCount, greaterThan(0));

    // Blazing fast: 5,000 items scored in < 80ms in unoptimized test JIT
    expect(
      stopwatch.elapsedMilliseconds,
      lessThan(80),
      reason:
          'Scored 5,000 items in ${stopwatch.elapsedMilliseconds}ms. Expected < 80ms.',
    );
  });
}
