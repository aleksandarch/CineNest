import 'package:cine_nest/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('returns error for null or empty', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('test@'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('returns error for empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('returns error for short password', () {
      expect(Validators.validatePassword('12345'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(Validators.validatePassword('secret123'), isNull);
    });
  });

  group('validateNickname', () {
    test('returns error for empty nickname', () {
      expect(Validators.validateNickname(''), isNotNull);
    });

    test('returns error for too short nickname', () {
      expect(Validators.validateNickname('ab'), isNotNull);
    });

    test('returns error for too long nickname', () {
      expect(Validators.validateNickname('a' * 17), isNotNull);
    });

    test('returns null for valid nickname', () {
      expect(Validators.validateNickname('FlutterDev'), isNull);
    });
  });
}
