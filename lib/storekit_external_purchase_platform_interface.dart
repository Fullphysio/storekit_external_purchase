import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'storekit_external_purchase_method_channel.dart';

/// Where the external purchase happens after the notice.
enum NoticeType {
  /// The purchase continues in the default browser.
  browser(0),

  /// The purchase continues inside the app.
  withinApp(1);

  const NoticeType(this.value);

  final int value;
}

/// The kind of token to request for Apple's External Purchase Server API.
enum TokenType {
  /// The person has not bought through this app's external link before.
  acquisition('ACQUISITION'),

  /// The person already acquired through the external link; used for
  /// subsequent purchases and renewals.
  services('SERVICES'),

  /// A purchase processed inside the app. Request it before every potential
  /// transaction in the EU on iOS 27.2+, and in Brazil and Japan on iOS 26.4+.
  inApp('IN_APP'),

  /// A purchase on a website the app links out to. Same rules as [inApp].
  linkOut('LINK_OUT');

  const TokenType(this.value);

  final String value;
}

/// The person's choice on the disclosure sheet.
enum NoticeResult {
  /// The person chose to continue to the external purchase.
  continued('continued'),

  /// The person dismissed the sheet.
  cancelled('cancelled');

  const NoticeResult(this.value);

  final String value;

  static NoticeResult fromValue(String value) {
    return NoticeResult.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid notice result: $value'),
    );
  }
}

/// An External Purchase Server API token.
class Token {
  /// The token data as returned from StoreKit
  final String value;

  const Token(this.value);

  @override
  String toString() => 'Token(data: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// The person's answer to an age range request.
sealed class AgeRangeResponse {
  const AgeRangeResponse();
}

/// How the age range was set (`AgeRangeService.AgeRangeDeclaration`).
///
/// On iOS 26.5+, an age confirmed by credit card, government ID or selfie is
/// [confirmed]. iOS 26.2 to 26.4 name the method instead: [paymentChecked],
/// [governmentIDChecked], [checkedByOtherMethod] and their guardian forms.
enum AgeRangeDeclaration {
  selfDeclared,
  guardianDeclared,
  confirmed,
  paymentChecked,
  governmentIDChecked,
  checkedByOtherMethod,
  guardianPaymentChecked,
  guardianGovernmentIDChecked,
  guardianCheckedByOtherMethod;

  /// Parses the Swift case name. A case added in a later iOS is `null`.
  static AgeRangeDeclaration? fromName(String? name) =>
      name == null ? null : values.asNameMap()[name];

  /// Whether the system confirmed the age, rather than a person declaring it.
  bool get isConfirmed => switch (this) {
    selfDeclared || guardianDeclared => false,
    _ => true,
  };
}

/// The person shared an age range. A `null` bound means the range is open on
/// that side: with an age gate of 18, an adult gets `lowerBound: 18` and
/// `upperBound: null`. [declaration] is `null` when iOS gives none or a case
/// this version does not know.
final class AgeRangeShared extends AgeRangeResponse {
  const AgeRangeShared({this.lowerBound, this.upperBound, this.declaration});

  final int? lowerBound;
  final int? upperBound;
  final AgeRangeDeclaration? declaration;

  @override
  String toString() =>
      'AgeRangeShared(lowerBound: $lowerBound, upperBound: $upperBound, '
      'declaration: ${declaration?.name})';

  @override
  bool operator ==(Object other) =>
      other is AgeRangeShared &&
      lowerBound == other.lowerBound &&
      upperBound == other.upperBound &&
      declaration == other.declaration;

  @override
  int get hashCode => Object.hash(lowerBound, upperBound, declaration);
}

/// The person, or their parent or guardian, declined to share an age range.
final class AgeRangeDeclined extends AgeRangeResponse {
  const AgeRangeDeclined();

  @override
  String toString() => 'AgeRangeDeclined()';

  @override
  bool operator ==(Object other) => other is AgeRangeDeclined;

  @override
  int get hashCode => (AgeRangeDeclined).hashCode;
}

/// The interface platform implementations of this plugin extend.
abstract class StorekitExternalPurchasePlatform extends PlatformInterface {
  /// Constructs a StorekitExternalPurchasePlatform.
  StorekitExternalPurchasePlatform() : super(token: _token);

  static final Object _token = Object();

  static StorekitExternalPurchasePlatform _instance =
      MethodChannelStorekitExternalPurchase();

  /// The default instance of [StorekitExternalPurchasePlatform] to use.
  ///
  /// Defaults to [MethodChannelStorekitExternalPurchase].
  static StorekitExternalPurchasePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StorekitExternalPurchasePlatform] when
  /// they register themselves.
  static set instance(StorekitExternalPurchasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getCountryCode() {
    throw UnimplementedError('getCountryCode() has not been implemented.');
  }

  Future<bool> isEligible() {
    throw UnimplementedError('isEligible() has not been implemented.');
  }

  Future<bool> canMakePayments() {
    throw UnimplementedError('canMakePayments() has not been implemented.');
  }

  Future<NoticeResult> showNotice(NoticeType noticeType) {
    throw UnimplementedError('showNotice() has not been implemented.');
  }

  Future<Token?> token(TokenType tokenType) {
    throw UnimplementedError('token() has not been implemented.');
  }

  Future<AgeRangeResponse> requestAgeRange(List<int> ageGates) {
    throw UnimplementedError('requestAgeRange() has not been implemented.');
  }
}
