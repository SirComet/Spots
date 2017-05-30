import UIKit

public class DefaultItemViewPresenter: ViewPresenter, ItemConfigurable {
  /// An optional reference to the current item
  public var item: Item?

  lazy var view: DefaultItemView = DefaultItemView()

  public var presentedView: View {
    return view
  }

  /// Configure cell with Item struct
  ///
  /// - parameter item: The Item struct that is used for configuring the view.
  public func configure(with item: Item) {
    if let action = item.action, !action.isEmpty {
      view.accessoryType = .disclosureIndicator
    } else {
      view.accessoryType = .none
    }

    view.detailTextLabel?.text = item.subtitle
    view.textLabel?.text = item.title
    view.imageView?.image = UIImage(named: item.image)

    self.item = item

    assignAccesibilityAttributes(from: item)
  }

  open func computeSize(for item: Item) -> CGSize {
    let itemHeight = item.size.height > 0.0 ? item.size.height : Configuration.defaultViewSize.height

    return .init(
      width: Configuration.defaultViewSize.width,
      height: itemHeight
    )
  }

  private func assignAccesibilityAttributes(from item: Item) {
    guard view.isAccessibilityElement else {
      return
    }

    view.accessibilityIdentifier = item.title
    view.accessibilityLabel = item.title + "." + item.subtitle
  }
}

/// A boilerplate cell for ListComponent
///
/// Accessibility: This class is per default an accessibility element, and gets its attributes
/// from any `Item` that it's configured with. You can override this behavior at any point, and
/// disable accessibility by setting `isAccessibilityElement = false` on the cell.
open class DefaultItemView: UITableViewCell {
  /// Initializes a table cell with a style and a reuse identifier and returns it to the caller.
  ///
  /// - parameter style:           A constant indicating a cell style. See UITableViewCellStyle for descriptions of these constants.
  /// - parameter reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.
  ///
  /// - returns: An initialized UITableViewCell object or nil if the object could not be created.
  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    isAccessibilityElement = true
  }

  /// Init with coder
  ///
  /// - parameter aDecoder: An NSCoder
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
