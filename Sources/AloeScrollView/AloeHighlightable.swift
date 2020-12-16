//
//  AloeHighlightable.swift
//
//  Created by Sereivoan Yong on 12/16/20.
//

import UIKit

/// Indicates that a row in an `AloeScrollView` should be highlighted when the user touches it.
///
/// Rows that are added to an `AloeScrollView` can conform to this protocol to have their
/// background color automatically change to a highlighted color (or some other custom behavior defined by the row) when the user is pressing down on
/// them.
public protocol AloeHighlightable: AnyObject {

  /// Checked when the user touches down on a row to determine if the row should be highlighted.
  ///
  /// The default implementation of this method always returns `true`.
  var isHighlightable: Bool { get }

  /// Called when the highlighted state of the row changes.
  /// Override this method to provide custom highlighting behavior for the row.
  ///
  /// The default implementation of this method changes the background color of the row to the `rowHighlightColor`.
  func setIsHighlighted(_ isHighlighted: Bool)
}

extension AloeHighlightable where Self: UIView {

  public var isHighlightable: Bool {
    return true
  }

  public func setIsHighlighted(_ isHighlighted: Bool) {
    guard let cell = superview as? AloeScrollViewCell else { return }
    cell.backgroundColor = isHighlighted ? cell.highlightColor : cell.unhighlightColor
  }
}
