//
//  AloeScrollView.swift
//
//  Created by Sereivoan Yong on 12/16/20.
//

import UIKit

/// A simple class for laying out a collection of views with a convenient API, while leveraging the
/// power of Auto Layout.
open class AloeScrollView: UIScrollView {

  private var axisObservation: NSKeyValueObservation?

  lazy private var stackViewDimensionConstraint: NSLayoutConstraint = createStackViewDimensionConstraint()

  /// Edge constraints (top, left, bottom, right) of `stackView`
  lazy open var stackViewConstraints: [NSLayoutConstraint] = [
    stackView.topAnchor.constraint(equalTo: topAnchor),
    stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
    bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
    trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
  ]

  /// `arrangedSubviews` must not be modified directly.
  public let stackView = UIStackView()

  /// The direction that rows are laid out in the stack view.
  ///
  /// If `axis` is `.vertical`, rows will be laid out in a vertical column. If `axis` is
  /// `.horizontal`, rows will be laid out horizontally, side-by-side.
  ///
  /// This property also controls the direction of scrolling in the stack view. If `axis` is
  /// `.vertical`, the stack view will scroll vertically, and rows will stretch to fill the width of
  /// the stack view. If `axis` is `.horizontal`, the stack view will scroll horizontally, and rows
  /// will be sized to fill the height of the stack view.
  ///
  /// The default value is `.vertical`.
  open var axis: NSLayoutConstraint.Axis {
    get { return stackView.axis }
    set { stackView.axis = newValue }
  }

  open var cellPreservesSuperviewLayoutMargins: Bool = false

  // MARK: Styling Rows

  /// The background color of rows in the stack view.
  ///
  /// This background color will be used for any new row that is added to the stack view.
  /// The default color is `.clear`.
  open var cellBackgroundColor: UIColor = .clear

