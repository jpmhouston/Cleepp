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
  @IBOutlet weak var searchModeButton: NSPopUpButton!
  @IBOutlet weak var promoteExtrasCheckbox: NSButton!
  @IBOutlet weak var promoteExtrasExpiresCheckbox: NSButton!
  @IBOutlet weak var checkForUpdatesItemsRow: NSGridRow!
  @IBOutlet weak var searchModeSeparatorRow: NSGridRow!
  @IBOutlet weak var searchModeItemsRow: NSGridRow!
  @IBOutlet weak var promoteExtrasSeparatorRow: NSGridRow!
  @IBOutlet weak var promoteExtrasItemsRow: NSGridRow!

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
    
    func addSubviewWithManualLayout(_ par: NSView, _ sub: NSView) {
      par.translatesAutoresizingMaskIntoConstraints = false
      sub.translatesAutoresizingMaskIntoConstraints = false
      par.addSubview(sub)
      par.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[s]|", metrics: nil, views: ["s": sub]))
      par.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[s]|", metrics: nil, views: ["s": sub]))
    }
    // using the above func instead of addSubview fixed layout issues with the KeyboardShortcuts.RecorderCocoa views
    addSubviewWithManualLayout(startHotkeyContainerView, startHotkeyRecorder)
    addSubviewWithManualLayout(copyHotkeyContainerView, copyHotkeyRecorder)
    addSubviewWithManualLayout(pasteHotkeyContainerView, pasteHotkeyRecorder)
    
    #if !ALLOW_SPARKLE_UPDATES
    hideSparkleUpdateRows()
    #endif
    
    #if FOR_APP_STORE
    if #unavailable(macOS 14) { // badged menu items first available in macOS 14
      hidePromoteExtrasRow()
    }
    #else
    hidePromoteExtrasRow()
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
    #if FOR_APP_STORE
    populatePromoteExtrasOptions()
    #endif
    showSearchOptionRows(Cleepp.allowHistorySearch)
  }
  
  public func promoteExtrasStateChanged() {
    #if FOR_APP_STORE
    populatePromoteExtrasOptions()
    #endif
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

  #if FOR_APP_STORE
  private func populatePromoteExtrasOptions() {
    promoteExtrasCheckbox.state = UserDefaults.standard.promoteExtras ? .on : .off
    promoteExtrasExpiresCheckbox.state = UserDefaults.standard.promoteExtrasExpires ? .on : .off
    promoteExtrasCheckbox.isEnabled = !Cleepp.hasBoughtExtras
    promoteExtrasExpiresCheckbox.isEnabled = !Cleepp.hasBoughtExtras && UserDefaults.standard.promoteExtras
  }
  
  private func updatePromoteExtrasExpirationOption() {
    promoteExtrasExpiresCheckbox.isEnabled = !Cleepp.hasBoughtExtras && UserDefaults.standard.promoteExtras
  }
  
  private func updatePromoteExtrasExpirationTimer() {
    guard let cleepp = (NSApp.delegate as? AppDelegate)?.maccy else {
      return
    }
    cleepp.setPromoteExtrasExpirationTimer(on: UserDefaults.standard.promoteExtras && UserDefaults.standard.promoteExtrasExpires)
  }
  #endif
  
  @IBAction func promoteExtrasChanged(_ sender: NSButton) {
    #if FOR_APP_STORE
    UserDefaults.standard.promoteExtras = (sender.state == .on)
    // turning promotion itself off & on doesn't reset the expiration date
    // but keeps the same expiration as long as its still in the future
    updatePromoteExtrasExpirationOption()
    updatePromoteExtrasExpirationTimer()
    #endif
  }
  
  @IBAction func promoteExtrasExpiresChanged(_ sender: NSButton) {
    #if FOR_APP_STORE
    UserDefaults.standard.promoteExtrasExpires = (sender.state == .on)
    // turning expiration checkbox off and on does reset the expiration date
    UserDefaults.standard.promoteExtrasExpiration = nil
    updatePromoteExtrasExpirationTimer()
    #endif
  }
  
  private func showSearchOptionRows(_ show: Bool) {
    searchModeSeparatorRow.isHidden = !show
    searchModeItemsRow.isHidden = !show
  }
  
  private func hideSparkleUpdateRows() {
    checkForUpdatesItemsRow.isHidden = true
  }
  
  private func hidePromoteExtrasRow() {
    promoteExtrasSeparatorRow.isHidden = true
    promoteExtrasItemsRow.isHidden = true
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
