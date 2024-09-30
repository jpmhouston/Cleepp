//
//  Cleepp+Actions.swift
//  Cleepp
//
//  Created by Pierre Houston on 2024-03-20.
//  Copyright © 2024 Bananameter Labs. All rights reserved.
//

import AppKit
import Settings
import os.log

// TODO: make methods return error instead of bool

// TODO: put these somewhere else
func nop() { }
func dontWarnUnused(_ x: Any) { }

extension Cleepp {
  
  private var copyTimeoutSeconds: Double { 1.0 }
  private var standardPasteDelaySeconds: Double { 0.33333 }
  private var standardPasteDelay: DispatchTimeInterval { .milliseconds(Int(standardPasteDelaySeconds * 1000)) }
  private var extraPasteDelaySeconds: Double { 0.66666 }
  private var extraPasteDelay: DispatchTimeInterval { .milliseconds(Int(extraPasteDelaySeconds * 1000)) }
  private var pasteMultipleDelay: DispatchTimeInterval { .milliseconds(Int(extraPasteDelaySeconds * 1000)) }
  
  private var extraDelayOnQueuedPaste: Bool {
    #if arch(x86_64) || arch(i386)
    true
    #else
    false
    #endif
    // or maybe is not processor, but instead the latest OS fixes need for longer delay
    //if #unavailable(macOS 14) { true } else { false }
  }
  
  private func accessibilityCheck(interactive: Bool = true) -> Bool {
    #if DEBUG
    if AppDelegate.shouldFakeAppInteraction {
      return true // clipboard short-circuits the frontmost app TODO: eventually use a mock clipboard obj
    }
    #endif
    return interactive ? Accessibility.check() : Accessibility.allowed
  }
  
  private func restoreClipboardMonitoring() {
    if UserDefaults.standard.ignoreEvents {
      UserDefaults.standard.ignoreEvents = false
      UserDefaults.standard.ignoreOnlyNextEvent = false
    }
  }
  
  @IBAction
  func startQueueMode(_ sender: AnyObject) {
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    startQueueMode(interactive: true)
  }
  
  @discardableResult
  func startQueueMode(interactive: Bool = false) -> Bool {
    guard !Self.busy else {
      return false
    }
    guard accessibilityCheck() else {
      return false
    }
    guard !queue.isOn else {
      return false
    }
    
    restoreClipboardMonitoring()
    
    queue.on()
    updateStatusMenuIcon()
    updateMenuTitle()
    
    return true
  }
  
  @IBAction
  func cancelQueueMode(_ sender: AnyObject) {
    cancelQueueMode()
  }
  
  @discardableResult
  func cancelQueueMode() -> Bool {
    guard !Self.busy else {
      return false
    }
    
    queue.off()
    updateStatusMenuIcon()
    updateMenuTitle()
    menu.updateHeadOfQueue(index: nil)
    
    return true
  }
  
  func resetQueue() {
    queue.off()
    updateStatusMenuIcon()
    updateMenuTitle()
  }
  
  @IBAction
  func queuedCopy(_ sender: AnyObject) {
    // handler for the menu item
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    queuedCopy(interactive: true)
  }
  
  func queuedCopy() {
    // handler for the global keyboard shortcut
    queuedCopy(interactive: true)
  }
  
  @discardableResult
  func queuedCopy(interactive: Bool) -> Bool {
    // handler for the global keyboard shortcut and menu item via funcs above, and the intent
    guard !Self.busy else {
      return false
    }
    guard accessibilityCheck(interactive: interactive) else {
      return false
    }
    
    restoreClipboardMonitoring()
    
    if !queue.isOn {
      queue.on(allowStayingOnAfterDecrementToZero: false)
    }
    
    Self.busy = true
    
    // make the frontmost application perform a copy
    // let clipboard object detect this normally and invoke incrementQueue
    clipboard.invokeApplicationCopy() { [weak self] in
      guard let self = self else { return }
      
      // allow copy again if no copy deletected after this duration
      self.runOnCopyTimeoutTimer(afterTimeout: self.copyTimeoutSeconds) { [weak self] in
        guard self != nil else { return }
        
        Self.busy = false
      }
    }
    
    return true
  }
  
