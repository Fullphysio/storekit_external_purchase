export 'storekit_external_purchase_platform_interface.dart' show NoticeType, TokenType, NoticeResult, Token;
import 'storekit_external_purchase_platform_interface.dart';

class StorekitExternalPurchase {
  Future<String?> getCountryCode() {
    return StorekitExternalPurchasePlatform.instance.getCountryCode();
  }

  Future<bool> isEligible() {
    return StorekitExternalPurchasePlatform.instance.isEligible();
  }

  Future<bool> canMakePayments() {
    return StorekitExternalPurchasePlatform.instance.canMakePayments();
  }

  Future<NoticeResult> showNotice(NoticeType noticeType) {
    return StorekitExternalPurchasePlatform.instance.showNotice(noticeType);
  }

  Future<Token?> token(TokenType tokenType) {
    return StorekitExternalPurchasePlatform.instance.token(tokenType);
  }
}
