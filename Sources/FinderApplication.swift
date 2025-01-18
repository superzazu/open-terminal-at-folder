import Cocoa
import ScriptingBridge

@objc protocol FinderApplication {
  /// The container in which a new folder would appear if “New Folder”
  /// was selected
  @objc optional var insertionLocation: SBObject { get }
}
extension SBApplication: FinderApplication {}

@objc protocol FinderItem {
  /// The URL of the item
  @objc optional var URL: String { get }
}
extension SBObject: FinderItem {}
