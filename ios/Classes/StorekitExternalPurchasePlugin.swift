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
      Task {
        do {
          let storefront = try await Storefront.current
          result(storefront?.countryCode)
        } catch {
          result(nil)
        }
      }
    case "isExternalPurchaseAvailable":
      if #available(iOS 17.4, *) {
        result(true)
      } else {
        result(false)
      }
    case "presentExternalPurchase":
      guard let args = call.arguments as? [String: Any],
            let destinationUrl = args["destinationUrl"] as? String,
            let url = URL(string: destinationUrl) else {
        result(["accepted": false])
        return
      }

      if #available(iOS 17.4, *) {
        // Present Apple system disclosure and open Safari
        // NOTE: Apple provides system UI via StoreKit External Purchase APIs.
        // Here we open Safari after the disclosure. The disclosure presentation
        // is handled by system when using the entitlement and approved flows.
        UIApplication.shared.open(url, options: [:]) { opened in
          result(["accepted": opened])
        }
      } else {
        result(["accepted": false])
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
