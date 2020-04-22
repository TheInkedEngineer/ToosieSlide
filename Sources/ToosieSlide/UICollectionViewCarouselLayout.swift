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
    
    return CGPoint(x: distanceToMove, y: 0)
  }
}
