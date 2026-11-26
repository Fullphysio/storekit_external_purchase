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
| `requestAgeRange(List<int>)` | `AgeRangeService.requestAgeRange(ageGates:_:_:in:)` | 26 |

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

3. To use `requestAgeRange`, also enable **Declared Age Range** on the App ID and add `<key>com.apple.developer.declared-age-range</key><true/>`.
4. Regenerate the provisioning profiles.

`isEligible()` is `true` only when the entitlement is in the signed profile, the person's App Store storefront is in that list, the OS is recent enough and Apple's server-side eligibility allows it.

## Usage

```dart
import 'package:flutter/services.dart';
import 'package:storekit_external_purchase/storekit_external_purchase.dart';

final storeKit = StorekitExternalPurchase();

/// Call at launch and again on the purchase tap.
Future<bool> useExternalPurchase() async {
  if (!await storeKit.canMakePayments()) return false; // offer no purchase at all
  return storeKit.isEligible(); // false: use In-App Purchase
}

/// iOS 27.2+ in the EU: IN_APP. Earlier: ACQUISITION, then SERVICES.
Future<Token?> currentToken({required bool iOS272OrLater}) async {
  final types = iOS272OrLater
      ? [TokenType.inApp]
      : [TokenType.acquisition, TokenType.services];
  for (final type in types) {
    try {
      final token = await storeKit.token(type);
      if (token != null) return token;
    } on PlatformException {
      // Each type on its own: one failure must not stop the others.
    }
  }
  return null;
}

Future<void> onPurchaseTap() async {
  if (await storeKit.showNotice(NoticeType.withinApp) != NoticeResult.continued) {
    return;
  }
  // Send the token to your server, or let the server use the one stored at launch,
  // then open your checkout URL.
}
```

## Age range

`requestAgeRange` wraps Declared Age Range. It is not a parental gate on its own: see [Traps](#traps-and-rabbit-holes). Use it to refuse a confirmed minor, after a visible gate:

```dart
final response = await storeKit.requestAgeRange([18]);
final isMinor = switch (response) {
  AgeRangeShared(:final upperBound) => upperBound != null && upperBound < 18,
  AgeRangeDeclined() => false,
};
```

Errors come back as `PlatformException` codes `AGE_RANGE_NOT_AVAILABLE`, `AGE_RANGE_INVALID_REQUEST` and `AGE_RANGE_UNAVAILABLE` (cases added after iOS 26.0: declined onboarding, ineligible account, network). Only iOS 26.0 symbols are referenced, so the plugin builds with Xcode 26.

`DeclaredAgeRange` is weak-linked, so apps with a deployment target below iOS 26 still launch on older systems.

## Traps and rabbit holes

We shipped EU alternative payments with this plugin in a production app. App Review approved it after 48 days, 9 App Store rejections and 7 TestFlight beta rejections. Most of them came from the points below.

### App Review

- **Read your server logs of the review session before the rejection text.** App Review reuses one message for different failures. One rejection quoted the parental gate, but the real failure was "no token" after the gate.
- **The reviewer tests in the sandbox, often on an iPad, often with their own Sign in with Apple account.** Expect a fresh account and a session longer than one hour.
- **Never fall back to In-App Purchase on an eligible device.** If a check fails and the app shows In-App Purchase, the reviewer reports that the feature "could not be found". Keep the external option and show a message.
- **TestFlight beta review has its own notes field**, separate from the App Store version notes. Keep both in sync.
- **Review notes are limited to 4,000 characters.** Attach a screen recording from an eligible device.
- **Turn off automatic submission in CI while a review thread is open.** A CI tool can submit a build before your notes and video are ready.

### Parental gate

Apple's EU terms require a parental gate before alternative payments for users under 18. In our case, App Review refused all of these:

- An 18+ App Store age rating, with no gate.
- Declared Age Range alone. After the first answer, `requestAgeRange` returns the cached range with no UI. The reviewer's account is an adult, so they see nothing and report "no parental gate". On review iPads it can also throw `AGE_RANGE_NOT_AVAILABLE`.
- A gate on the purchase tap. The gate must show "before the subscription page".

What passed: an adult-level task, shown to every user each time the paywall opens, before plans and prices. Declared Age Range then only refuses a confirmed minor.

On iPadOS 26+, Flutter's `TextInputType.number` shows a floating keypad that sometimes ignores taps ([flutter/flutter#178096](https://github.com/flutter/flutter/issues/178096)). A reviewer could not type the gate answer. Draw your own keypad.

### Tokens

- **iOS 27.2+ in the EU: request `TokenType.inApp`.** `ACQUISITION` and `SERVICES` return `null` there. Apple's docs disagree on this: the sandbox testing page still lists only `ACQUISITION` and `SERVICES`.
- **An `IN_APP` token payload has no `tokenType` and no `tokenExpirationDate`.** If your server requires them, it refuses the token.
- **`token()` returns `null` when no token exists.** The system creates tokens on install and update. In production, `token()` does not create one.
- **Sandbox tokens expire 1 hour after creation** and their `externalPurchaseId` starts with `SANDBOX`. TestFlight and App Review only get sandbox tokens, so your production server must accept them and report them to the sandbox host.
- **Send tokens to your server at launch** and store them on the user account. At checkout, use the stored token when the device returns none.
- **A token belongs to the Apple Account.** Two user accounts on one device send the same token.
- **`token()` can throw `SKInternalErrorDomain` error 14 on some iPads.** Apple says it throws when the app is not eligible. Call `isEligible()` again: false means use In-App Purchase, true means retry once, then use the stored token. A relaunch often clears it.

### Entitlement and profiles

- **A capability change on the App ID invalidates its provisioning profiles.** Regenerate them before the next build.
- **A regenerated profile can silently lose `custom-purchase-link.allowed-regions`** if the capability was unticked on the App ID. Check the profile with `security cms -D -i` and the built app with `codesign -d --entitlements :-`.
- **The App Store Connect API cannot set this capability.** Use the developer portal.
- **Eligibility follows the device's production Apple Account storefront**, not the sandbox account. Simulators return `false`.

### Which option to show

Apple's [`canMakePayments`](https://developer.apple.com/documentation/storekit/appstore/canmakepayments) doc says: when `isEligible` is true, use only the external purchase APIs. Apple's EU terms say In-App Purchase must show at the same time as an alternative payment, when the app offers both. The two do not agree. An app with the external option alone on eligible devices and In-App Purchase on the others passed review for us.

App Store Connect has no setting for the EU payment choice. The choice is what your approved app ships, and it is locked for 12 months.

## Reporting

Apple requires every token and every resulting transaction to be reported to the [External Purchase Server API](https://developer.apple.com/documentation/externalpurchaseserverapi) from your server. This plugin only fetches the tokens.

## License

BSD 3-Clause, see [LICENSE](LICENSE).