  /// The highlight background color of rows in the stack view.
  ///
  /// This highlight background color will be used for any new row that is added to the stack view.
  /// The default color is #D9D9D9 (RGB 217, 217, 217).
  open var cellHighlightColor: UIColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1)

  /// Specifies the default inset of rows.
  ///
  /// This inset will be used for any new row that is added to the stack view.
  ///
  /// You can use this property to add space between a row and the left and right edges of the stack
  /// view and the rows above and below it. Positive inset values move the row inward and away
  /// from the stack view edges and away from rows above and below.
  ///
  /// The default inset is 15pt on each side and 12pt on the top and bottom.
  open var cellLayoutMargins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
  
  // MARK: Lifecycle
  
  public override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    addSubview(stackView)

    NSLayoutConstraint.activate(stackViewConstraints)
    stackViewDimensionConstraint.isActive = true

    axisObservation = stackView.observe(\.axis) { [weak self] stackView, _ in
      guard let self = self else { return }
      self.stackViewDimensionConstraint.isActive = false
      self.stackViewDimensionConstraint = self.createStackViewDimensionConstraint()
      self.stackViewDimensionConstraint.isActive = true
    }
  }
  
  // MARK: Adding and Removing Rows
  
  /// Adds a row to the end of the stack view.
  ///
  /// If `animated` is `true`, the insertion is animated.
  open func addRow(_ row: UIView, animated: Bool = false) {
    insertCellForRow(row, at: stackView.arrangedSubviews.count, animated: animated)
  }
  
  /// Adds multiple rows to the end of the stack view.
  ///
  /// If `animated` is `true`, the insertions are animated.
  open func addRows(_ rows: [UIView], animated: Bool = false) {
    for row in rows {
      addRow(row, animated: animated)
    }
  }
  
  /// Adds a row to the beginning of the stack view.
  ///
  /// If `animated` is `true`, the insertion is animated.
  open func prependRow(_ row: UIView, animated: Bool = false) {
    insertCellForRow(row, at: 0, animated: animated)
  }
  
  /// Adds multiple rows to the beginning of the stack view.
  ///
  /// If `animated` is `true`, the insertions are animated.
  open func prependRows(_ rows: [UIView], animated: Bool = false) {
    for row in rows.reversed() {
      prependRow(row, animated: animated)
    }
  }
  
  /// Inserts a row above the specified row in the stack view.
  ///
  /// If `animated` is `true`, the insertion is animated.
  open func insertRow(_ row: UIView, before beforeRow: UIView, animated: Bool = false) {
    guard
      let cell = beforeRow.superview as? AloeScrollViewCell,
      let index = stackView.arrangedSubviews.firstIndex(of: cell)
    else { return }
    
    insertCellForRow(row, at: index, animated: animated)
  }
  
  /// Inserts multiple rows above the specified row in the stack view.
  ///
  /// If `animated` is `true`, the insertions are animated.
  open func insertRows(_ rows: [UIView], before beforeRow: UIView, animated: Bool = false) {
    for row in rows {
      insertRow(row, before: beforeRow, animated: animated)
    }
  }
  
  /// Inserts a row below the specified row in the stack view.
  ///
  /// If `animated` is `true`, the insertion is animated.
  open func insertRow(_ row: UIView, after afterRow: UIView, animated: Bool = false) {
    guard
      let cell = afterRow.superview as? AloeScrollViewCell,
      let index = stackView.arrangedSubviews.firstIndex(of: cell)
    else { return }

    insertCellForRow(row, at: index + 1, animated: animated)
  }
  
  /// Inserts multiple rows below the specified row in the stack view.
  ///
  /// If `animated` is `true`, the insertions are animated.
  open func insertRows(_ rows: [UIView], after afterRow: UIView, animated: Bool = false) {
    var afterRow = afterRow
    for row in rows {
      insertRow(row, after: afterRow, animated: animated)
      afterRow = row
    }
  }
  
  /// Removes the given row from the stack view.
  ///
  /// If `animated` is `true`, the removal is animated.
  open func removeRow(_ row: UIView, animated: Bool = false) {
    if let cell = row.superview as? AloeScrollViewCell {
      removeCell(cell, animated: animated)
    }
  }
  
  /// Removes the given rows from the stack view.
  ///
  /// If `animated` is `true`, the removals are animated.
  open func removeRows(_ rows: [UIView], animated: Bool = false) {
    for row in rows {
      removeRow(row, animated: animated)
    }
  }
  
  /// Removes all the rows in the stack view.
  ///
  /// If `animated` is `true`, the removals are animated.
  open func removeAllRows(animated: Bool = false) {
    for cell in stackView.arrangedSubviews as! [AloeScrollViewCell] {
      removeRow(cell.contentView, animated: animated)
    }
  }

  // MARK: Accessing Rows
  
  /// The first row in the stack view.
  ///
  /// This property is nil if there are no rows in the stack view.
  open var firstRow: UIView? {
    return (stackView.arrangedSubviews.first as? AloeScrollViewCell)?.contentView
  }
  
  /// The last row in the stack view.
  ///
  /// This property is nil if there are no rows in the stack view.
  open var lastRow: UIView? {
    return (stackView.arrangedSubviews.last as? AloeScrollViewCell)?.contentView
  }
  
  /// Returns an array containing of all the rows in the stack view.
  ///
  /// The rows in the returned array are in the order they appear visually in the stack view.
  open func rows() -> [UIView] {
    return (stackView.arrangedSubviews as! [AloeScrollViewCell]).map { $0.contentView }
  }
  
  /// Returns `true` if the given row is present in the stack view, `false` otherwise.
  open func containsRow(_ row: UIView) -> Bool {
    guard let cell = row.superview as? AloeScrollViewCell else { return false }

    return stackView.arrangedSubviews.contains(cell)
  }
  
  // MARK: Hiding and Showing Rows
  
  /// Hides the given row, making it invisible.
  ///
  /// If `animated` is `true`, the change is animated.
  open func hideRow(_ row: UIView, animated: Bool = false) {
    setRowHidden(row, isHidden: true, animated: animated)
  }
  
  /// Hides the given rows, making them invisible.
  ///
  /// If `animated` is `true`, the changes are animated.
  open func hideRows(_ rows: [UIView], animated: Bool = false) {
    for row in rows {
      hideRow(row, animated: animated)
    }
  }
  
  /// Shows the given row, making it visible.
  ///
  /// If `animated` is `true`, the change is animated.
  open func showRow(_ row: UIView, animated: Bool = false) {
    setRowHidden(row, isHidden: false, animated: animated)
  }
  
  /// Shows the given rows, making them visible.
  ///
  /// If `animated` is `true`, the changes are animated.
  open func showRows(_ rows: [UIView], animated: Bool = false) {
    for row in rows {
      showRow(row, animated: animated)
    }
  }
  
  /// Hides the given row if `isHidden` is `true`, or shows the given row if `isHidden` is `false`.
  ///
  /// If `animated` is `true`, the change is animated.
  open func setRowHidden(_ row: UIView, isHidden: Bool, animated: Bool = false) {
    guard let cell = row.superview as? AloeScrollViewCell, cell.isHidden != isHidden else { return }
    
    if animated {
      UIView.animate(withDuration: 0.3) {
        cell.isHidden = isHidden
        cell.layoutIfNeeded()
      }
    } else {
      cell.isHidden = isHidden
    }
  }
  
  /// Hides the given rows if `isHidden` is `true`, or shows the given rows if `isHidden` is
  /// `false`.
  ///
  /// If `animated` is `true`, the change are animated.
  open func setRowsHidden(_ rows: [UIView], isHidden: Bool, animated: Bool = false) {
    for row in rows {
      setRowHidden(row, isHidden: isHidden, animated: animated)
    }
  }
  
  /// Returns `true` if the given row is hidden, `false` otherwise.
  open func isRowHidden(_ row: UIView) -> Bool {
    return (row.superview as? AloeScrollViewCell)?.isHidden ?? false
  }
  
  // MARK: Handling User Interaction
  
  /// Sets a closure that will be called when the given row in the stack view is tapped by the user.
  ///
  /// The handler will be passed the row.
  open func setTapHandlerForRow<Row: UIView>(_ row: Row, handler: ((Row) -> Void)?) {
    guard let cell = row.superview as? AloeScrollViewCell else { return }
    
    if let handler = handler {
      cell.tapHandler = { contentView in
        guard let contentView = contentView as? Row else { return }
        handler(contentView)
      }
    } else {
      cell.tapHandler = nil
    }
  }

  // MARK: Extending AloeScrollView
  
  /// Returns the `AloeScrollViewCell` to be used for the given row.
  ///
  /// An instance of `AloeScrollViewCell` wraps every row in the stack view.
  ///
  /// Subclasses can override this method to return a custom `AloeScrollViewCell` subclass, for example
  /// to add custom behavior or functionality that is not provided by default.
  ///
  /// If you customize the values of some properties of `AloeScrollViewCell` in this method, these values
  /// may be overwritten by default values after the cell is returned. To customize the values of
  /// properties of the cell, override `configureCell(_:)` and perform the customization there,
  /// rather than on the cell returned from this method.
  open func createCellForRow(_ row: UIView) -> AloeScrollViewCell {
    return AloeScrollViewCell(contentView: row)
  }
  
  /// Allows subclasses to configure the properties of the given `AloeScrollViewCell`.
  ///
  /// This method is called for newly created cells after the default values of any properties of
  /// the cell have been set by the superclass.
  ///
  /// The default implementation of this method does nothing.
  open func configureCell(_ cell: AloeScrollViewCell) { }

  open func cellForRow(_ row: UIView) -> AloeScrollViewCell? {
    return row.superview as? AloeScrollViewCell
  }

  // MARK: Modifying the Scroll Position

  /// Scrolls the given row onto screen so that it is fully visible.
  ///
  /// If `animated` is `true`, the scroll is animated. If the row is already fully visible, this
  /// method does nothing.
  open func scrollRowToVisible(_ row: UIView, animated: Bool = true) {
    guard let superview = row.superview else { return }
    scrollRectToVisible(convert(row.frame, from: superview), animated: animated)
  }
  
  // MARK: - Private
  
  private func createStackViewDimensionConstraint() -> NSLayoutConstraint {
    switch stackView.axis {
    case .horizontal:
      return stackView.heightAnchor.constraint(equalTo: heightAnchor)
    case .vertical:
      return stackView.widthAnchor.constraint(equalTo: widthAnchor)
    @unknown default:
      return stackView.heightAnchor.constraint(equalTo: heightAnchor)
    }
  }
  
  private func insertCellForRow(_ contentView: UIView, at index: Int, animated: Bool) {
    let cellToRemove = containsRow(contentView) ? contentView.superview : nil
    
    let cell = createCellForRow(contentView)
    setValueIfNotEqual(cellLayoutMargins, for: \.layoutMargins, on: cell)
    setValueIfNotEqual(cellPreservesSuperviewLayoutMargins, for: \.preservesSuperviewLayoutMargins, on: cell)
    setValueIfNotEqual(cellBackgroundColor, for: \.unhighlightColor, on: cell)
    setValueIfNotEqual(cellHighlightColor, for: \.highlightColor, on: cell)
    configureCell(cell)
    stackView.insertArrangedSubview(cell, at: index)
    
    if let cellToRemove = cellToRemove as? AloeScrollViewCell {
      removeCell(cellToRemove, animated: false)
    }
    
    if animated {
      cell.alpha = 0
      layoutIfNeeded()
      UIView.animate(withDuration: 0.3) {
        cell.alpha = 1
      }
    }
  }
  
  private func removeCell(_ cell: AloeScrollViewCell, animated: Bool) {
    let completion: (Bool) -> Void = { _ in
      cell.removeFromSuperview()
    }
    
    if animated {
      UIView.animate(
        withDuration: 0.3,
        animations: {
          cell.isHidden = true
        },
        completion: completion)
    } else {
      completion(true)
    }
  }
}

@usableFromInline
func setValueIfNotEqual<Root, Value>(_ value: Value, for keyPath: ReferenceWritableKeyPath<Root, Value>, on object: Root) where Value: Equatable {
  if object[keyPath: keyPath] != value {
    object[keyPath: keyPath] = value
  }
}
