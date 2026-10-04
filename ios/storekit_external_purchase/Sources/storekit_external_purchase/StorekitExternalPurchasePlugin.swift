import Flutter
import StoreKit
import UIKit

public class StorekitExternalPurchasePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "storekit_external_purchase", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(StorekitExternalPurchasePlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCountryCode":
      guard #available(iOS 15.0, *) else {
        result(nil)
        return
      }
      Task {
        result(await Storefront.current?.countryCode)
      }
    case "canMakePayments":
      guard #available(iOS 15.0, *) else {
        result(Self.unsupported("iOS 15.0"))
        return
      }
      result(AppStore.canMakePayments)
    case "isEligible":
      guard #available(iOS 18.1, *) else {
        result(Self.unsupported("iOS 18.1"))
        return
      }
      Task {
        result(await ExternalPurchaseCustomLink.isEligible)
      }
    case "showNotice":
      guard #available(iOS 18.1, *) else {
        result(Self.unsupported("iOS 18.1"))
        return
      }
      guard let args = call.arguments as? [String: Any],
            let rawNoticeType = args["noticeType"] as? Int,
            let noticeType = Self.noticeType(from: rawNoticeType) else {
        result(Self.invalidArguments(call))
        return
      }
      Task { @MainActor in
        do {
          switch try await ExternalPurchaseCustomLink.showNotice(type: noticeType) {
          case .continued:
            result("continued")
          case .cancelled:
            result("cancelled")
          @unknown default:
            result(FlutterError(code: "UNKNOWN_NOTICE_RESULT", message: "StoreKit returned an unknown notice result", details: nil))
          }
        } catch {
          result(FlutterError(code: "SHOW_NOTICE_FAILED", message: "Failed to show external purchase notice", details: error.localizedDescription))
        }
      }
    case "token":
      guard #available(iOS 18.1, *) else {
        result(Self.unsupported("iOS 18.1"))
        return
      }
      guard let args = call.arguments as? [String: Any],
            let tokenType = args["tokenType"] as? String else {
        result(Self.invalidArguments(call))
        return
      }
      Task {
        do {
          result(try await ExternalPurchaseCustomLink.token(for: tokenType)?.value)
        } catch {
          result(FlutterError(code: "TOKEN_REQUEST_FAILED", message: "Failed to request external purchase token", details: error.localizedDescription))
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 18.1, *)
  private static func noticeType(from value: Int) -> ExternalPurchaseCustomLink.NoticeType? {
    switch value {
    case 0: return .browser
    case 1: return .withinApp
    default: return nil
    }
  }

  private static func unsupported(_ minVersion: String) -> FlutterError {
    FlutterError(
      code: "UNSUPPORTED_API",
      message: "The requested feature is not supported on this version of iOS.",
      details: ["min_version": minVersion]
    )
  }

  private static func invalidArguments(_ call: FlutterMethodCall) -> FlutterError {
    FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for \(call.method)", details: call.arguments)
  }
}
