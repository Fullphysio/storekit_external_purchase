## 0.4.0

* `AgeRangeShared.declaration`: how the age range was set (`AgeRangeService.AgeRangeDeclaration`), with `AgeRangeDeclaration.isConfirmed` for an age the system confirmed (`confirmed` on iOS 26.5+, `paymentChecked` and the other checked cases on 26.2 to 26.4). A case added in a later iOS reads as `null`.

## 0.3.0

* `TokenType.inApp` (`IN_APP`) and `TokenType.linkOut` (`LINK_OUT`), the token types for the EU on iOS 27.2+ and for Brazil and Japan on iOS 26.4+.

## 0.2.0

* `requestAgeRange` over `DeclaredAgeRange`'s `AgeRangeService` (iOS 26+), returning `AgeRangeShared` or `AgeRangeDeclined`; errors map to `AGE_RANGE_NOT_AVAILABLE`, `AGE_RANGE_INVALID_REQUEST` and `AGE_RANGE_UNAVAILABLE`.

## 0.1.0

* First release.
* `isEligible`, `canMakePayments`, `showNotice`, `token` and `getCountryCode` over StoreKit's `ExternalPurchaseCustomLink`, `AppStore` and `Storefront`.
* Swift Package Manager and CocoaPods support.
