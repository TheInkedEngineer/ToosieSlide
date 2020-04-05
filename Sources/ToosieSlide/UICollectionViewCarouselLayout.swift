//
//  Toosie Slide
//

import UIKit

open class UICollectionViewCarouselLayout: UICollectionViewFlowLayout {
  
  // MARK: - Properties
  
  /// The cell currently being displayed for the user.
  public var currentVisibleCell = 0
  
  /// The lowest absolute velocity that should invoke a change of cells.
  /// If the absolute velocity of the swipe is lower than this variable, the centeral cell does not change.
  public var lowestVelocitySensitivity: CGFloat = 0.2
  
  /// The space between the cell and the collection view edge.
  public var spaceFromCollectionViewEdge: CGFloat {
    guard let collectionView = collectionView else { return .zero }
    return (collectionView.frame.size.width - itemSize.width) / 2
  }
  
  // MARK: - Overrided properties
  
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
  
  // MARK: - Overrided Methods
  
  open override func invalidateLayout() {
    super.invalidateLayout()
    
    guard let collectionView = collectionView else { return }
    
    let horizontalOffset = (collectionView.frame.size.width - itemSize.width) / 2
    let verticalOffset = (collectionView.frame.size.height - itemSize.height) / 2
    // we set the inset of the content to be equal to the horizontal offset on the sides to simulate the centering of the cell.
    collectionView.contentInset = UIEdgeInsets(top: verticalOffset, left: horizontalOffset, bottom: verticalOffset, right: horizontalOffset)
    // position the cell in the center of the collection.
    collectionView.contentOffset = CGPoint(x: -horizontalOffset, y: -verticalOffset)
  }
  
  open override func targetContentOffset(
    forProposedContentOffset proposedContentOffset: CGPoint,
    withScrollingVelocity velocity: CGPoint
  ) -> CGPoint {
    
    // The curremt offset
    let currentDistance = CGFloat(currentVisibleCell) * (itemSize.width + minimumLineSpacing) - spaceFromCollectionViewEdge
    
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