  func clipboardChanged(_ item: HistoryItem) {
    // cancel timeout if its timer is active and clear the busy flag controlled by the timer
    let withinTimeout = copyTimeoutTimer != nil
    if withinTimeout {
      cancelCopyTimeoutTimer()
      // perhaps assert Self.busy here?
      
      // i tried having this in a defer, awkward, should be the same to do it early
      Self.busy = false
    }
    
    if queue.isOn {
      do {
        try queue.add(item)
      } catch {
        return
      }
      
      menu.add(item) // or different queue-aware add function
      menu.updateHeadOfQueue(index: queue.headIndex) // or don't pass in index, inject queue into menu when its created?
      
      updateStatusMenuIcon(.increment)
      updateMenuTitle()
    } else {
      history.add(item)
      menu.add(item)
    }
  }
  
  @IBAction
  func queuedPaste(_ sender: AnyObject) {
    // handler for the global keyboard shortcut
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    queuedPaste(interactive: true)
  }
  
  func queuedPaste() {
    // handler for the global keyboard shortcut
    queuedPaste(interactive: true)
  }
  
  @discardableResult
  func queuedPaste(interactive: Bool) -> Bool {
    // handler for the global keyboard shortcut and menu item via funcs above, and the intent
    guard !Self.busy else {
      return false
    }
    
    guard !queue.empty else {
      return false
    }
    guard accessibilityCheck(interactive: interactive) else {
      return false
    }
    
    Self.busy = true
    
    do {
      try queue.putNextOnClipboard()
    } catch {
      Self.busy = false
      return false
    }
    
    let decrementQueueDelay = extraDelayOnQueuedPaste ? extraPasteDelay : standardPasteDelay
    
    // make the frontmost application perform a paste, then advance the queue after our
    // heuristic delay, keep the app from doing anything else until them
    invokeApplicationPaste(plusDelay: decrementQueueDelay) { [weak self] in
      guard let self = self else { return }
      
      do {
        try self.queue.remove()
      } catch { }
      
      menu.updateHeadOfQueue(index: self.queue.headIndex)
      updateStatusMenuIcon(.decrement)
      updateMenuTitle()
      
      Self.busy = false
      
      #if FOR_APP_STORE
        // TODO: enable reviews when this target is truly building for the app store
//      if !queue.isOn {
//        AppStoreReview.ask(after: 20)
//      }
      #endif
    }
    
    return true
  }
  
