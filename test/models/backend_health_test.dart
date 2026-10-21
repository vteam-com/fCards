import 'package:cards/models/app/backend_health.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendHealth', () {
    late DateTime now;
    late BackendHealth health;

    setUp(() {
      now = DateTime(2026, 10, 21, 9);
      health = BackendHealth(now: () => now);
    });

    test('starts unknown and lets requests through', () {
      expect(health.status, BackendStatus.unknown);
      expect(health.isUnreachable, isFalse);
      expect(health.beginAttempt(), isTrue);
    });

    test('a failure refuses requests until the retry delay has passed', () {
      health.recordFailure();
      expect(health.isUnreachable, isTrue);
      expect(health.beginAttempt(), isFalse);

      now = now.add(backendRetryAfter - const Duration(seconds: 1));
      expect(health.beginAttempt(), isFalse);

      now = now.add(const Duration(seconds: 1));
      expect(health.beginAttempt(), isTrue);
    });

    test('only one probe is let through after the retry delay', () {
      health.recordFailure();
      now = now.add(backendRetryAfter);
      expect(health.beginAttempt(), isTrue);
      expect(health.beginAttempt(), isFalse);

      health.recordFailure();
      expect(health.beginAttempt(), isFalse);
      now = now.add(backendRetryAfter);
      expect(health.beginAttempt(), isTrue);
    });

    test('a success closes the breaker', () {
      health.recordFailure();
      now = now.add(backendRetryAfter);
      expect(health.beginAttempt(), isTrue);
      health.recordSuccess();
      expect(health.status, BackendStatus.reachable);
      expect(health.beginAttempt(), isTrue);
      expect(health.beginAttempt(), isTrue);
    });

    test('reset lets requests through right away', () {
      health.recordFailure();
      expect(health.beginAttempt(), isFalse);
      health.reset();
      expect(health.status, BackendStatus.unknown);
      expect(health.lastFailureAt, isNull);
      expect(health.beginAttempt(), isTrue);
    });

    test('notifies listeners only when the status changes', () {
      int notifications = 0;
      health.addListener(() => notifications++);

      health.recordFailure();
      health.recordFailure();
      expect(notifications, 1);

      health.recordSuccess();
      health.recordSuccess();
      expect(notifications, 2);

      health.reset();
      expect(notifications, 3);
    });
  });
}
