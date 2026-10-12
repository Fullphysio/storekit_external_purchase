import DeclaredAgeRange
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
    case "requestAgeRange":
      guard #available(iOS 26.0, *) else {
        result(Self.unsupported("iOS 26.0"))
        return
      }
      guard let args = call.arguments as? [String: Any],
            let ageGates = args["ageGates"] as? [Int],
            (1...3).contains(ageGates.count) else {
        result(Self.invalidArguments(call))
        return
      }
      Task { @MainActor in
        guard let viewController = Self.topViewController() else {
          result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller to present the age range sheet from", details: nil))
          return
        }
        do {
          let response = try await AgeRangeService.shared.requestAgeRange(
            ageGates: ageGates[0],
            ageGates.count > 1 ? ageGates[1] : nil,
            ageGates.count > 2 ? ageGates[2] : nil,
            in: viewController
          )
          switch response {
          case let .sharing(range):
            result(["status": "sharing", "lowerBound": range.lowerBound as Any, "upperBound": range.upperBound as Any])
          case .declinedSharing:
            result(["status": "declined"])
          @unknown default:
            result(FlutterError(code: "UNKNOWN_AGE_RANGE_RESPONSE", message: "DeclaredAgeRange returned an unknown response", details: nil))
          }
        } catch {
          result(FlutterError(code: "AGE_RANGE_REQUEST_FAILED", message: "Failed to request the age range", details: String(describing: error)))
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @MainActor
  private static func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
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
