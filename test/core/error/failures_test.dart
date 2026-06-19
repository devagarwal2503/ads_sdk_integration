import 'package:flutter_test/flutter_test.dart';
import 'package:ads_sdk_integration/core/error/failures.dart';

void main() {
  group('Failure Tests', () {
    test('NetworkFailure properties and equality', () {
      const failure1 = NetworkFailure('No Internet Connection');
      const failure2 = NetworkFailure('No Internet Connection');
      const failure3 = NetworkFailure('Slow Connection');

      expect(failure1.message, 'No Internet Connection');
      expect(failure1.props, ['No Internet Connection']);
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('ServerFailure properties and equality', () {
      const failure1 = ServerFailure('Internal Server Error');
      const failure2 = ServerFailure('Internal Server Error');
      const failure3 = ServerFailure('Gateway Timeout');

      expect(failure1.message, 'Internal Server Error');
      expect(failure1.props, ['Internal Server Error']);
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('SdkNotInitializedFailure properties and equality', () {
      const failure1 = SdkNotInitializedFailure('SDK is not initialized');
      const failure2 = SdkNotInitializedFailure('SDK is not initialized');
      const failure3 = SdkNotInitializedFailure('SDK failed to build');

      expect(failure1.message, 'SDK is not initialized');
      expect(failure1.props, ['SDK is not initialized']);
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('UnexpectedFailure properties and equality', () {
      const failure1 = UnexpectedFailure('An unexpected error occurred');
      const failure2 = UnexpectedFailure('An unexpected error occurred');
      const failure3 = UnexpectedFailure('Crash occurred');

      expect(failure1.message, 'An unexpected error occurred');
      expect(failure1.props, ['An unexpected error occurred']);
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });
}
