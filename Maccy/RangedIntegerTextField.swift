//
//  RangedIntegerTextField.swift
//  ClipStack
//
//  Created by Pierre Houston on 2024-03-16.
//  Copyright © 2024 Bananameter Labs. All rights reserved.
//

import AppKit

class RangedIntegerTextField: NSTextField {
  
  typealias ChangeValidationAction = (Bool)->Void
  
  enum EitherIntRange {
    case open(Range<Int>)
    case closed(ClosedRange<Int>)
  }
  
  var allowedRange: EitherIntRange = .closed(0...10)
  var allowEmpty = false
  var validationAction: ChangeValidationAction?
  
  init(acceptingRange range: Range<Int>, permittingEmpty: Bool, frame: NSRect, validationAction action: ChangeValidationAction? = nil) {
    allowedRange = .open(range)
    allowEmpty = permittingEmpty
    validationAction = action
    super.init(frame: frame)
    formatter = NumberFormatter()
  }
  
  init(acceptingRange range: ClosedRange<Int>, permittingEmpty: Bool, frame: NSRect, validationAction action: ChangeValidationAction? = nil) {
    allowedRange = .closed(range)
    allowEmpty = permittingEmpty
    validationAction = action
    super.init(frame: frame)
    formatter = NumberFormatter()
  }
  
  init(permittingEmpty: Bool, frame: NSRect, validationAction action: ChangeValidationAction? = nil) {
    allowEmpty = permittingEmpty
    validationAction = action
    super.init(frame: frame)
    formatter = NumberFormatter()
  }
  
  override init(frame: NSRect) {
    super.init(frame: frame)
    formatter = NumberFormatter()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var isValid: Bool {
    if stringValue.isEmpty {
      return allowEmpty
    }
    guard let value = Int(stringValue) else {
      return false
    }
    switch allowedRange {
    case .open(let r):
      return r.contains(value)
    case .closed(let r):
      return r.contains(value)
    }
  }
  
  override func textDidChange(_ notification: Notification) {
    super.textDidChange(notification)
    validationAction?(isValid)
  }
  
  override func resignFirstResponder() -> Bool {
    return isValid
  }
  
}
