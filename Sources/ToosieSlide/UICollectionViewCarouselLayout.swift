//
//  Toosie Slide
//

import UIKit

/// A type alias to simulate the idea of a cell index.
public typealias CellIndex = Int

/// A Custom `UICollectionViewFlowLayout` that simulates a carousel. That is a paginated collection view, with the focused item only in the center of the collection.
/// In addition `UICollectionViewCarouselLayout` offers the possibility to resize the non focused cells and change their alpha while scrolling.
/// For the proper functioning of this flow layout, collection view's `decelerationRate` should be set to fast.
///
/// For the proper functioning of `UICollectionViewCarouselLayout` you are required to set the item size, either using the convenience `init(itemSize: CGSize)`
/// or by manually calling `layout.itemSize` and setting its value.
/// Using `func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize` will not work
/// Because a concrete fixed item size is needed to be able to calculate the various insets.
open class UICollectionViewCarouselLayout: UICollectionViewFlowLayout {
  
  // MARK: - Properties
  
  /// The lowest absolute velocity that should invoke a change of cells.
  /// If the absolute velocity of the swipe is lower than this variable, the central cell does not change.
  /// Defaults to `0.2`.
  public var lowestVelocitySensitivity: CGFloat = 0.2
  
  /// The cell currently being displayed for the user.
  public internal(set) var currentVisibleCellIndex: CellIndex = 0 {
    willSet {
      guard let collection = collectionView, newValue != currentVisibleCellIndex else { return }
      (collectionView?.delegate as? UICollectionViewDelegateCarouselLayout)?.collectionView(collection, willDisplayCellAt: newValue)
    }
  }
  
  /// The scale factor to apply to the focused cell' size. Defaults to `1.0`.
  /// The size of the item will be multiplied by this value, so a value lower than 1 will make it smaller, greater than 1 will make it bigger.
  public var focusedItemScaleFactor: CGFloat = 1 { didSet { invalidateLayout() } }
  
  /// The alpha value of the lone focused cell. This defaults to `1.0`.
  public var focusedItemAlphaValue: CGFloat = 1 { didSet { invalidateLayout() } }
  
  /// The scale factor to apply to the non focused cells' size. Defaults to `0.8`.
  /// The size of the item will be multiplied by this value, so a value lower than 1 will make it smaller, greater than 1 will make it bigger.
  public var nonFocusedItemsScaleFactor: CGFloat = 0.8 { didSet { invalidateLayout() } }
  
  /// The alpha value of the non focused cells. This defaults to `0.5`.
  public var nonFocusedItemsAlphaValue: CGFloat = 0.5 { didSet { invalidateLayout() } }
  
  /// The affine transform applied to focused items.
  private var focusedItemAffineTransform: CGAffineTransform {
    CGAffineTransform(scaleX: focusedItemScaleFactor, y: focusedItemScaleFactor)
  }
  
  /// The affine transform applied to unfocused items.
  private var nonFocusedItemAffineTransform: CGAffineTransform {
    CGAffineTransform(scaleX: nonFocusedItemsScaleFactor, y: nonFocusedItemsScaleFactor)
  }
  
  /// The current content offset of the visible cell from the section inset..
  public var currentOffset: CGFloat {
    CGFloat(currentVisibleCellIndex) * (itemSize.width + minimumLineSpacing)
  }
  
  /// The latest known collection view size, it is useful to understand when collection view size has changed
  /// to manually call `invalidateLayout()` since iOS won't call it when subclassing UICollectionView.
  private var latestKnownCollectionViewSize: CGSize?
  
  /// The space between the cell and the collection view horizontal edge. If no collection view is yet available, it just returns `.zero`.
  /// This is calculated and set as the inset of the collection view to ensure always a single row of cells that are always centered.
  private var horizontalSpacingFromCollectionViewEdge: CGFloat {
    guard let collectionView = collectionView, collectionView.bounds.width > 0 else { return .zero }
    return (collectionView.bounds.width - itemSize.width) / 2
  }
  
  /// The space between the cell and the collection view vertical edge. If no collection view is yet available, it just returns `.zero`.
  /// This is calculated and set as the inset of the collection view to ensure always a single row of cells that are always centered.
  private var verticalSpacingFromCollectionViewEdge: CGFloat {
    guard let collectionView = collectionView, collectionView.bounds.height > 0 else { return .zero }
    return (collectionView.bounds.height - itemSize.height) / 2
  }
  
  // MARK: - Overridden properties
  
