//
//  Toosie Slide
//

import UIKit

open class UICollectionViewCarouselLayout: UICollectionViewFlowLayout {
  
  // MARK: - Properties
  
  /// The cell currently being displayed for the user.
  public var currentVisibleCell = 0
  
  /// The lowest absolute velocity that should invoke a change of cells.
  /// If the absolute velocity of the swipe is lower than this variable, the central cell does not change.
  public var lowestVelocitySensitivity: CGFloat = 0.2
  
  /// The space between the cell and the collection view edge. If no collection view is yet available, it just returns `.zero`.
  public var spaceFromCollectionViewEdge: CGFloat {
    guard let collectionView = collectionView, collectionView.bounds.width > 0 else {
      return .zero
    }
    return (collectionView.bounds.width - itemSize.width) / 2
  }
  
  /// The latest known CV size, it is useful to understand when collection view size has changed but no `invalidateLayout()` is automatically
  /// called by iOS.
  private var latestKnownCollectionViewSize: CGSize?
  
  /// Updates collection view section insets with leading and trailing space.
  private func updateSectionInsets() {
    sectionInset = UIEdgeInsets(
      top: sectionInset.top,
      left: spaceFromCollectionViewEdge,
      bottom: sectionInset.bottom,
      right: spaceFromCollectionViewEdge
    )
  }
  
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
    currentVisibleCell = 0
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    scrollDirection = .horizontal
    currentVisibleCell = 0
  }
  
  // MARK: - Overridden Methods
  
  open override func invalidateLayout() {
    super.invalidateLayout()
    updateSectionInsets()
  }

  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    /// Since `invalidateLayout()` is not called everytime the collection view `.bounds` changes, just listen
    /// and invalidate layout by caching the collection view size. `layoutAttributesForElements(in rect: CGRect)` is called
    /// every time the collection view doesn't know/isn't "sure" about where to place cells. It is called upon rotation as well.
    if latestKnownCollectionViewSize != collectionView?.bounds.size {
      latestKnownCollectionViewSize = collectionView?.bounds.size
      invalidateLayout()
    }
    return super.layoutAttributesForElements(in: rect)
  }
  
  open override func targetContentOffset(
    forProposedContentOffset proposedContentOffset: CGPoint,
    withScrollingVelocity velocity: CGPoint
  ) -> CGPoint {
    // The current offset
    let currentDistance = CGFloat(currentVisibleCell) * (itemSize.width + minimumLineSpacing)
    
    guard
      let collectionView = collectionView,
      abs(velocity.x) > lowestVelocitySensitivity
      
      else {
      return CGPoint(x: currentDistance, y: 0)
    }
    
    let distanceToMove = velocity.x > 0 ?
      currentDistance + itemSize.width + minimumLineSpacing :
      currentDistance - itemSize.width - minimumLineSpacing
    
    currentVisibleCell = velocity.x > 0 ?
      min(currentVisibleCell + 1, collectionView.numberOfItems(inSection: 0) - 1) :
      max(0, currentVisibleCell - 1)
    
    return CGPoint(x: distanceToMove, y: 0)
  }
}
