import AppKit

class History {
  #if CLEEPP
  var maxItemsOverride = 0
  private var sortBy = "lastCopiedAt"
  #else
  private var sortBy: String { UserDefaults.standard.sortBy }
  #endif

  var all: [HistoryItem] {
    #if CLEEPP
    let sorter = Sorter(by: sortBy)
    var items = sorter.sort(HistoryItem.all)
    
    // trim results and the database based on size setting, but also if queueing then include all those
    let maxItems = max(UserDefaults.standard.size, UserDefaults.standard.maxMenuItems, CleeppMenu.minNumMenuItems, maxItemsOverride)
    while items.count > maxItems {
      remove(items.removeLast())
    }
    
    return items
    
    #else
    let sorter = Sorter(by: sortBy)
    var unpinned = sorter.sort(HistoryItem.unpinned)
    while unpinned.count > UserDefaults.standard.size {
      remove(unpinned.removeLast())
    }

    return sorter.sort(HistoryItem.all)
    #endif
  }

  var first: HistoryItem? {
    let sorter = Sorter(by: sortBy)
    return sorter.first(HistoryItem.all)
  }

  var count: Int {
    HistoryItem.count
  }

  private var sessionLog: [Int: HistoryItem] = [:]

  init() {
    UserDefaults.standard.register(defaults: [UserDefaults.Keys.size: UserDefaults.Values.size])
    if ProcessInfo.processInfo.arguments.contains("ui-testing") {
      clear()
    }
  }

  func add(_ item: HistoryItem) {
    if let existingHistoryItem = findSimilarItem(item) {
      if isModified(item) == nil {
        item.contents = existingHistoryItem.contents
      }
      item.firstCopiedAt = existingHistoryItem.firstCopiedAt
      item.numberOfCopies += existingHistoryItem.numberOfCopies
      item.pin = existingHistoryItem.pin
      item.title = existingHistoryItem.title
      if !item.fromMaccy {
        item.application = existingHistoryItem.application
      }
      remove(existingHistoryItem)
    } else {
      #if !CLEEPP
      Notifier.notify(body: item.title, sound: .write)
      #endif
    }

    sessionLog[Clipboard.shared.changeCount] = item
    CoreDataManager.shared.saveContext()
  }

  func update(_ item: HistoryItem?) {
    CoreDataManager.shared.saveContext()
  }

  func remove(_ item: HistoryItem?) {
    guard let item else { return }

    item.getContents().forEach(CoreDataManager.shared.viewContext.delete(_:))
    CoreDataManager.shared.viewContext.delete(item)
  }

  func clearUnpinned() {
    all.filter({ $0.pin == nil }).forEach(remove(_:))
  }

  func clear() {
    all.forEach(remove(_:))
  }

  private func findSimilarItem(_ item: HistoryItem) -> HistoryItem? {
    let duplicates = all.filter({ $0 == item || $0.supersedes(item) })
    if duplicates.count > 1 {
      return duplicates.first(where: { $0.objectID != item.objectID })
    } else {
      return isModified(item)
    }
  }

  private func isModified(_ item: HistoryItem) -> HistoryItem? {
    if let modified = item.modified, sessionLog.keys.contains(modified) {
      return sessionLog[modified]
    }

    return nil
  }
}
