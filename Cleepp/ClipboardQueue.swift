//
//  ClipboardQueue.swift
//  Cleepp
//
//  Created by Pierre Houston on 2024-05-20.
//  Copyright © 2024 Bananameter Labs. All rights reserved.
//

import AppKit

class ClipboardQueue {
  
  enum QueueError: Error {
    case logicError
    case noSuchItem
    case sizeExceedsHistory
  }
  
  enum Mode {
    case pasteboardHasLatest
    case pasteboardHasNext
    
    static var easy: Self { .pasteboardHasLatest }
    static var pro: Self { .pasteboardHasNext }
  }
  
  var isOn = false
  var turnOffWhenEmptied = false
  var size = 0 {
    didSet {
      history.maxItemsOverride = size
    }
  }
  
  var mode = Mode.easy {
    didSet {
      modeChanged()
    }
  }
  
  // probably should be protocols I can easily mock
  private let clipboard: Clipboard
  private let history: History
  
  init(clipboard c: Clipboard, history h: History) {
    clipboard = c
    history = h
  }
  
  // MARK: -
  
  var notEmpty: Bool {
    isOn && size > 0
  }
  
  var empty: Bool {
    !notEmpty
  }
  
  var headIndex: Int? {
    if empty {
      nil
    } else {
      size - 1
    }
  }
  
  func modeChanged() {
    // ?
  }
  
  // MARK: -
  
  func on(allowingDecrmentToZero allowEmpty: Bool = true) {
    isOn = true
    turnOffWhenEmptied = !allowEmpty
    size = 0
  }
  
  func off() {
    isOn = false
    size = 0
    
    // in case pasteboard was left set to an item deeper in the queue, reset to the latest item copied
    if mode == .pasteboardHasNext, let newestItem = history.first {
      clipboard.copy(newestItem)
    }
  }
  
  // MARK: -
  
  func add(_ item: HistoryItem) throws {
    if !isOn {
      on(allowingDecrmentToZero: false)
    }
    
    // currently item not treated differently by history when queue on vs off
    // but this may change in the future
    history.add(item)
    
    size += 1
    
    // we presume the item passed in has come from the clipboard,
    // if size of the queue is only 1, then we've already got the one we want for either mode
    if mode == .pasteboardHasNext && size > 1 {
      guard let headIndex = headIndex else {
        throw QueueError.logicError
      }
      guard headIndex < history.count else {
        throw QueueError.sizeExceedsHistory
      }
      
      // in the mode where always want next item to be pasted on the clipboard, presuming the item
      // passed in has come from the clipboard, replace it again with the next item to be pasted
      clipboard.copy(history.all[headIndex])
    }
  }
  
  func putNextOnClipboard() throws {
    if mode == .pasteboardHasNext {
      return
    }
    
    guard !empty, let headIndex = headIndex else {
      throw QueueError.noSuchItem
    }
    guard headIndex < history.count else {
      throw QueueError.sizeExceedsHistory
    }
    
    clipboard.copy(history.all[headIndex])
  }
  
  func remove(atIndex index: Int? = nil) throws {
    guard !empty, let priorHeadIndex = headIndex else {
      throw QueueError.noSuchItem
    }
    let index = index ?? priorHeadIndex
    guard index >= 0 && index <= priorHeadIndex else {
      throw QueueError.noSuchItem
    }
    
    size -= 1
    
    if empty {
      isOn = !turnOffWhenEmptied
      // leave clipboard alone, want it to be left at the latest item that's been copied, but even
      // in pasteboardHasNext mode, when queue size was 1 the next to paste was the latest copied
      
    } else if mode == .pasteboardHasLatest && index == 0 {
      // in the mode where always want the latest item that's been copied on the clipboard,
      // but latest item has been removed, use the new latest one in its place
      clipboard.copy(history.all.first)
      
    } else if mode == .pasteboardHasNext && index == priorHeadIndex {
      guard let newHeadIndex = headIndex else {
        throw QueueError.logicError // should have insted entered the `if empty` case above
      }
      guard newHeadIndex < history.count else {
        throw QueueError.sizeExceedsHistory
      }
      
      // in the mode where always want next item to be pasted on the clipboard, but the next one
      // has been removed, use the new next one in its place
      clipboard.copy(history.all[newHeadIndex])
    }
  }
  
  func setHead(toIndex index: Int) throws {
    if !isOn {
      on()
    }
    
    size = index + 1
    
    if mode == .pasteboardHasNext && size > 1 {
      guard index < history.count else {
        throw QueueError.sizeExceedsHistory
      }
      
      // in the mode where always want next item to be pasted on the clipboard
      clipboard.copy(history.all[index])
    }
  }
  
  // MARK: -
  
  func bulkRemoveNext() throws {
    guard !empty else {
      throw QueueError.noSuchItem
    }
    
    size -= 1
    
    if empty {
      isOn = !turnOffWhenEmptied
      // leave clipboard alone, want it to be left at the latest item copied which should
      // be the one from the previous iteration
    } else {
      guard let newHeadIndex = headIndex else {
        throw QueueError.logicError // should have insted entered the `if empty` case above
      }
      
      // when pasting multiple, want next item to be pasted on the clipboard
      clipboard.copy(history.all[newHeadIndex])
    }
  }
  
  func finishBulkRemove() {
    // if size of the queue is only 1, then we've already got the one we want for either mode
    if mode == .pasteboardHasLatest && size > 1 {
      // in the mode where always want the latest item that's been copied on the clipboard
      clipboard.copy(history.all.first)
    }
  }
  
}
