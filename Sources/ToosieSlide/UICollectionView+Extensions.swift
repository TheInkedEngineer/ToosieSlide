//
//  Toosie Slide
// 

import UIKit

public extension UICollectionView {
  /// A convenient initializer to instantiate a `UICollectionView` and configure it with a `UICollectionViewCarouselLayout`
  /// The `decelerationRate` of the cell is automatically set to `.fast`
  /// - Parameters:
  ///   - frame: The CGRect frame to assign to the `UICollectionView` when creating it.
  ///   - collectionViewCarouselLayout: The `UICollectionViewCarouselLayout` instance to use when instantiating the `UICollectionView`.
  convenience init(frame: CGRect = .zero, collectionViewCarouselLayout: UICollectionViewCarouselLayout) {
    self.init(frame: frame, collectionViewLayout: collectionViewCarouselLayout)
    decelerationRate = UIScrollView.DecelerationRate.fast
  }

  /// Returns an instance of `collectionViewLayout` down casted to `CarouselCollectionViewFlowLayout`.
  var carouselFlowLayout: UICollectionViewCarouselLayout {
    collectionViewLayout as! UICollectionViewCarouselLayout
  }
  
  /// Scrolls the CollectionView to a given cell index.
  ///
  /// If the passed index is grater than the number of items in the collection, the scroll stops at the last item.
  /// - Parameters:
  ///   - index: The index of desired cell. Should be a value greater than or equal to 0.
  ///   - animated: Whether or not to animate the scroll.
  func scrollToCell(at index: CellIndex, animated: Bool = true) {
    assert(index >= 0, "`index` cannot be negative.")
    
    // check if delegate allows it. check if section not empty
    guard
      (delegate as? UICollectionViewDelegateCarouselLayout)?.collectionView(self, shouldDisplayCellAt: index) != false,
      numberOfItems(inSection: 0) > 0
    else {
      return
    }
    
    // make sure index don't overflow
    let index = min(index, numberOfItems(inSection: 0) - 1)
    // get new offset
    let finalOffset = CGFloat(index) * (carouselFlowLayout.itemSize.width + carouselFlowLayout.minimumLineSpacing)
    // update visible cell
    carouselFlowLayout.currentVisibleCellIndex = index
    // navigate to offset
    setContentOffset(CGPoint(x: finalOffset, y: contentOffset.y), animated: animated)
    // update the layout
    carouselFlowLayout.invalidateLayout()
  }
  
  /// Returns the visible cell object at the specified `CellIndex`.
  /// - Parameter index: The `CellIndex` that specifies the item number of the cell.
  /// - Returns: The cell object at the corresponding index path or nil if the cell is not visible or indexPath is out of range.
  func cellForItem(at index: CellIndex) -> UICollectionViewCell? {
    cellForItem(at: IndexPath(item: index, section: 0))
  }
}
