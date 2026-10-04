# storekit_external_purchase

Flutter plugin for Apple's [StoreKit External Purchase Custom Link](https://developer.apple.com/documentation/storekit/externalpurchasecustomlink) API: link out of an iOS app to your own payment page (Stripe, Paddle, …) where Apple's EU terms allow it.

iOS only. Supports Swift Package Manager and CocoaPods.

| Method | StoreKit | Min iOS |
|--------|----------|---------|
| `isEligible()` | `ExternalPurchaseCustomLink.isEligible` | 18.1 |
| `showNotice(NoticeType)` | `ExternalPurchaseCustomLink.showNotice(type:)` | 18.1 |
| `token(TokenType)` | `ExternalPurchaseCustomLink.token(for:)` | 18.1 |
| `canMakePayments()` | `AppStore.canMakePayments` | 15 |
| `getCountryCode()` | `Storefront.current?.countryCode` (alpha-3) | 15 |

Below the minimum, calls throw a `PlatformException` with code `UNSUPPORTED_API` (`getCountryCode` returns `null`).

## Setup

1. Accept the current Apple Developer Program License Agreement and enable **StoreKit External Purchases or Offers (EU)** on your App ID.
2. Add the entitlement with the storefronts you sell in to your `.entitlements` file:

   ```xml
   <key>com.apple.developer.storekit.custom-purchase-link.allowed-regions</key>
   <array>
     <string>fr</string>
     <string>de</string>
   </array>
   ```

3. Regenerate the provisioning profiles.

`isEligible()` is `true` only when the entitlement is in the signed profile, the person's App Store storefront is in that list, the OS is recent enough and Apple's server-side eligibility allows it.

## Usage

```dart
import 'package:storekit_external_purchase/storekit_external_purchase.dart';

final storeKit = StorekitExternalPurchase();

Future<void> buy() async {
  if (!await storeKit.canMakePayments() || !await storeKit.isEligible()) {
    return; // fall back to in-app purchase
  }
  if (await storeKit.showNotice(NoticeType.browser) != NoticeResult.continued) {
    return;
  }
  final token = await storeKit.token(TokenType.acquisition) ??
      await storeKit.token(TokenType.services);
  // Send token.value to your server, then open your checkout URL.
}
```

## Reporting

Apple requires every token and every resulting transaction to be reported to the [External Purchase Server API](https://developer.apple.com/documentation/externalpurchaseserverapi) from your server. This plugin only fetches the tokens.

## License

BSD 3-Clause, see [LICENSE](LICENSE).
