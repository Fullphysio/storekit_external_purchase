import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_method_channel.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelStorekitExternalPurchase platform = MethodChannelStorekitExternalPurchase();
  const MethodChannel channel = MethodChannel('storekit_external_purchase');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelStorekitExternalPurchase', () {
    group('getCountryCode', () {
      test('returns value when available', () async {
        expect(await platform.getCountryCode(), '42');
      });

      test('handles method channel exceptions', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          throw PlatformException(code: 'UNAVAILABLE', message: 'Feature not available');
        });

        expect(() => platform.getCountryCode(), throwsA(isInstanceOf<PlatformException>()));
      });
    });

    group('isEligible', () {
      test('returns true when available', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          return true;
        });

        expect(await platform.isEligible(), true);
      });

      test('returns false when native returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          return null;
        });

        expect(await platform.isEligible(), false);
      });

      test('handles method channel exceptions', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          throw PlatformException(code: 'ERROR', message: 'An error occurred');
        });

        expect(() => platform.isEligible(), throwsA(isInstanceOf<PlatformException>()));
      });
    });

    group('showNotice', () {
      test('returns continued when shown', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          return 'continued';
        });

        final result = await platform.showNotice(NoticeType.browser);
        expect(result, NoticeResult.continued);
      });

      test('returns cancelled by default', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          return null;
        });

        final result = await platform.showNotice(NoticeType.browser);
        expect(result, NoticeResult.cancelled);
      });

      test('passes browser notice type correctly', () async {
        int? passedNoticeType;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'showNotice') {
            passedNoticeType = methodCall.arguments['noticeType'] as int?;
          }
          return 'continued';
        });

        await platform.showNotice(NoticeType.browser);
        expect(passedNoticeType, NoticeType.browser.value);
      });

      test('handles method channel exceptions', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          throw PlatformException(code: 'ERROR', message: 'Failed to show notice');
        });

        expect(() => platform.showNotice(NoticeType.browser), throwsA(isInstanceOf<PlatformException>()));
      });
    });

    group('token', () {
      test('returns token when available', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          return 'token-data';
        });

        final result = await platform.token(TokenType.acquisition);
        expect(result, isNotNull);
        expect(result!.value, 'token-data');
      });

      test('returns null when native returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          return null;
        });

        final result = await platform.token(TokenType.acquisition);
        expect(result, isNull);
      });

      test('passes acquisition token type correctly', () async {
        String? passedTokenType;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'token') {
            passedTokenType = methodCall.arguments['tokenType'] as String?;
          }
          return 'token-data';
        });

        await platform.token(TokenType.acquisition);
        expect(passedTokenType, TokenType.acquisition.value);
      });

      test('passes services token type correctly', () async {
        String? passedTokenType;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'token') {
            passedTokenType = methodCall.arguments['tokenType'] as String?;
          }
          return 'token-data';
        });

        await platform.token(TokenType.services);
        expect(passedTokenType, TokenType.services.value);
      });

      test('handles method channel exceptions', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          throw PlatformException(code: 'ERROR', message: 'Failed to get token');
        });

        expect(() => platform.token(TokenType.acquisition), throwsA(isInstanceOf<PlatformException>()));
      });
    });

    group('Concurrent Operations', () {
      test('handles mixed concurrent calls', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          await Future.delayed(const Duration(milliseconds: 10));
          if (methodCall.method == 'getCountryCode') {
            return 'US';
          } else if (methodCall.method == 'canMakePayments') {
            return true;
          } else if (methodCall.method == 'isEligible') {
            return true;
          }
          return null;
        });

        final futures = [platform.getCountryCode(), platform.canMakePayments(), platform.isEligible()];

        final results = await Future.wait(futures);
        expect(results[0], 'US');
        expect(results[1], true);
        expect(results[2], true);
      });
    });
  });
}
