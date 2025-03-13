import Cocoa
import KeyboardShortcuts
import Settings
#if ALLOW_SPARKLE_UPDATES
import Sparkle
#endif
#if canImport(ServiceManagement)
import ServiceManagement
#endif

class GeneralSettingsViewController: NSViewController, SettingsPane {
  public let paneIdentifier = Settings.PaneIdentifier.general
  public let paneTitle = NSLocalizedString("preferences_general", comment: "")
  public let toolbarItemIcon = NSImage(named: .gearshape)!

  override var nibName: NSNib.Name? { "GeneralSettingsViewController" }

  private let startHotkeyRecorder = KeyboardShortcuts.RecorderCocoa(for: .queueStart)
  private let copyHotkeyRecorder = KeyboardShortcuts.RecorderCocoa(for: .queuedCopy)
  private let pasteHotkeyRecorder = KeyboardShortcuts.RecorderCocoa(for: .queuedPaste)

  #if ALLOW_SPARKLE_UPDATES
  private var sparkleUpdater: SPUUpdater
  #endif
  
  private lazy var loginItemsURL = URL(
    string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
  )
  
  @IBOutlet weak var startHotkeyContainerView: NSView!
  @IBOutlet weak var copyHotkeyContainerView: NSView!
  @IBOutlet weak var pasteHotkeyContainerView: NSView!
  @IBOutlet weak var launchAtLoginButton: NSButton!
  @IBOutlet weak var launchAtLoginRow: NSGridRow!
  @IBOutlet weak var openLoginItemsPanelButton: NSButton!
  @IBOutlet weak var openLoginItemsPanelRow: NSGridRow!
  @IBOutlet weak var automaticUpdatesButton: NSButton!
  @IBOutlet weak var searchModeSeparator: NSView!
  @IBOutlet weak var searchModeLabel: NSTextField!
  @IBOutlet weak var searchModeButton: NSPopUpButton!
  @IBOutlet weak var checkForUpdatesOptionRow: NSGridRow!
  @IBOutlet weak var checkForUpdatesButtonRow: NSGridRow!
  
  #if ALLOW_SPARKLE_UPDATES
  init(updater: SPUUpdater) {
    sparkleUpdater = updater
    super.init(nibName: nil, bundle: nil)
  }
  
  private init() {
    fatalError("init(updater:) must be used instead of init()")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  #endif
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startHotkeyContainerView.addSubview(startHotkeyRecorder)
    copyHotkeyContainerView.addSubview(copyHotkeyRecorder)
    pasteHotkeyContainerView.addSubview(pasteHotkeyRecorder)
    
    #if !ALLOW_SPARKLE_UPDATES
    hideSparkleUpdateRows()
    #endif
    
    if #available(macOS 13.0, *) {
      showLaunchAtLoginRow()
    } else {
      showOpenLoginItemsPanelRow()
    }
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    populateLaunchAtLogin()
    populateSparkleAutomaticUpdates()
    populateSearchMode()
    showSearchOption(Cleepp.allowHistorySearch)
  }

  @IBAction func sparkleAutomaticUpdatesChanged(_ sender: NSButton) {
    #if ALLOW_SPARKLE_UPDATES
    sparkleUpdater.automaticallyChecksForUpdates = (sender.state == .on)
    #endif
  }
  
  private func populateSparkleAutomaticUpdates() {
    #if ALLOW_SPARKLE_UPDATES
    let automatic = sparkleUpdater.automaticallyChecksForUpdates
    automaticUpdatesButton.state = automatic ? .on : .off
    #endif
  }
  
  @IBAction func sparkleUpdateCheck(_ sender: NSButton) {
    #if ALLOW_SPARKLE_UPDATES
    sparkleUpdater.checkForUpdates()
    #endif
  }
  
  @IBAction func launchAtLoginChanged(_ sender: NSButton) {
    guard #available(macOS 13.0, *) else {
      return
    }
    if sender.state == .on {
      do {
        if SMAppService.mainApp.status == .enabled {
          try? SMAppService.mainApp.unregister()
        }
        try SMAppService.mainApp.register()
      } catch {
        sender.state = .off
      }
      
    } else {
      do {
        try SMAppService.mainApp.unregister()
      } catch {
        sender.state = .on
      }
    }
  }
  
  @IBAction func openLoginItemsPanel(_ sender: NSButton) {
    guard let url = loginItemsURL else {
      return
    }
    NSWorkspace.shared.open(url)
  }
  
  @IBAction func searchModeChanged(_ sender: NSPopUpButton) {
    switch sender.selectedTag() {
    case 3:
      UserDefaults.standard.searchMode = Search.Mode.mixed.rawValue
    case 2:
      UserDefaults.standard.searchMode = Search.Mode.regexp.rawValue
    case 1:
      UserDefaults.standard.searchMode = Search.Mode.fuzzy.rawValue
    default:
      UserDefaults.standard.searchMode = Search.Mode.exact.rawValue
    }
  }

  private func populateLaunchAtLogin() {
    guard #available(macOS 13.0, *) else {
      return
    }
    launchAtLoginButton.state = SMAppService.mainApp.status == .enabled ? .on : .off
  }

  private func populateSearchMode() {
    switch Search.Mode(rawValue: UserDefaults.standard.searchMode) {
    case .mixed:
      searchModeButton.selectItem(withTag: 3)
    case .regexp:
      searchModeButton.selectItem(withTag: 2)
    case .fuzzy:
      searchModeButton.selectItem(withTag: 1)
    default:
      searchModeButton.selectItem(withTag: 0)
    }
  }

  private func showSearchOption(_ show: Bool) {
    searchModeSeparator.isHidden = !show
    searchModeLabel.isHidden = !show
    searchModeButton.isHidden = !show
  }

  private func hideSparkleUpdateRows() {
    checkForUpdatesOptionRow.isHidden = true
    checkForUpdatesButtonRow.isHidden = true
  }
  
  private func showLaunchAtLoginRow() {
    launchAtLoginRow.isHidden = false
    openLoginItemsPanelRow.isHidden = true
  }
  
  private func showOpenLoginItemsPanelRow() {
    launchAtLoginRow.isHidden = true
    openLoginItemsPanelRow.isHidden = false
  }
  
}
