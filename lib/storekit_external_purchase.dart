/// Apple StoreKit External Purchase Custom Link APIs for Flutter (iOS only).
library;

export 'storekit_external_purchase_platform_interface.dart'
    show NoticeType, TokenType, NoticeResult, Token;
import 'storekit_external_purchase_platform_interface.dart';

/// Entry point to StoreKit's `ExternalPurchaseCustomLink` and related APIs.
///
/// Calls made on an iOS version below an API's minimum throw a
/// `PlatformException` with code `UNSUPPORTED_API`.
class StorekitExternalPurchase {
  /// The App Store storefront country code (ISO 3166-1 alpha-3, e.g. `FRA`),
  /// or `null` when unavailable or below iOS 15.
  Future<String?> getCountryCode() {
    return StorekitExternalPurchasePlatform.instance.getCountryCode();
  }

  /// Whether the app can link out to an external purchase on this device
  /// (`ExternalPurchaseCustomLink.isEligible`, iOS 18.1+).
  Future<bool> isEligible() {
    return StorekitExternalPurchasePlatform.instance.isEligible();
  }

  /// Whether the person is allowed to make payments
  /// (`AppStore.canMakePayments`, iOS 15+).
  Future<bool> canMakePayments() {
    return StorekitExternalPurchasePlatform.instance.canMakePayments();
  }

  /// Presents Apple's system disclosure sheet before linking out
  /// (`ExternalPurchaseCustomLink.showNotice(type:)`, iOS 18.1+).
  ///
  /// Only continue to the external purchase when this returns
  /// [NoticeResult.continued].
  Future<NoticeResult> showNotice(NoticeType noticeType) {
    return StorekitExternalPurchasePlatform.instance.showNotice(noticeType);
  }

  /// A token to report to Apple's External Purchase Server API
  /// (`ExternalPurchaseCustomLink.token(for:)`, iOS 18.1+), or `null` when
  /// StoreKit has none of this type for the current person.
  Future<Token?> token(TokenType tokenType) {
    return StorekitExternalPurchasePlatform.instance.token(tokenType);
  }
}
