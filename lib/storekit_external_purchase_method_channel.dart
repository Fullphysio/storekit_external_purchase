import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'storekit_external_purchase_platform_interface.dart';

/// An implementation of [StorekitExternalPurchasePlatform] that uses method channels.
class MethodChannelStorekitExternalPurchase extends StorekitExternalPurchasePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('storekit_external_purchase');

  @override
  Future<String?> getCountryCode() async {
    final countryCode = await methodChannel.invokeMethod<String>('getCountryCode');
    return countryCode;
  }

  @override
  Future<bool> isExternalPurchaseAvailable() async {
    final available = await methodChannel.invokeMethod<bool>('isExternalPurchaseAvailable');
    return available ?? false;
  }

  @override
  Future<ExternalPurchaseResult> presentExternalPurchase(String destinationUrl) async {
    final resultMap = await methodChannel.invokeMethod<Map<Object?, Object?>>('presentExternalPurchase', {
      'destinationUrl': destinationUrl,
    });
    return ExternalPurchaseResult.fromMap(resultMap ?? const {'accepted': false});
  }
}
