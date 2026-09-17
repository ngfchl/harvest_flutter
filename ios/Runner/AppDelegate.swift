import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let badgeChannelName = "com.ptools.harvest/app_badge"
  private var badgeChannelRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerBadgeChannelIfNeeded()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Scene 生命周期下 window 由 SceneDelegate 在 didFinishLaunching 之后创建，
  /// 此时 rootViewController 尚未就绪；active 回调时必然已就绪，补注册一次。
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    registerBadgeChannelIfNeeded()
  }

  private func registerBadgeChannelIfNeeded() {
    guard !badgeChannelRegistered else { return }
    // Scene 生命周期下 window 属于 SceneDelegate，AppDelegate.window 恒为 nil，
    // 需从 connectedScenes 的前台 Scene 中取 FlutterViewController
    let controller = window?.rootViewController as? FlutterViewController
      ?? UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .compactMap { $0.rootViewController as? FlutterViewController }
        .first
    guard let controller else { return }
    badgeChannelRegistered = true
    FlutterMethodChannel(
      name: badgeChannelName,
      binaryMessenger: controller.binaryMessenger
    ).setMethodCallHandler { call, result in
      guard call.method == "setBadgeCount" else {
        result(FlutterMethodNotImplemented)
        return
      }

      let count = max(call.arguments as? Int ?? 0, 0)
      if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
          DispatchQueue.main.async {
            if let error = error {
              result(FlutterError(code: "BADGE_UPDATE_FAILED", message: error.localizedDescription, details: nil))
            } else {
              result(nil)
            }
          }
        }
      } else {
        UIApplication.shared.applicationIconBadgeNumber = count
        result(nil)
      }
    }
  }
}
