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
  Future<bool> isEligible() async {
    final available = await methodChannel.invokeMethod<bool>('isEligible');
    return available ?? false;
  }

  @override
  Future<bool> canMakePayments() async {
    final result = await methodChannel.invokeMethod<bool>('canMakePayments');
    return result ?? false;
  }

  @override
  Future<NoticeResult> showNotice(NoticeType noticeType) async {
    final resultString = await methodChannel.invokeMethod<String>('showNotice', {'noticeType': noticeType.value});
    return NoticeResult.fromValue(resultString ?? 'cancelled');
  }

  @override
  Future<Token?> token(TokenType tokenType) async {
    final result = await methodChannel.invokeMethod<String>('token', {'tokenType': tokenType.value});
    return result != null ? Token(result) : null;
  }
}
