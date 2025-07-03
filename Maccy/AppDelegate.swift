import Cocoa
import Intents
import KeyboardShortcuts
import Sauce
#if !CLEEPP
import LaunchAtLogin
#endif
#if !CLEEPP || ALLOW_SPARKLE_UPDATES
import Sparkle
#endif
import os.log

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var copyMenuItem: NSMenuItem!
  @IBOutlet weak var pasteMenuItem: NSMenuItem!

#if CLEEPP
  @IBOutlet weak var cutMenuItem: NSMenuItem!
  
  private var startHotKey: GlobalStartHotKey!
  private var copyHotKey: GlobalCopyHotKey!
  private var pasteHotKey: GlobalPasteHotKey!
  #else
  private var hotKey: GlobalHotKey!
  #endif
  var maccy: Maccy!

  func applicationWillFinishLaunching(_ notification: Notification) {
    #if !CLEEPP
    if ProcessInfo.processInfo.arguments.contains("ui-testing") {
      SPUUpdater(hostBundle: Bundle.main,
                 applicationBundle: Bundle.main,
                 userDriver: SPUStandardUserDriver(hostBundle: Bundle.main, delegate: nil),
                 delegate: nil)
        .automaticallyChecksForUpdates = false
    }
    #endif
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    #if !CLEEPP
    LaunchAtLogin.migrateIfNeeded()
    #endif
    migrateUserDefaults()
    clearOrphanRecords()

    maccy = Maccy()
    #if CLEEPP
    startHotKey = GlobalStartHotKey(maccy.startQueueMode)
    copyHotKey = GlobalCopyHotKey(maccy.queuedCopy)
    pasteHotKey = GlobalPasteHotKey(maccy.queuedPaste)
    #else
    hotKey = GlobalHotKey(maccy.popUp)
    #endif
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    #if CLEEPP
    // if the user has chosen to hide the menu bar icon when not in batch mode then
    // open the Settings window whenever the application icon is double clicked again
    if !UserDefaults.standard.showInStatusBar {
      maccy.showSettings(selectingPane: .general)
    }
    return false // best to return false instead of true to tell NSApp to do nothing
    #else
    maccy.popUp()
    return true
    #endif
  }

  #if CLEEPP
  func application(_ application: NSApplication, open urls: [URL]) {
    // get the first of the url,s ignore the rest
    guard let url = urls.first else {
      return
    }
    if url.absoluteString == Cleepp.showIntroInAppURL {
      maccy.showIntro(self)
    }
    if url.absoluteString == Cleepp.showIntroPermissionPageInAppURL {
      maccy.showIntroAtPermissionPage(self)
    }
    if url.absoluteString == Cleepp.showLicensesInAppURL {
      maccy.showLicenses()
    }
  }
  #endif
  
  func applicationWillTerminate(_ notification: Notification) {
    if UserDefaults.standard.clearOnQuit {
      maccy.clearUnpinned(suppressClearAlert: true)
    }
    CoreDataManager.shared.saveContext()
  }

  @available(macOS 11.0, *)
  func application(_ application: NSApplication, handlerFor intent: INIntent) -> Any? {
    if intent is SelectIntent {
      return SelectIntentHandler(maccy)
    } else if intent is ClearIntent {
      return ClearIntentHandler(maccy)
    } else if intent is GetIntent {
      return GetIntentHandler(maccy)
    } else if intent is DeleteIntent {
      return DeleteIntentHandler(maccy)
    }
    #if CLEEPP
    if intent is StartIntent  {
      return StartIntentHandler(maccy)
    } else if intent is CancelIntent {
      return CancelIntentHandler(maccy)
    } else if intent is BatchCopyIntent {
      return BatchCopyIntentHandler(maccy)
    } else if intent is BatchPasteIntent {
      return BatchPasteIntentHandler(maccy)
    }
    #endif

    return nil
  }

  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable function_body_length
  private func migrateUserDefaults() {
    #if !CLEEPP
    if UserDefaults.standard.migrations["2020-04-25-allow-custom-ignored-types"] != true {
      UserDefaults.standard.ignoredPasteboardTypes = [
        "de.petermaurer.TransientPasteboardType",
        "com.typeit4me.clipping",
        "Pasteboard generator type",
        "com.agilebits.onepassword"
      ]
      UserDefaults.standard.migrations["2020-04-25-allow-custom-ignored-types"] = true
    }

    if UserDefaults.standard.migrations["2020-06-19-use-keyboardshortcuts"] != true {
      if let keys = UserDefaults.standard.string(forKey: "hotKey") {
        var keysList = keys.split(separator: "+")

        if let keyString = keysList.popLast() {
          if let key = Key(character: String(keyString), virtualKeyCode: nil) {
            var modifiers: NSEvent.ModifierFlags = []
            for keyString in keysList {
              switch keyString {
              case "command":
                modifiers.insert(.command)
              case "control":
                modifiers.insert(.control)
              case "option":
                modifiers.insert(.option)
              case "shift":
                modifiers.insert(.shift)
              default: ()
              }
            }

            if let keyboardShortcutKey = KeyboardShortcuts.Key(rawValue: Int(key.QWERTYKeyCode)) {
              let shortcut = KeyboardShortcuts.Shortcut(keyboardShortcutKey, modifiers: modifiers)
              if let encoded = try? JSONEncoder().encode(shortcut) {
                if let hotKeyString = String(data: encoded, encoding: .utf8) {
                  let preferenceKey = "KeyboardShortcuts_\(KeyboardShortcuts.Name.popup.rawValue)"
                  UserDefaults.standard.set(hotKeyString, forKey: preferenceKey)
                }
              }
            }
          }
        }
      }

      UserDefaults.standard.migrations["2020-06-19-use-keyboardshortcuts"] = true
    }

    if UserDefaults.standard.migrations["2020-09-01-ignore-keeweb"] != true {
      UserDefaults.standard.ignoredPasteboardTypes =
        UserDefaults.standard.ignoredPasteboardTypes.union(["net.antelle.keeweb"])

      UserDefaults.standard.migrations["2020-09-01-ignore-keeweb"] = true
    }

    if UserDefaults.standard.migrations["2021-02-20-allow-to-customize-supported-types"] != true {
      UserDefaults.standard.enabledPasteboardTypes = [
        .fileURL, .png, .string, .tiff
      ]

      UserDefaults.standard.migrations["2021-02-20-allow-to-customize-supported-types"] = true
    }

    if UserDefaults.standard.migrations["2021-06-28-add-title-to-history-item"] != true {
      for item in HistoryItem.all {
        item.title = item.generateTitle(item.getContents())
      }
      CoreDataManager.shared.saveContext()

      UserDefaults.standard.migrations["2021-06-28-add-title-to-history-item"] = true
    }

    if UserDefaults.standard.migrations["2021-10-16-remove-dynamic-pasteboard-types"] != true {
      let fetchRequest = NSFetchRequest<HistoryItemContent>(entityName: "HistoryItemContent")
      fetchRequest.predicate = NSPredicate(format: "type BEGINSWITH 'dyn.'")
      do {
        try CoreDataManager.shared.viewContext
          .fetch(fetchRequest)
          .forEach(CoreDataManager.shared.viewContext.delete(_:))
        CoreDataManager.shared.saveContext()
      } catch {
        // Something went wrong, but it's no big deal.
      }

      CoreDataManager.shared.saveContext()

      UserDefaults.standard.migrations["2021-10-16-remove-dynamic-pasteboard-types"] = true
    }

    if UserDefaults.standard.migrations["2022-08-01-rename-suppress-clear-alert"] != true {
      if let suppressClearAlert = UserDefaults.standard.object(forKey: "supressClearAlert") as? Bool {
        UserDefaults.standard.suppressClearAlert = suppressClearAlert
        UserDefaults.standard.removeObject(forKey: "supressClearAlert")
      }

      UserDefaults.standard.migrations["2022-08-01-rename-suppress-clear-alert"] = true
    }

    if UserDefaults.standard.migrations["2022-11-14-add-html-rtf-to-supported-types"] != true {
      if UserDefaults.standard.enabledPasteboardTypes.contains(.string) {
        UserDefaults.standard.enabledPasteboardTypes =
          UserDefaults.standard.enabledPasteboardTypes.union([.html, .rtf])
      }

      UserDefaults.standard.migrations["2022-11-14-add-html-rtf-to-supported-types"] = true
    }

    if UserDefaults.standard.migrations["2023-01-22-add-regexp-search-mode"] != true {
      if UserDefaults.standard.bool(forKey: "fuzzySearch") {
        UserDefaults.standard.searchMode = Search.Mode.fuzzy.rawValue
      }
      UserDefaults.standard.removeObject(forKey: "fuzzySearch")

      UserDefaults.standard.migrations["2023-01-22-add-regexp-search-mode"] = true
    }
    #endif
  }

  private func clearOrphanRecords() {
    let fetchRequest = NSFetchRequest<HistoryItemContent>(entityName: "HistoryItemContent")
    fetchRequest.predicate = NSPredicate(format: "item == nil")
    do {
      try CoreDataManager.shared.viewContext
        .fetch(fetchRequest)
        .forEach(CoreDataManager.shared.viewContext.delete(_:))
      CoreDataManager.shared.saveContext()
    } catch {
      // Something went wrong, but it's no big deal.
    }
  }
  // swiftlint:enable cyclomatic_complexity
  // swiftlint:enable function_body_length
}
