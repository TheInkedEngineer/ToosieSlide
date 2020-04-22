//
//  Toosie Slide
//

import UIKit

/// A type alias to simulate the idea of a cell index.
public typealias CellIndex = Int

open class UICollectionViewCarouselLayout: UICollectionViewFlowLayout {
  
  // MARK: - Properties
  
  /// The lowest absolute velocity that should invoke a change of cells.
  /// If the absolute velocity of the swipe is lower than this variable, the central cell does not change.
  public var lowestVelocitySensitivity: CGFloat = 0.2
  
  /// The cell currently being displayed for the user.
  public var currentVisibleCellIndex: CellIndex = 0 {
    willSet {
      guard let collection = collectionView, newValue != currentVisibleCellIndex else { return }
      (collectionView?.delegate as? UICollectionViewDelegateCarouselLayout)?.collectionView(collection, willDisplayCellAt: newValue)
    }
  }
  
  /// The current content offset of the visible cell from the section inset..
  public var currentOffset: CGFloat {
    CGFloat(currentVisibleCellIndex) * (itemSize.width + minimumLineSpacing)
  }
  
  /// The scale factor to apply to the visible cell's height. Defaults to 1.
  /// The height of the item will be multiplied by this value, so a value lower than 1 will make it smaller, greater than 1 will make it bigger.
  public var visibleItemHeightScaleFactor: CGFloat = 1 { didSet { invalidateLayout() } }
  
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
  
  /// The latest known CV size, it is useful to understand when collection view size has changed but no `invalidateLayout()` is automatically
  /// called by iOS.
  private var latestKnownCollectionViewSize: CGSize?
  
  /// A flag needed to force the resize of the first cell, if needed, when first layouting.
  private var isFirstLayout: Bool = true
  
  // MARK: - Overridden properties
  
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
  
  open override var scrollDirection: UICollectionView.ScrollDirection {
    get { super.scrollDirection }
    set {
      guard newValue == .horizontal else { fatalError("CarouselLayout supports only horizontal layout.") }
      super.scrollDirection = newValue
    }
  }
  
  // MARK: - Init
  
  public override init() {
    super.init()
    scrollDirection = .horizontal
    currentVisibleCellIndex = 0
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    scrollDirection = .horizontal
    currentVisibleCellIndex = 0
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
  
  open override func invalidateLayout() {
    super.invalidateLayout()
    updateSectionInsets()
  }
  
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    // unwrap super's attributes
    guard let superArray = super.layoutAttributesForElements(in: rect) else { return nil }
    
    // if this is not the first layout, return attributes as is
    guard isFirstLayout, superArray[0].indexPath.row == 0 else { return superArray }
    
    // make sure this part won't be triggered again.
    isFirstLayout = false
    
    // deep copy items. A shallow copy is not enough since it will lead to inconsistencies in the cache.
    guard let attributes = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
    
    // modify attributes of first cell. We know it's first cell from the guard.
    attributes[0].bounds.size.height = self.itemSize.height * self.visibleItemHeightScaleFactor
    
    return attributes
  }
  
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    /// Since `invalidateLayout()` is not called every time the collection view `.bounds` changes, just listen
    /// and invalidate layout by caching the collection view size. `layoutAttributesForElements(in rect: CGRect)` is called
    /// every time the collection view doesn't know/isn't "sure" about where to place cells. It is called upon rotation as well.
    if latestKnownCollectionViewSize != collectionView?.bounds.size {
      latestKnownCollectionViewSize = collectionView?.bounds.size
      return true
    }
    return false
  }
  
  open override func targetContentOffset(
    forProposedContentOffset proposedContentOffset: CGPoint,
    withScrollingVelocity velocity: CGPoint
  ) -> CGPoint {
    // check collection not empty and if fast enough to scroll
    guard let collectionView = collectionView, collectionView.numberOfItems(inSection: 0) > 0, abs(velocity.x) > lowestVelocitySensitivity else {
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
    
    resizeCellsIfNeeded()
    
    return CGPoint(x: distanceToMove, y: 0)
  }
}

internal extension UICollectionViewCarouselLayout {
  /// Resizes and animates the cells according to `visibleItemWidthScaleFactor` and `visibleItemHeightScaleFactor`.
  /// If both variables are equal to 1, nothing will happen.
  func resizeCellsIfNeeded() {
    guard let collectionView = collectionView, (visibleItemHeightScaleFactor != 1 || nonFocusedItemsScaleFactor != 1) else {
      return
    }
    
    let previousCell = collectionView.cellForItem(at: currentVisibleCellIndex - 1)
    let currentCell = collectionView.cellForItem(at: currentVisibleCellIndex)
    let nextCell = collectionView.cellForItem(at: currentVisibleCellIndex + 1)
    
    collectionView.setNeedsLayout()
    UIView.animate(withDuration: 0.3) { [weak collectionView, weak self] in
      guard let self = self else { return }
      
      previousCell?.bounds.size.height = self.itemSize.height * self.nonFocusedItemsScaleFactor
      currentCell?.bounds.size.height = self.itemSize.height * self.visibleItemHeightScaleFactor
      nextCell?.bounds.size.height = self.itemSize.height * self.nonFocusedItemsScaleFactor
      
      previousCell?.alpha = 0.2
      currentCell?.alpha = 1
      nextCell?.alpha = 0.2
      
      collectionView?.layoutIfNeeded()
    }
  }
}
