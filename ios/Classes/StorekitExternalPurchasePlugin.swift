import Flutter
import UIKit
import StoreKit

public class StorekitExternalPurchasePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "storekit_external_purchase", binaryMessenger: registrar.messenger())
    let instance = StorekitExternalPurchasePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCountryCode":
      if #available(iOS 15.0, *) {
        Task {
            let storefront = await Storefront.current
            result(storefront?.countryCode)
        }
      } else {
        result(nil)
      }
    case "isEligible":
      if #available(iOS 18.1, *) {
        Task {
          let eligible = await ExternalPurchaseCustomLink.isEligible
          result(eligible)
        }
      } else {
        result(false)
      }
    case "canMakePayments":
      if #available(iOS 15.0, *) {
        result(AppStore.canMakePayments)
      } else {
        result(false)
      }
    case "showNotice":
      if #available(iOS 18.1, *) {
        guard let args = call.arguments as? [String: Any],
              let noticeTypeString = args["noticeType"] as? Int,
              let noticeType = ExternalPurchaseCustomLink.NoticeType(rawValue: noticeTypeString) else {
          result(FlutterError(
            code: "INVALID_ARGUMENTS",
            message: "Invalid arguments",
            details: ["noticeType": call.arguments]
          ))
          return
        }
        Task {
          do {
            let purchaseResult = try await ExternalPurchaseCustomLink.showNotice(type: noticeType)
            var resultString: String
            switch purchaseResult {
            case .continued:
                resultString = "continued"
            case .cancelled:
                resultString = "cancelled"
            @unknown default:
                resultString = "error"
            }
            result(resultString)
          } catch {
            result(FlutterError(
              code: "SHOW_NOTICE_FAILED",
              message: "Failed to show external purchase notice",
              details: error.localizedDescription
            ))
          }
        }
      } else {
        result(FlutterError(
            code: "UNSUPPORTED_API",
            message: "The requested feature is not supported on this version of iOS.",
            details: ["min_version": "iOS 18.1"]
        ))
      }
    case "token":
      if #available(iOS 18.1, *) {
        guard let args = call.arguments as? [String: Any],
              let tokenTypeString = args["tokenType"] as? String else {
          result(FlutterError(
            code: "INVALID_ARGUMENTS",
            message: "Invalid arguments",
            details: ["tokenType": call.arguments]
          ))
          return
        }
        Task {
          do {
            let token = try await ExternalPurchaseCustomLink.token(for: tokenTypeString)
            if let token = token {
              result(token.value)
            } else {
              result(nil)
            }
          } catch {
            result(FlutterError(
              code: "TOKEN_REQUEST_FAILED",
              message: "Failed to request external purchase token",
              details: error.localizedDescription
            ))
          }
        }
      } else {
        result(FlutterError(
          code: "UNSUPPORTED_API",
          message: "The requested feature is not supported on this version of iOS.",
          details: ["min_version": "iOS 18.1"]
        ))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
