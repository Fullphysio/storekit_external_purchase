import 'package:flutter_test/flutter_test.dart';
import 'package:storekit_external_purchase/storekit_external_purchase.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_platform_interface.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStorekitExternalPurchasePlatform with MockPlatformInterfaceMixin implements StorekitExternalPurchasePlatform {
  int getCountryCodeCallCount = 0;
  int isExternalPurchaseAvailableCallCount = 0;
  int canMakePaymentsCallCount = 0;
  int showNoticeCallCount = 0;

  @override
  Future<String?> getCountryCode() async {
    getCountryCodeCallCount++;
    return 'US';
  }

  @override
  Future<bool> isExternalPurchaseAvailable() async {
    isExternalPurchaseAvailableCallCount++;
    return true;
  }

  @override
  Future<bool> canMakePayments() async {
    canMakePaymentsCallCount++;
    return true;
  }

  @override
  Future<NoticeResult> showNotice(NoticeType noticeType) async {
    showNoticeCallCount++;
    return NoticeResult.continued;
  }
}

class MockStorekitExternalPurchasePlatformNull
    with MockPlatformInterfaceMixin
    implements StorekitExternalPurchasePlatform {
  @override
  Future<String?> getCountryCode() => Future.value(null);

  @override
  Future<bool> isExternalPurchaseAvailable() => Future.value(false);

  @override
  Future<bool> canMakePayments() => Future.value(false);

  @override
  Future<NoticeResult> showNotice(NoticeType noticeType) => Future.value(NoticeResult.cancelled);
}

void main() {
  final StorekitExternalPurchasePlatform initialPlatform = StorekitExternalPurchasePlatform.instance;

  group('StorekitExternalPurchase Main Plugin Class', () {
    test('$MethodChannelStorekitExternalPurchase is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelStorekitExternalPurchase>());
    });

    group('getCountryCode', () {
      test('returns value when available', () async {
        StorekitExternalPurchase plugin = StorekitExternalPurchase();
        MockStorekitExternalPurchasePlatform fakePlatform = MockStorekitExternalPurchasePlatform();
        StorekitExternalPurchasePlatform.instance = fakePlatform;

        final result = await plugin.getCountryCode();
        expect(result, 'US');
        expect(fakePlatform.getCountryCodeCallCount, 1);
      });

      test('returns null when not available', () async {
        StorekitExternalPurchase plugin = StorekitExternalPurchase();
        MockStorekitExternalPurchasePlatformNull fakePlatform = MockStorekitExternalPurchasePlatformNull();
        StorekitExternalPurchasePlatform.instance = fakePlatform;

        final result = await plugin.getCountryCode();
        expect(result, null);
      });
    });

    group('isExternalPurchaseAvailable', () {
      test('returns true when available', () async {
        StorekitExternalPurchase plugin = StorekitExternalPurchase();
        MockStorekitExternalPurchasePlatform fakePlatform = MockStorekitExternalPurchasePlatform();
        StorekitExternalPurchasePlatform.instance = fakePlatform;

        final result = await plugin.isExternalPurchaseAvailable();
        expect(result, true);
        expect(fakePlatform.isExternalPurchaseAvailableCallCount, 1);
      });
    });

    group('canMakePayments', () {
      test('returns true when payments can be made', () async {
        StorekitExternalPurchase plugin = StorekitExternalPurchase();
        MockStorekitExternalPurchasePlatform fakePlatform = MockStorekitExternalPurchasePlatform();
        StorekitExternalPurchasePlatform.instance = fakePlatform;

        final result = await plugin.canMakePayments();
        expect(result, true);
        expect(fakePlatform.canMakePaymentsCallCount, 1);
      });
    });

    group('showNotice', () {
      test('returns cancelled when user cancels', () async {
        StorekitExternalPurchase plugin = StorekitExternalPurchase();
        MockStorekitExternalPurchasePlatformNull fakePlatform = MockStorekitExternalPurchasePlatformNull();
        StorekitExternalPurchasePlatform.instance = fakePlatform;

        final result = await plugin.showNotice(NoticeType.browser);
        expect(result, NoticeResult.cancelled);
      });
    });

    tearDown(() {
      StorekitExternalPurchasePlatform.instance = initialPlatform;
    });
  });
}
