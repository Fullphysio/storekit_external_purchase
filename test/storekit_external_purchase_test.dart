import 'package:flutter_test/flutter_test.dart';
import 'package:storekit_external_purchase/storekit_external_purchase.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_platform_interface.dart';
import 'package:storekit_external_purchase/storekit_external_purchase_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStorekitExternalPurchasePlatform with MockPlatformInterfaceMixin implements StorekitExternalPurchasePlatform {
  @override
  Future<String?> getCountryCode() => Future.value('US');

  @override
  Future<bool> isExternalPurchaseAvailable() => Future.value(true);

  @override
  Future<ExternalPurchaseResult> presentExternalPurchase(String destinationUrl) =>
      Future.value(ExternalPurchaseResult(accepted: true));
}

class MockStorekitExternalPurchasePlatformNull
    with MockPlatformInterfaceMixin
    implements StorekitExternalPurchasePlatform {
  @override
  Future<String?> getCountryCode() => Future.value(null);

  @override
  Future<bool> isExternalPurchaseAvailable() => Future.value(false);

  @override
  Future<ExternalPurchaseResult> presentExternalPurchase(String destinationUrl) =>
      Future.value(ExternalPurchaseResult(accepted: false));
}

void main() {
  final StorekitExternalPurchasePlatform initialPlatform = StorekitExternalPurchasePlatform.instance;

  test('$MethodChannelStorekitExternalPurchase is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStorekitExternalPurchase>());
  });

  test('getCountryCode returns value', () async {
    StorekitExternalPurchase storekitExternalPurchasePlugin = StorekitExternalPurchase();
    MockStorekitExternalPurchasePlatform fakePlatform = MockStorekitExternalPurchasePlatform();
    StorekitExternalPurchasePlatform.instance = fakePlatform;

    expect(await storekitExternalPurchasePlugin.getCountryCode(), 'US');
  });

  test('getCountryCode returns null', () async {
    StorekitExternalPurchase storekitExternalPurchasePlugin = StorekitExternalPurchase();
    MockStorekitExternalPurchasePlatformNull fakePlatform = MockStorekitExternalPurchasePlatformNull();
    StorekitExternalPurchasePlatform.instance = fakePlatform;

    expect(await storekitExternalPurchasePlugin.getCountryCode(), null);
  });
}
