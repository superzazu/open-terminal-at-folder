import Cocoa
import ScriptingBridge

/// Returns the active window's document path (when possible).
func getActiveWindowDocumentDirectory() -> URL? {
  guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
    print("No frontmost application found.")
    return nil
  }
  let pid = frontmostApp.processIdentifier

  let appElement = AXUIElementCreateApplication(pid)

  // Get the focused window
  var focusedWindow: CFTypeRef?
  let result = AXUIElementCopyAttributeValue(
    appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow
  )
  guard result == .success,
    let windowRef = focusedWindow,
    CFGetTypeID(windowRef) == AXUIElementGetTypeID()
  else {
    print("Could not retrieve the focused window.")
    return nil
  }

  let window = windowRef as! AXUIElement

  // Get the document path of the focused window
  var documentPath: CFTypeRef?
  let docResult = AXUIElementCopyAttributeValue(
    window, kAXDocumentAttribute as CFString, &documentPath
  )
  guard docResult == .success, let path = documentPath as? String else {
    print("Could not retrieve the document path for the focused window.")
    return nil
  }

  var url = URL(string: path)

  // special case for Terminal, where the document path is already a directory
  if frontmostApp.bundleIdentifier != "com.apple.Terminal" {
    url = url?.deletingLastPathComponent()
  }

  return url
}

/// Returns the path to Finder's insertion location (eg the path in which
/// a new folder would appear if “New Folder” was selected)
func getFinderInsertionLocationDirectory() -> URL? {
  guard let app = SBApplication(bundleIdentifier: "com.apple.finder") else {
    print("Could not access Finder.")
    return nil
  }
  let finder = app as FinderApplication

  guard let location = finder.insertionLocation?.get() as? FinderItem,
    let urlString = location.URL,
    let url = URL(string: urlString)
  else {
    print("Could not retrieve Finder selection or URL is invalid.")
    return nil
  }

  return url
}

func openTerminal(at url: URL) throws {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
  process.arguments = ["-a", "Terminal", url.path]
  try process.run()
  // process.waitUntilExit()
}

/// Gets the current directory based on the frontmost application or
/// Finder insertion location.
func getCurrentDirectory() -> URL {
  let homeDirectory = FileManager.default.homeDirectoryForCurrentUser

  guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
    print("No frontmost application found. Defaulting to home directory.")
    return homeDirectory
  }

  let directory: URL?
  if frontmostApp.bundleIdentifier == "com.apple.finder" {
    directory = getFinderInsertionLocationDirectory()
  } else {
    directory = getActiveWindowDocumentDirectory()
  }

  return directory ?? homeDirectory
}

func main() {
  let currentDir = getCurrentDirectory()

  do {
    try openTerminal(at: currentDir)
  } catch {
    print("Failed to open Terminal: \(error.localizedDescription)")
  }
}

main()
