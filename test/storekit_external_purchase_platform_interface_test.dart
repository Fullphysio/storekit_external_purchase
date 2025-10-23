import 'package:flutter_test/flutter_test.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_platform_interface.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_method_channel.dart';

class MockPlatformImplementation extends StorekitExternalPurchasePlatform {
  @override
  Future<String?> getCountryCode() => Future.value('US');

  @override
  Future<bool> isExternalPurchaseAvailable() => Future.value(true);

  @override
  Future<bool> canMakePayments() => Future.value(true);

  @override
  Future<NoticeResult> showNotice(NoticeType noticeType) => Future.value(NoticeResult.continued);

  @override
  Future<Token?> token(TokenType tokenType) => Future.value(Token('mock-token-data'));
}

void main() {
  group('NoticeType Enum', () {
    test('browser has correct value', () {
      expect(NoticeType.browser.value, 0);
    });

    test('withinApp has correct value', () {
      expect(NoticeType.withinApp.value, 1);
    });
  });

  group('TokenType Enum', () {
    test('acquisition has correct value', () {
      expect(TokenType.acquisition.value, 'ACQUISITION');
    });

    test('services has correct value', () {
      expect(TokenType.services.value, 'SERVICES');
    });
  });

  group('Token Class', () {
    test('constructor sets data correctly', () {
      const token = Token('test-data');
      expect(token.value, 'test-data');
    });

    test('toString returns correct format', () {
      const token = Token('test-data');
      expect(token.toString(), 'Token(data: test-data)');
    });

    test('equality works correctly', () {
      const token1 = Token('data');
      const token2 = Token('data');
      const token3 = Token('different');

      expect(token1, equals(token2));
      expect(token1, isNot(equals(token3)));
    });

    test('hashCode is consistent', () {
      const token1 = Token('data');
      const token2 = Token('data');

      expect(token1.hashCode, equals(token2.hashCode));
    });
  });

  group('NoticeResult Enum', () {
    test('continued has correct value', () {
      expect(NoticeResult.continued.value, 'continued');
    });

    group('fromValue factory', () {
      test('returns continued for "continued" string', () {
        final result = NoticeResult.fromValue('continued');
        expect(result, NoticeResult.continued);
      });

      test('throws ArgumentError for invalid value', () {
        expect(() => NoticeResult.fromValue('invalid'), throwsA(isInstanceOf<ArgumentError>()));
      });
    });
  });

  group('StorekitExternalPurchasePlatform Interface', () {
    final StorekitExternalPurchasePlatform initialPlatform = StorekitExternalPurchasePlatform.instance;

    test('default instance is MethodChannelStorekitExternalPurchase', () {
      expect(initialPlatform, isInstanceOf<MethodChannelStorekitExternalPurchase>());
    });

    test('can be set to a custom implementation', () {
      final mock = MockPlatformImplementation();
      StorekitExternalPurchasePlatform.instance = mock;
      expect(StorekitExternalPurchasePlatform.instance, mock);
    });

    tearDown(() {
      StorekitExternalPurchasePlatform.instance = initialPlatform;
    });
  });
}
