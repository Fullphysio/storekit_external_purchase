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

  test('getCountryCode returns value', () async {
    expect(await platform.getCountryCode(), '42');
  });

  test('getCountryCode returns null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return null;
    });

    expect(await platform.getCountryCode(), null);
  });

  test('isExternalPurchaseAvailable returns true', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return true;
    });

    expect(await platform.isExternalPurchaseAvailable(), true);
  });

  test('isExternalPurchaseAvailable returns false by default', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return null;
    });

    expect(await platform.isExternalPurchaseAvailable(), false);
  });

  test('showNotice returns continued', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return 'continued';
    });

    final result = await platform.showNotice(NoticeType.browser);
    expect(result, NoticeResult.continued);
  });

  test('showNotice returns cancelled by default', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return null;
    });

    final result = await platform.showNotice(NoticeType.browser);
    expect(result, NoticeResult.cancelled);
  });
}
