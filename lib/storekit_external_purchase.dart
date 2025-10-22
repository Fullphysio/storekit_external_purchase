import 'storekit_external_purchase_platform_interface.dart';

class StorekitExternalPurchase {
  Future<String?> getCountryCode() {
    return StorekitExternalPurchasePlatform.instance.getCountryCode();
  }

  Future<bool> isExternalPurchaseAvailable() {
    return StorekitExternalPurchasePlatform.instance.isExternalPurchaseAvailable();
  }

  Future<bool> canMakePayments() {
    return StorekitExternalPurchasePlatform.instance.canMakePayments();
  }

  Future<NoticeResult> showNotice(NoticeType noticeType) {
    return StorekitExternalPurchasePlatform.instance.showNotice(noticeType);
  }
}