  /// The `CGSize` of the single item inside the cell.
  /// It's value should be less or equal to `UIScreen.main.bounds.size.width`.
  open override var itemSize: CGSize {
    get { super.itemSize }
    set {
      guard newValue.width <= UIScreen.main.bounds.size.width else {
        fatalError("Item size width should not be larger than actual screen width.")
      }
      super.itemSize = newValue
      invalidateLayout()
    }
  }
  
  /// The `UICollectionView.ScrollDirection` of the collection.
  /// This value, defaults to `.horizontal` and should **NOT** be changed.
  open override var scrollDirection: UICollectionView.ScrollDirection {
    get { super.scrollDirection }
    set {
      guard newValue == .horizontal else { fatalError("CarouselLayout supports only horizontal layout.") }
      super.scrollDirection = newValue
    }
  }
  
  // MARK: - Init
  
  /// Initializes the flow layout with a `.horizontal` scroll direction.
  public override init() {
    super.init()
    scrollDirection = .horizontal
  }
  
  /// Initializes the flow layout with a `.horizontal` scroll direction, and sets the `itemSize` of the single element.
  public convenience init(itemSize: CGSize) {
    self.init()
    self.itemSize = itemSize
  }
  
  /// Initializes the flow layout with a `.horizontal` scroll direction using the `NSCoder`.
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    scrollDirection = .horizontal
  }
  
  // MARK: - Methods
  
  /// Updates collection view section insets with leading and trailing space.
  private func updateSectionInsets() {
    sectionInset = UIEdgeInsets(
      top: verticalSpacingFromCollectionViewEdge,
      left: horizontalSpacingFromCollectionViewEdge,
      bottom: verticalSpacingFromCollectionViewEdge,
      right: horizontalSpacingFromCollectionViewEdge
    )
  }
  
  // MARK: - Overridden Methods
  
  /// Invalidates the current layout and triggers a layout update.
  ///
  /// You can call this method at any time to update the layout information.
  /// This method invalidates the layout of the collection view itself and returns right away.
  /// Thus, you can call this method multiple times from the same block of code without triggering multiple layout updates.
  /// The actual layout update occurs during the next view layout update cycle.
  /// If you override this method, you must call super at some point in your implementation.
  open override func invalidateLayout() {
    super.invalidateLayout()
    updateSectionInsets()
  }
  
  /// Returns the layout attributes for all of the cells and views in the specified rectangle.
  ///
  /// Subclasses must override this method and use it to return layout information for all items whose view intersects the specified rectangle.
  /// Your implementation should return attributes for all visual elements, including cells, supplementary views, and decoration views.
  /// When creating the layout attributes, always create an attributes object that represents the correct element type (cell, supplementary, or decoration).
  /// The collection view differentiates between attributes for each type and uses that information to make decisions about which views to create and how to manage them.
  /// - Parameter rect: The rectangle (specified in the collection view’s coordinate system) containing the target views.
  /// - Returns: An array of UICollectionViewLayoutAttributes objects representing the layout information for the cells and views. The default implementation returns nil.
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    // unwrap super's attributes
    guard let superArray = super.layoutAttributesForElements(in: rect) else { return nil }
    // deep copy items. A shallow copy is not enough since it will lead to inconsistencies in the cache.
    guard let attributes = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return superArray }
    
    attributes.enumerated().forEach { index, element in
      // if first layout, apply focus attributes to first element.
      if element.indexPath.row == currentVisibleCellIndex {
        attributes[index].transform = self.focusedItemAffineTransform
        attributes[index].alpha = focusedItemAlphaValue
        return
      }
      
      // set all non focused attributes, because when element is set to focused his attributes will be updated in
      // func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
      attributes[index].transform = self.nonFocusedItemAffineTransform
      attributes[index].alpha = nonFocusedItemsAlphaValue
    }
    
    // to make sure the current cell is always properly attributed.
    // in case at any point this is called
    // after func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
    resizeCellsIfNeeded()
    return attributes
  }
  
  /// Asks the layout object if the new bounds require a layout update.
  ///
  /// The default implementation of this method returns false.
  /// Subclasses can override it and return an appropriate value based on whether changes in the bounds of the collection view require changes to the layout of cells and supplementary views.
  /// If the bounds of the collection view change and this method returns true, the collection view invalidates the layout by calling the invalidateLayout(with:) method.
  /// - Parameter newBounds: The new bounds of the collection view.
  /// - Returns: true if the collection view requires a layout update or false if the layout does not need to change.
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    // Since `invalidateLayout()` is not called every time the collection view `.bounds` changes, just listen
    // and invalidate layout by caching the collection view size. `layoutAttributesForElements(in rect: CGRect)` is called
    // every time the collection view doesn't know/isn't "sure" about where to place cells. It is called upon rotation as well.
    if latestKnownCollectionViewSize != collectionView?.bounds.size {
      latestKnownCollectionViewSize = collectionView?.bounds.size
      return true
    }
    return false
  }
  
  /// Updates the current layout if collection view size have changed.
  ///
  /// This is needed, because for some weird iOS reason, when subclassing a `UICollectionView`,
  /// `func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool` is never called.
  /// If this class is overridden, super should be called.
  open override func prepare() {
    if latestKnownCollectionViewSize != collectionView?.bounds.size {
      latestKnownCollectionViewSize = collectionView?.bounds.size
      invalidateLayout()
    }
  }
  
  /// Returns the point at which to stop scrolling.
  ///
  /// If you want the scrolling behaviour to snap to specific boundaries, you can override this method and use it to change the point at which to stop.
  /// For example, you might use this method to always stop scrolling on a boundary between items, as opposed to stopping in the middle of an item.
  /// If you override this method, you should call super which would return the expected point where to scroll to have the next centered cell.
  /// - Parameters:
  ///   - proposedContentOffset: The proposed point (in the collection view’s content view) at which to stop scrolling.
  ///   This is the value at which scrolling would naturally stop if no adjustments were made. The point reflects the upper-left corner of the visible content.
  ///   - velocity: The current scrolling velocity along both the horizontal and vertical axes. This value is measured in points per second.
  /// - Returns: The point where to stop in order to have the next cell centralised.
  open override func targetContentOffset(
    forProposedContentOffset proposedContentOffset: CGPoint,
    withScrollingVelocity velocity: CGPoint
  ) -> CGPoint {
    
    // check collection not empty and if fast enough to scroll
    guard
      let collectionView = collectionView,
      collectionView.numberOfItems(inSection: 0) > 0,
      abs(velocity.x) > lowestVelocitySensitivity
      
      else {
        return CGPoint(x: currentOffset, y: 0)
    }
    
    let futureCellIndex = velocity.x > 0 ?
      min(currentVisibleCellIndex + 1, collectionView.numberOfItems(inSection: 0) - 1) :
      max(0, currentVisibleCellIndex - 1)
    
    if let delegate = (collectionView.delegate as? UICollectionViewDelegateCarouselLayout) {
      // defaults to true, check if another implementation forces it to not show.
      guard delegate.collectionView(collectionView, shouldDisplayCellAt: futureCellIndex) else {
        return CGPoint(x: currentOffset, y: 0)
      }
    }
    
    // actual distance to scroll
    let distanceToMove = velocity.x > 0 ?
      currentOffset + itemSize.width + minimumLineSpacing :
      currentOffset - itemSize.width - minimumLineSpacing
    
    // update visible cell index
    currentVisibleCellIndex = futureCellIndex
    
    // invalidate layout to set new attributes.
    invalidateLayout()
    
    return CGPoint(x: distanceToMove, y: 0)
  }
}

