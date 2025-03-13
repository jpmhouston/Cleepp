import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  // define these merely so code referring to them need not change
  static let popup = Name("popup")
  static let pin = Name("pin")
  
  // this still used by the keyhandler for now to get the key and modifiers from, must keep in sync with the item menu :(
  static let delete = Name("delete", default: Shortcut(.delete, modifiers: [.command]))
  
  // start queue mode
  static let queueStart = Name("queueStart", default: nil)
  // special copy that starts queue mode first if not yet in queue mode
  static let queuedCopy = Name("queuedCopy", default: Shortcut(.c, modifiers: [.command, .control]))
  // special paste that advances to next in the queue if in queue mode
  static let queuedPaste = Name("queuedPaste", default: Shortcut(.v, modifiers: [.command, .control]))
}
