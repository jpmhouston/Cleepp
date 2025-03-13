//
//  GlobalHotKeys.swift
//  Cleepp
//
//  Created by Pierre Houston on 2024-03-21.
//  Portions Copyright © 2024 Bananameter Labs. All rights reserved.
//
//  Based on GlobalHotKey from Maccy which is
//  Copyright © 2024 Alexey Rodionov. All rights reserved.
//

import AppKit
import KeyboardShortcuts
import Sauce

class GlobalStartHotKey {
  typealias Handler = () -> Void

  static public var key: Key? {
    guard let key = KeyboardShortcuts.Shortcut(name: .queueStart)?.key else {
      return nil
    }
    return Sauce.shared.key(for: key.rawValue)
  }
  static public var modifierFlags: NSEvent.ModifierFlags? { KeyboardShortcuts.Shortcut(name: .queueStart)?.modifiers }

  private var handler: Handler

  init(_ handler: @escaping Handler) {
    self.handler = handler
    KeyboardShortcuts.onKeyDown(for: .queueStart, action: handler)
  }
}

class GlobalCopyHotKey {
  typealias Handler = () -> Void

  static public var key: Key? {
    guard let key = KeyboardShortcuts.Shortcut(name: .queuedCopy)?.key else {
      return nil
    }
    return Sauce.shared.key(for: key.rawValue)
  }
  static public var modifierFlags: NSEvent.ModifierFlags? { KeyboardShortcuts.Shortcut(name: .queuedCopy)?.modifiers }

  private var handler: Handler

  init(_ handler: @escaping Handler) {
    self.handler = handler
    KeyboardShortcuts.onKeyDown(for: .queuedCopy, action: handler)
  }
}

class GlobalPasteHotKey {
  typealias Handler = () -> Void

  static public var key: Key? {
    guard let key = KeyboardShortcuts.Shortcut(name: .queuedPaste)?.key else {
      return nil
    }
    return Sauce.shared.key(for: key.rawValue)
  }
  static public var modifierFlags: NSEvent.ModifierFlags? { KeyboardShortcuts.Shortcut(name: .queuedPaste)?.modifiers }

  private var handler: Handler

  init(_ handler: @escaping Handler) {
    self.handler = handler
    KeyboardShortcuts.onKeyDown(for: .queuedPaste, action: handler)
  }
}
