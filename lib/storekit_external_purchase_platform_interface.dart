import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'storekit_external_purchase_method_channel.dart';

class ExternalPurchaseResult {
  ExternalPurchaseResult({required this.accepted, this.token});

  final bool accepted;
  final String? token;

  factory ExternalPurchaseResult.fromMap(Map<Object?, Object?> map) {
    return ExternalPurchaseResult(accepted: (map['accepted'] as bool?) ?? false, token: map['token'] as String?);
  }
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

  Future<bool> isExternalPurchaseAvailable() {
    throw UnimplementedError('isExternalPurchaseAvailable() has not been implemented.');
  }

  Future<ExternalPurchaseResult> presentExternalPurchase(String destinationUrl) {
    throw UnimplementedError('presentExternalPurchase() has not been implemented.');
  }
}
