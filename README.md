# storekit_external_purchase

A Flutter plugin that exposes Apple StoreKit External Purchase (Custom Link) APIs to Flutter.

This plugin lets you:
- Check if the device can make App Store payments
- Check whether the app/account is eligible for the External Purchase Custom Link program
- Present the required StoreKit notice (browser or in-app) and get the result

For more information about Apple's External Purchase APIs, see the [official documentation](https://developer.apple.com/documentation/storekit/external-purchase).

Note: External Purchase is available only in EU storefronts and requires specific OS versions. See Requirements.

## Requirements
- iOS 17.4+ (APIs used for notice presentation require iOS 18.1+)
- Xcode with an App ID configured for `com.apple.developer.storekit.external-purchase-link`
- Provisioning profiles regenerated after enabling the entitlement

## Installation
Add to your `pubspec.yaml`:

```yaml
dependencies:
  storekit_external_purchase: ^0.0.1
```

Run `flutter pub get`.

## iOS Setup
1. Enable the entitlement for your App ID on Apple Developer portal.
2. In Xcode, ensure your target’s `.entitlements` (`Runner.entitlements`) includes:

```xml
<key>com.apple.developer.storekit.external-purchase-link</key>
<true/>
```

If using the example app, this is already present in `example/ios/Runner/Runner.entitlements` and the project references it via `CODE_SIGN_ENTITLEMENTS`.

On next build or archive, Xcode may fetch a new provisioning profile that includes the entitlement.

## API

```dart
enum NoticeType { browser, withinApp }

enum NoticeResult { continued, cancelled }

class StorekitExternalPurchase {
  Future<String?> getCountryCode();
  Future<bool> isExternalPurchaseAvailable();
  Future<bool> canMakePayments();
  Future<NoticeResult> showNotice(NoticeType noticeType);
}
```

- `getCountryCode()` returns the current App Store storefront country code (iOS 15+), or null.
- `isExternalPurchaseAvailable()` returns whether the External Purchase Custom Link is available (iOS 18.1+).
- `canMakePayments()` proxies `AppStore.canMakePayments` (iOS 15+).
- `showNotice(NoticeType)` presents Apple’s system notice and resolves to `continued` or `cancelled` (iOS 18.1+).

## Usage

```dart
import 'package:storekit_external_purchase/storekit_external_purchase.dart';

final sdk = StorekitExternalPurchase();

Future<void> attemptExternalPurchase() async {
  final canPay = await sdk.canMakePayments();
  final eligible = await sdk.isExternalPurchaseAvailable();

  if (!eligible) return;

  // Choose which notice to show based on your flow
  final result = await sdk.showNotice(NoticeType.withinApp);
  if (result == NoticeResult.continued) {
    // Open your external link or proceed with your flow here
  }
}
```

## Notes
- Ensure your app distribution targets EU storefronts and meets Apple’s policy requirements. For details on communication and promotion of offers on the App Store in the EU, see [Apple's support page](https://developer.apple.com/support/communication-and-promotion-of-offers-on-the-app-store-in-the-eu/).
- Wrap calls with platform/version checks as needed if you support older iOS versions.

