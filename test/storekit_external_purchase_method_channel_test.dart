import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_method_channel.dart';

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

  test('presentExternalPurchase returns accepted true', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return {'accepted': true};
    });

    final result = await platform.presentExternalPurchase('https://example.com');
    expect(result.accepted, true);
  });

  test('presentExternalPurchase returns accepted false by default', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return null;
    });

    final result = await platform.presentExternalPurchase('https://example.com');
    expect(result.accepted, false);
  });
}
