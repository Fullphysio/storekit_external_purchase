import 'storekit_external_purchase_platform_interface.dart';

class StorekitExternalPurchase {
  Future<String?> getCountryCode() {
    return StorekitExternalPurchasePlatform.instance.getCountryCode();
  }

  Future<bool> isExternalPurchaseAvailable() {
    return StorekitExternalPurchasePlatform.instance.isExternalPurchaseAvailable();
  }

  Future<ExternalPurchaseResult> presentExternalPurchase(String destinationUrl) {
    return StorekitExternalPurchasePlatform.instance.presentExternalPurchase(destinationUrl);
  }
}
