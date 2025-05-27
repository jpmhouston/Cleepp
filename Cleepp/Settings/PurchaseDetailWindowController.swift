//
//  PurchaseDetailWindowController.swift
//  Cleepp
//
//  Created by Pierre Houston on 2024-10-19.
//  Copyright © 2024 Bananameter Labs. All rights reserved.
//

import AppKit

class PurchaseDetailCellView: NSTableCellView {
  @IBOutlet var innerView: NSView!
  @IBOutlet var productDescription: NSTextField!
  @IBOutlet var notPurchasedLabel: NSTextField!
  @IBOutlet var alreadyPurchasedLabel: NSTextField!
  @IBOutlet var priceLabel: NSTextField!
  @IBOutlet var oneTimeLabel: NSTextField!
  @IBOutlet var monthlyLabel: NSTextField!
  @IBOutlet var yearlyLabel: NSTextField!
}

class PurchaseDetailWindowController: NSWindowController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
  
  @IBOutlet var tableView: NSTableView!
  @IBOutlet var buyButton: NSButton!
  @IBOutlet var userAgreementLinkLabel: NSTextField!
  //@IBOutlet var privacyPolicyLinkLabel: NSTextField!
  
  private var disabledBuyButtonTitle: String = ""
  private var templateBuyButtonTitle: String = ""
  
  var products: [Purchases.ProductDetail] = []
  var purchases: Set<Purchases.Item> = []
  var chosenProduct: Purchases.ProductDetail?
  
  class func createFromNib() -> Self {
    self.init(windowNibName: "PurchaseDetailWindow")
    // after using this the caller should then set products and purchases
    // i chose not to pass them in as arguments to have some symmetry with where the
    // caller needs to directly access chosenProduct after the window closes
  }
  
  override func windowDidLoad() {
    #if DEBUG
    if let product = products.first, product is Purchases.DummyProductDetail {
      templateBuyButtonTitle = "Test, won't charge $" // do not localize
    } else {
      templateBuyButtonTitle = buyButton.title
    }
    #else
    templateBuyButtonTitle = buyButton.title
    #endif
    disabledBuyButtonTitle = buyButton.alternateTitle
    buyButton.alternateTitle = ""
    
    let styled = NSMutableAttributedString(attributedString: userAgreementLinkLabel.attributedStringValue)
    let font = userAgreementLinkLabel.font ?? NSFont.labelFont(ofSize: NSFont.smallSystemFontSize)
    styled.applySimpleStyles(basedOnFont: font, withLink: Cleepp.appStoreUserAgreementURL)
    userAgreementLinkLabel.attributedStringValue = styled
    
    //styled = NSMutableAttributedString(attributedString: privacyPolicyLinkLabel.attributedStringValue)
    //styled.applySimpleStyles(basedOnFont: font, withLink: Cleepp.privacyPolicyURL)
    //privacyPolicyLinkLabel.attributedStringValue = styled
    
    if purchases.isEmpty, let defaultSelectRow = products.firstIndex(where: { $0.item == .bonus }) {
      let product = products[defaultSelectRow]
      tableView.selectRowIndexes(IndexSet(integer: defaultSelectRow), byExtendingSelection: false)
      setButtonEnabled(withPrice: product.localizedPrice)
    } else {
      setButtonDisabled()
    }
  }
  
  func setButtonDisabled() {
    buyButton.title = disabledBuyButtonTitle
    buyButton.isEnabled = false
  }
  
  func setButtonEnabled(withPrice price: String) {
    let title = templateBuyButtonTitle.replacingOccurrences(of: "$", with: price)
    buyButton.title = title
    buyButton.isEnabled = true
  }
  
  @IBAction func buy(_ sender: AnyObject) {
    guard let window = window else { return }
    
    let row = tableView.selectedRow
    guard row >= 0 && row < products.count else { return }
    chosenProduct = products[row]
    
    window.sheetParent?.endSheet(window, returnCode: .OK)
  }
  
  @IBAction func cancel(_ sender: AnyObject) {
    guard let window = window else { return }
    window.sheetParent?.endSheet(window, returnCode: .cancel)
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    products.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cellId = NSUserInterfaceItemIdentifier(rawValue: "ProductDetail")
    guard row >= 0 && row < products.count,
          let cellView = tableView.makeView(withIdentifier: cellId, owner: self) as? PurchaseDetailCellView else
    {
      return nil
    }
    //cellView.wantsLayer = true
    
    let product = products[row]
    cellView.productDescription.stringValue = product.localizedTitle
    cellView.priceLabel.stringValue = product.localizedPrice
    cellView.oneTimeLabel.isHidden = true
    cellView.monthlyLabel.isHidden = true
    cellView.yearlyLabel.isHidden = true
    
    switch product.subscription {
    case .not:
      cellView.oneTimeLabel.isHidden = false
    case .monthly:
      cellView.monthlyLabel.isHidden = false
    case .yearly:
      cellView.yearlyLabel.isHidden = false
    }
    
    let isPurchased = purchases.contains(product.item)
    cellView.notPurchasedLabel.isHidden = isPurchased
    cellView.alreadyPurchasedLabel.isHidden = !isPurchased
    
    cellView.showHighlightRing(row == tableView.selectedRow)
    
    return cellView
  }
  
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    guard row >= 0 && row < products.count else { return false }
    let product = products[row]
    return !purchases.contains(product.item)
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    if tableView.selectedRow == -1 {
      setButtonDisabled()
    }
    
    for row in 0 ..< products.count {
      guard let cellView = tableView.view(atColumn: 0, row: row, makeIfNecessary: true) as? PurchaseDetailCellView else {
        continue
      }
      
      if cellView.innerView.layer == nil {
        print("in tableView(_:shouldSelectRow:) innerView layer missing for row \(row)")
      }
      if row == tableView.selectedRow {
        cellView.showHighlightRing(true)
        setButtonEnabled(withPrice: cellView.priceLabel.stringValue)
      } else {
        cellView.showHighlightRing(false)
      }
    }
  }
  
}

extension PurchaseDetailCellView {
  func showHighlightRing(_ show: Bool) {
    if show {
      innerView.layer?.borderColor = NSColor.gray.cgColor
      innerView.layer?.borderWidth = 2.0
      innerView.layer?.cornerRadius = 4.0
    } else {
      innerView.layer?.borderWidth = 0
    }
  }
}
