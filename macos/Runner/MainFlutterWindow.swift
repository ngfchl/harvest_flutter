import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)
    self.isMovableByWindowBackground = true
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    DispatchQueue.main.async {
      self.moveWindowControlsDown()
    }
  }

  private func moveWindowControlsDown() {
    let offset: CGFloat = 12
    let buttonTypes: [NSWindow.ButtonType] = [
      .closeButton,
      .miniaturizeButton,
      .zoomButton,
    ]

    for type in buttonTypes {
      guard let button = self.standardWindowButton(type) else { continue }
      button.setFrameOrigin(
        NSPoint(x: button.frame.origin.x, y: button.frame.origin.y - offset)
      )
    }
  }
}
