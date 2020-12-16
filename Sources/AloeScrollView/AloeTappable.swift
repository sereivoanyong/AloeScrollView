//
//  AloeTappable.swift
//
//  Created by Sereivoan Yong on 12/16/20.
//

/// Notifies a row in an `AloeScrollView` when it receives a user tap.
///
/// Rows that are added to an `AloeScrollView` can conform to this protocol to be notified when a
/// user taps on the row. This notification happens regardless of whether the row has a tap handler
/// set for it or not.
///
/// This notification can be used to implement default behavior in a view that should always happen
/// when that view is tapped.
public protocol AloeTappable: AnyObject {
  
  /// Called when the row is tapped by the user.
  func didTapView()
}
