import Foundation

#if os(OSX)
  import Cocoa
#else
  import CoreGraphics
#endif

public protocol ViewPresenter {
  var presentedView: View { get }
}

public class NibPresenter: ViewPresenter {
  public let nib: Nib
  public let presentedView: View

  init(nib: Nib) {
    self.nib = nib
    #if os(OSX)
      var views: NSArray?
      if nib.instantiate(withOwner: nil, topLevelObjects: &views!) {
        self.presentedView = views?.filter({ $0 is NSTableRowView }).first as? View ?? View()
      }
    #else
      self.presentedView = nib.instantiate(withOwner: nil, options: nil).first as? View ?? View()
    #endif
  }
}

/// A registry that is used internally when resolving kind to the corresponding component.
public struct Registry {

  /// A Key-value dictionary of registred types
  var storage = [String: ViewPresenter]()

  /// The default item for the registry
  var defaultItem: ViewPresenter? {
    didSet {
      storage[defaultIdentifier] = defaultItem
    }
  }

  /// A composite item
  var composite: ViewPresenter? {
    didSet {
      storage[CompositeComponent.identifier] = composite
    }
  }

  /// The default identifier for the registry
  var defaultIdentifier: String {
    guard defaultItem != nil else {
      return ""
    }
    return "default"
  }

  /// A subscripting method for getting a value from storage using a StringConvertible key
  ///
  /// - parameter key: A StringConvertable identifier
  ///
  /// - returns: An optional Nib
  public subscript(key: StringConvertible) -> ViewPresenter? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }

  // MARK: - Template

  /// A cache that stores instances of created views
  fileprivate var cache: NSCache = NSCache<NSString, View>()

  /**
   Empty the current view cache
   */
  func purge() {
    cache.removeAllObjects()
  }

  /**
   Create a view for corresponding identifier

   - parameter identifier: A reusable identifier for the view
   - returns: A tuple with an optional registry type and view
   */
  func make(_ identifier: String, parentFrame: CGRect = CGRect.zero, useCache: Bool = false) -> (type: RegistryType?, view: View?)? {
    guard let item = storage[identifier] else { return nil }

    let registryType: RegistryType
    var view: View? = nil

    switch item {
    case let presenter as NibPresenter:
      registryType = .nib
      let cacheIdentifier: String = "\(registryType.rawValue)-\(identifier)"
      if let view = cache.object(forKey: cacheIdentifier as NSString) {
        return (type: registryType, view: view)
      }
      view = presenter.presentedView
    default:
      registryType = .regular

      if useCache {
        let cacheIdentifier: String = "\(registryType.rawValue)-\(identifier)"
        if let view = cache.object(forKey: cacheIdentifier as NSString) {
          (view as? ItemConfigurable)?.prepareForReuse()
          return (type: registryType, view: view)
        }
      }

      view = item.presentedView
      view?.frame = parentFrame
    }

    if let view = view, useCache {
      let cacheIdentifier: String = "\(registryType.rawValue)-\(identifier)"
      cache.setObject(view, forKey: cacheIdentifier as NSString)
    }

    return (type: registryType, view: view)
  }
}
