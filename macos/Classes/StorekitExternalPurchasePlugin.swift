import Cocoa
import FlutterMacOS
import StoreKit

public class StorekitExternalPurchasePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "storekit_external_purchase", binaryMessenger: registrar.messenger)
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
      // External purchase flow is not applicable on macOS as apps can already open external URLs
      result(false)
    case "presentExternalPurchase":
      guard let args = call.arguments as? [String: Any],
            let destinationUrl = args["destinationUrl"] as? String,
            let url = URL(string: destinationUrl) else {
        result(["accepted": false])
        return
      }

      // On macOS, we can directly open the URL without system disclosure
      NSWorkspace.shared.open(url)
      result(["accepted": true])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