internal extension UICollectionViewCarouselLayout {
  /// Resizes and animates the cells if any of `focusedItemScaleFactor`, `focusedItemAlphaValue`,
  /// `nonFocusedItemsScaleFactor`, `nonFocusedItemsAlphaValue`
  /// is different of 1, else returns.
  func resizeCellsIfNeeded() {
    guard
      let collectionView = collectionView,
        focusedItemScaleFactor != 1 ||
        focusedItemAlphaValue != 1 ||
        nonFocusedItemsScaleFactor != 1 ||
        nonFocusedItemsAlphaValue != 1
      else {
        return
    }
    
    collectionView.setNeedsLayout()
    UIView.animate(withDuration: 0.3) { [weak collectionView, weak self] in
      guard let self = self else { return }
      
      let previousCell = collectionView?.cellForItem(at: self.currentVisibleCellIndex - 1)
      let currentCell = collectionView?.cellForItem(at: self.currentVisibleCellIndex)
      let nextCell = collectionView?.cellForItem(at: self.currentVisibleCellIndex + 1)
      
      // resize
      previousCell?.transform = self.nonFocusedItemAffineTransform
      nextCell?.transform = self.nonFocusedItemAffineTransform
      currentCell?.transform = self.focusedItemAffineTransform
      
      // update alpha
      previousCell?.alpha = self.nonFocusedItemsAlphaValue
      currentCell?.alpha = self.focusedItemAlphaValue
      nextCell?.alpha = self.nonFocusedItemsAlphaValue
      
      collectionView?.layoutIfNeeded()
    }
  }
}
