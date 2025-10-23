import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'storekit_external_purchase_method_channel.dart';

enum NoticeType {
  browser(0),
  withinApp(1);

  const NoticeType(this.value);

  final int value;
}

enum TokenType {
  acquisition('ACQUISITION'),
  services('SERVICES');

  const TokenType(this.value);

  final String value;
}

enum NoticeResult {
  continued("continued"),
  cancelled("cancelled");

  const NoticeResult(this.value);

  final String value;

  static NoticeResult fromValue(String value) {
    try {
      return NoticeResult.values.firstWhere((e) => e.value == value);
    } catch (_) {
      throw ArgumentError('Invalid notice result: $value');
    }
  }
}

class Token {
  /// The token data as returned from StoreKit
  final String value;

  const Token(this.value);

  @override
  String toString() => 'Token(data: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Token && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

abstract class StorekitExternalPurchasePlatform extends PlatformInterface {
  /// Constructs a StorekitExternalPurchasePlatform.
  StorekitExternalPurchasePlatform() : super(token: _token);

  static final Object _token = Object();

  static StorekitExternalPurchasePlatform _instance = MethodChannelStorekitExternalPurchase();

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
