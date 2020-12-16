//
//  AloeScrollViewCell.swift
//
//  Created by Sereivoan Yong on 12/16/20.
//

import UIKit

/// A view that wraps every row in a stack view.
open class AloeScrollViewCell: UIView {
  
  private var tapGestureRecognizer: UITapGestureRecognizer!

  var unhighlightColor: UIColor? {
    didSet {
      if !isHighlighted {
        backgroundColor = unhighlightColor
      }
    }
  }

  var highlightColor: UIColor? {
    didSet {
      if isHighlighted {
        backgroundColor = highlightColor
      }
    }
  }

  // MARK: Public

  public let contentView: UIView

  open var accessoryView: UIView? {
    didSet {
      guard accessoryView != oldValue else {
        return
      }
      oldValue?.removeFromSuperview()
      if let accessoryView = accessoryView {
        accessoryView.setContentHuggingPriority(.required, for: .horizontal)
        accessoryView.setContentCompressionResistancePriority(.required, for: .horizontal)
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryView)

        contentViewConstraints[3].isActive = false
        contentViewConstraints[3] = accessoryView.leftAnchor.constraint(equalTo: contentView.rightAnchor, constant: 8)

        NSLayoutConstraint.activate([
          contentViewConstraints[3],
          accessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
          layoutMarginsGuide.rightAnchor.constraint(equalTo: accessoryView.rightAnchor),
        ])
      } else {
        contentViewConstraints[3].isActive = false
        contentViewConstraints[3] = layoutMarginsGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        contentViewConstraints[3].isActive = true
      }
    }
  }

  open private(set) var isHighlighted: Bool = false

  /// Edge constraints (top, left, bottom, right) of `contentView`
  open private(set) var contentViewConstraints: [NSLayoutConstraint]!
  
  // MARK: Lifecycle
  
  public init(contentView: UIView) {
    self.contentView = contentView
    super.init(frame: .zero)

    clipsToBounds = true
    if #available(iOS 11.0, *) {
      insetsLayoutMarginsFromSafeArea = false
    }
    translatesAutoresizingMaskIntoConstraints = false
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentView)

    contentViewConstraints = [
      contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      layoutMarginsGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      layoutMarginsGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ]

    contentViewConstraints[2].priority = .required - 1
    NSLayoutConstraint.activate(contentViewConstraints)
    
    if contentView is AloeTappable {
      tapGestureRecognizer = UITapGestureRecognizer()
      tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
      tapGestureRecognizer.delegate = self
      addGestureRecognizer(tapGestureRecognizer)
    }
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIResponder
  
  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard contentView.isUserInteractionEnabled else { return }
    
    if let contentView = contentView as? AloeHighlightable, contentView.isHighlightable {
      isHighlighted = true
      contentView.setIsHighlighted(true)
    }
  }
  
  open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    guard contentView.isUserInteractionEnabled, let touch = touches.first else { return }

    if let contentView = contentView as? AloeHighlightable, contentView.isHighlightable {
      let location = touch.location(in: self)
      let isPointInside = point(inside: location, with: event)
      isHighlighted = isPointInside
      contentView.setIsHighlighted(isPointInside)
    }
  }
  
  open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    guard contentView.isUserInteractionEnabled else { return }
    
    if let contentView = contentView as? AloeHighlightable, contentView.isHighlightable {
      isHighlighted = false
      contentView.setIsHighlighted(false)
    }
  }
  
  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    guard contentView.isUserInteractionEnabled else { return }
    
    if let contentView = contentView as? AloeHighlightable, contentView.isHighlightable {
      isHighlighted = false
      contentView.setIsHighlighted(false)
    }
  }
  
  // MARK: Internal
  
  var tapHandler: ((UIView) -> Void)? {
    didSet {
      tapGestureRecognizer.isEnabled = tapHandler != nil
    }
  }
  
  // MARK: Private
  
  @objc private func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
    guard contentView.isUserInteractionEnabled else { return }
    (contentView as? AloeTappable)?.didTapView()
    tapHandler?(contentView)
  }
}

extension AloeScrollViewCell: UIGestureRecognizerDelegate {
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    guard let view = gestureRecognizer.view else { return false }
    
    let location = touch.location(in: view)
    var hitView = view.hitTest(location, with: nil)
    
    // Traverse the chain of superviews looking for any UIControls.
    while hitView != view && hitView != nil {
      if hitView is UIControl {
        // Ensure UIControls get the touches instead of the tap gesture.
        return false
      }
      hitView = hitView?.superview
    }
    
    return true
  }
}
