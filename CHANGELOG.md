## 0.3.0

* `TokenType.inApp` (`IN_APP`) and `TokenType.linkOut` (`LINK_OUT`), the token types for the EU on iOS 27.2+ and for Brazil and Japan on iOS 26.4+.

## 0.2.0

* `requestAgeRange` over `DeclaredAgeRange`'s `AgeRangeService` (iOS 26+), returning `AgeRangeShared` or `AgeRangeDeclined`; errors map to `AGE_RANGE_NOT_AVAILABLE`, `AGE_RANGE_INVALID_REQUEST` and `AGE_RANGE_UNAVAILABLE`.

## 0.1.0

* First release.
* `isEligible`, `canMakePayments`, `showNotice`, `token` and `getCountryCode` over StoreKit's `ExternalPurchaseCustomLink`, `AppStore` and `Storefront`.
* Swift Package Manager and CocoaPods support.
