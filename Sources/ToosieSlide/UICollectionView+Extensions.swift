//
//  Toosie Slide
// 

import UIKit

public extension UICollectionView {
  /// A convenient initializer to instantiate a `UICollectionView` and configure it with a `UICollectionViewCarouselLayout`
  /// - Parameters:
  ///   - frame: The CGRect frame to assign to the `UICollectionView` when creating it.
  ///   - collectionViewCarouselLayout: The `UICollectionViewCarouselLayout` instance to use when instantiating the `UIcollectionView`.
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
    let index = min(carouselFlowLayout.currentVisibleCell + 1, numberOfItems(inSection: 0) - 1)
    scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
    carouselFlowLayout.currentVisibleCell = index
  }
  
  /// Returns the visible cell object at the specified `CellIndex`.
  /// - Parameter index: The `CellIndex` that specifies the item number of the cell.
  /// - Returns: The cell object at the corresponding index path or nil if the cell is not visible or indexPath is out of range.
  func cellForItem(at index: CellIndex) -> UICollectionViewCell? {
    cellForItem(at: IndexPath(item: index, section: 0))
  }
}
