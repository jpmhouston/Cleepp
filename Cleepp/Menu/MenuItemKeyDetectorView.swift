//
//  MenuEventMonitorView.swift
//  Cleepp
//
//  Created by Pierre Houston on 2025-05-28.
//  Copyright © 2025 Bananameter Labs. All rights reserved.
//

import AppKit
import Sauce

extension Key {
  func matchesKeyEquivalent(_ keyEquivalent: String) -> Bool {
    // unfortunately `Key(character: "\u{8},...) ≠ .delete` and similar for other keys that
    // correspond to ascii control characters, so also need work-around for those cases
    // https://github.com/Clipy/Sauce/issues/32#issuecomment-2926255530
    switch self {
    case .delete: keyEquivalent == "\u{8}"
    case .tab: keyEquivalent == "\u{9}"
    case .escape: keyEquivalent == "\u{27}"
    case .space: keyEquivalent == " "
    case .forwardDelete: keyEquivalent == "\u{127}"
    default: false
    }
  }
}

class MenuItemKeyDetectorView : NSView {
  
  @IBOutlet var menuItem: NSMenuItem?
  
  private lazy var eventMonitor = RunLoopLocalEventMonitor(runLoopMode: .eventTracking) { event in
    if self.processInterceptedEvent(event) {
      return nil
    } else {
      return event
    }
  }
  
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    
    guard menuItem != nil else {
      // need to do nothing if the outlet isn't connected to a menu item, TODO: fatal error here?
      return
    }
    
    if window != nil {
      eventMonitor.start()
    } else if NSApp.menuWindow?.isVisible == false {
      // don't stop if the view has simply scrolled out of view in the menu
      eventMonitor.stop()
    }
  }
  
  private func processInterceptedEvent(_ event: NSEvent) -> Bool {
    guard let menuItem = menuItem, menuItem.isEnabled, let target = menuItem.target, let action = menuItem.action else {
      return false
    }
    
    if event.type != NSEvent.EventType.keyDown {
      return false
    }
    
    let eventModifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask).subtracting(.capsLock)
    guard let key = Sauce.shared.key(for: Int(event.keyCode)) else {
      return false
    }
    
    guard eventModifiers == menuItem.keyEquivalentModifierMask &&
        (key == menuItem.key || key.matchesKeyEquivalent(menuItem.keyEquivalent)) else {
      return false
    }
    
    DispatchQueue.main.async {
      _ = target.perform(action, with: self)
    }
    return true
  }
  
}