  func invokeApplicationPaste(plusDelay delay: DispatchTimeInterval, then completion: @escaping () -> Void) {
    clipboard.invokeApplicationPaste() {
      // paste is always followed by a delay to give the frontmost app time to start performing the paste
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        completion()
      }
    }
  }
  
  @IBAction
  func queuedPasteMultiple(_ sender: AnyObject) {
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    guard !Self.busy else {
      return
    }
    
    guard !queue.empty else {
      return
    }
    guard accessibilityCheck() else {
      return
    }
    
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    withNumberToPasteAlert() { number in
      // Tricky! See MenuController for how `withFocus` normally uses NSApp.hide
      // after making the menu open, except when returnFocusToPreviousApp false.
      // `withNumberToPasteAlert` must set that flag to false to run the alert
      // and so at this moment our app has not been hidden.
      // `invokeApplicationPaste` internally does a dispatch async around
      // controlling the frontmost app so it does so only after the `withFocus`
      // closure does NSApp.hide as it exits.
      // Because this runs after withFocus has already exited without doing
      // NSApp.hide (since withNumberToPasteAlert sets returnFocusToPreviousApp
      // to false), and we want to immediately control the app now, must do the
      // NSApp.hide ourselves here.
      NSApp.hide(self)
      
      self.queuedPasteMultiple(number, interactive: true)
    }
  }
  
  @IBAction
  func queuedPasteAll(_ sender: AnyObject) {
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    guard !Self.busy else {
      return
    }
    
    guard !queue.empty else {
      return
    }
    guard accessibilityCheck() else {
      return
    }
    
    queuedPasteMultiple(queue.size, interactive: true)
  }
  
  // TODO: add support for paste multiple from an intent
  
  @discardableResult
  private func queuedPasteMultiple(_ count: Int, interactive: Bool = true) -> Bool {
    guard count >= 1 && count <= queue.size else {
      return false
    }
    if count == 1 {
      return queuedPaste(interactive: interactive)
    } else {
      do {
        try queue.putNextOnClipboard()
      } catch {
        return false
      }
      
      Self.busy = true
      
      // menu icon will show this for the duration
      setStatusMenuIcon(to: .cleepMenuIconListMinus)
      
      queuedPasteMultipleIterator(count) { [weak self] in
        guard let self = self else { return }
        
        self.queue.finishBulkRemove()
        
        // final update to these and including icon not updated since the syaty
        self.updateStatusMenuIcon()
        self.updateMenuTitle()
        self.menu.updateHeadOfQueue(index: self.queue.headIndex)
        
        Self.busy = false
        
        #if FOR_APP_STORE
        // TODO: enable reviews when this target is truly building for the app store
//        if !queue.isOn && interactive {
//          AppStoreReview.ask(after: 20)
//        }
        #endif
      }
      
      return true
    }
  }
  
  private func queuedPasteMultipleIterator(_ count: Int, then completion: @escaping ()->Void) {
    guard count > 0, let index = queue.headIndex, index < history.count else {
      // don't expect to ever be called with count = 0, exit condition is below, before recursive call
      completion()
      return
    }
    
    nop() // TODO: remove once no longer need a breakpoint here
    
    // presume item to be pasted is already be on the clpiaboard, make the frontmost application
    // to perform a paste, then advance the queue after our long delay and either exit or recurse
    invokeApplicationPaste(plusDelay: self.pasteMultipleDelay) { [weak self] in
      guard let self = self else { return }
      
      do {
        try queue.bulkRemoveNext()
      } catch {
        completion()
        return
      }
      if queue.empty || count <= 1 {
        completion()
        return
      }
      
      updateMenuTitle()
      menu.updateHeadOfQueue(index: queue.headIndex)
      
      self.queuedPasteMultipleIterator(count - 1, then: completion)
    }
  }
  
  @IBAction
  func advanceReplay(_ sender: AnyObject) {
    guard !Self.busy else {
      return
    }
    
    guard !queue.empty else {
      return
    }
    
    do {
      try self.queue.remove()
    } catch {
      return
    }
    
    menu.updateHeadOfQueue(index: queue.headIndex)
    updateStatusMenuIcon(.decrement)
    updateMenuTitle()
  }
  
  @IBAction
  func replayFromHistory(_ sender: AnyObject) {
    menu.cancelTrackingWithoutAnimation() // do this before any alerts appear
    guard let item = (sender as? HistoryMenuItem)?.item,
          let index = history.all.firstIndex(of: item) else {
      return
    }
    replayFromHistory(atIndex: index, interactive: true)
  }
  
  @discardableResult
  func replayFromHistory(atIndex index: Int, interactive: Bool = false) -> Bool {
    guard Cleepp.allowReplayFromHistory else {
      return false
    }
    guard !Self.busy else {
      return false
    }
    guard accessibilityCheck() else {
      return false
    }
    
    queue.on(allowStayingOnAfterDecrementToZero: false)
    do {
      try queue.setHead(toIndex: index)
    } catch {
      queue.off()
      return false
    }
    
    updateStatusMenuIcon()
    updateMenuTitle()
    menu.updateHeadOfQueue(index: index)
    
    return true
  }
  
  @IBAction
  func copyFromHistory(_ sender: AnyObject) {
    guard !Self.busy else {
      return
    }
    
    guard let item = (sender as? HistoryMenuItem)?.item else {
      return
    }
    
    clipboard.copy(item)
  }
  
  @IBAction
  func deleteHistoryItem(_ sender: AnyObject) {
    guard let item = (sender as? HistoryMenuItem)?.item, let index = history.all.firstIndex(of: item) else {
      return
    }
    
    deleteHistoryItem(index)
  }
  
  @discardableResult
  func deleteHistoryItem(_ index: Int) -> Bool {
    guard !Self.busy else {
      return false
    }
    guard index < history.count else {
      return false
    }
    
    menu.delete(position: index)
    
    fixQueueAfterDeletingItem(atIndex: index)
    
    return true
  }
  
  @IBAction
  func deleteHighlightedHistoryItem(_ sender: AnyObject) {
    guard !Self.busy else {
      return
    }
    
    guard let deletedIndex = menu.deleteHighlightedItem() else {
      return
    }
    
    fixQueueAfterDeletingItem(atIndex: deletedIndex)
  }
  
  func fixQueueAfterDeletingItem(atIndex index: Int) {
    if queue.isOn {
      do {
        try queue.remove(atIndex: index)
      } catch {
        os_log(.default, "fixing queue after deleting item failed, %@", error.localizedDescription)
        queue.off()
      }
      
      updateStatusMenuIcon(.decrement)
      updateMenuTitle()
      // menu updates the head of queue item itself when deleting
    }
  }
  
  @IBAction
  func clear(_ sender: AnyObject) {
    guard !Self.busy else {
      return
    }
    
    clearUnpinned() // for us this is the same as clearAll
  }
  
  @IBAction
  func undoLastCopy(_ sender: AnyObject) {
    guard !Self.busy else {
      return
    }
    
    guard let removeItem = history.first else {
      return
    }
    
    history.remove(removeItem)
    menu.delete(position: 0)
    
    if !queue.empty {
      fixQueueAfterDeletingItem(atIndex: 0)
    }
  }
  
  @IBAction
  func showAbout(_ sender: AnyObject) {
    Self.returnFocusToPreviousApp = false
    about.openAbout()
    Self.returnFocusToPreviousApp = true
  }
  
  @IBAction
  func showIntro(_ sender: AnyObject) {
    Self.returnFocusToPreviousApp = false
    introWindowController.openIntro(with: self)
    Self.returnFocusToPreviousApp = true
  }
  
  @IBAction
  func showIntroAtPermissionPage(_ sender: AnyObject) {
    Self.returnFocusToPreviousApp = false
    introWindowController.openIntro(atPage: .checkAuth, with: self)
    Self.returnFocusToPreviousApp = true
  }
  
  func showLicenses() {
    Self.returnFocusToPreviousApp = false
    licensesWindowController.openLicenses()
    Self.returnFocusToPreviousApp = true
  }
  
  @IBAction
  func showSettings(_ sender: AnyObject) {
    showSettings()
  }
  
  func showSettings(selectingPane pane: Settings.PaneIdentifier? = nil) {
    Self.returnFocusToPreviousApp = false
    settingsWindowController.show(pane: pane)
    settingsWindowController.window?.orderFrontRegardless()
    Self.returnFocusToPreviousApp = true
  }
  
  @IBAction
  func quit(_ sender: AnyObject) {
    NSApp.terminate(sender)
  }
  
  // MARK: -
  
  private func runOnCopyTimeoutTimer(afterTimeout timeout: Double, _ action: @escaping () -> Void) {
    if copyTimeoutTimer != nil {
      cancelCopyTimeoutTimer()
    }
    copyTimeoutTimer = DispatchSource.scheduledTimerForRunningOnMainQueue(afterDelay: timeout) { [weak self] in
      self?.copyTimeoutTimer = nil // doing this before calling closure supports closure itself calling runOnCopyTimeoutTimer, fwiw
      action()
    }
  }
  
  private func cancelCopyTimeoutTimer() {
    copyTimeoutTimer?.cancel()
    copyTimeoutTimer = nil
  }
  
}
