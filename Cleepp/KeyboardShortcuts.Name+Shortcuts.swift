import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  // define these merely so code referring to them need not change
  static let popup = Self("popup")
  static let pin = Self("pin")
  
  // this still used by the keyhandler for now to get the key and modifiers from, must keep in sync with the item menu :(
  static let delete = Self("delete", default: Shortcut(.delete, modifiers: [.command]))
  
  // start queue mode
  static let queueStart = Self("queueStart", default: nil)
  // special copy that starts queue mode first if not yet in queue mode
  static let queuedCopy = Self("queuedCopy", default: Shortcut(.c, modifiers: [.command, .control]))
  // special paste that advances to next in the queue if in queue mode
  static let queuedPaste = Self("queuedPaste", default: Shortcut(.v, modifiers: [.command, .control]))
}
