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
  services('SERVICES');

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
}
