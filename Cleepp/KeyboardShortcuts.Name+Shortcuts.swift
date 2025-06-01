import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  // start queue mode
  static let queueStart = Self("queueStart", default: nil)
  // special copy that starts queue mode first if not yet in queue mode
  static let queuedCopy = Self("queuedCopy", default: Shortcut(.c, modifiers: [.command, .control]))
  // special paste that advances to next in the queue if in queue mode
  static let queuedPaste = Self("queuedPaste", default: Shortcut(.v, modifiers: [.command, .control]))
}
