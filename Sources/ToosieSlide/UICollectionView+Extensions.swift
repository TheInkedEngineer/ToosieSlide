//
//  Toosie Slide
// 

import UIKit

public extension UICollectionView {
  /// A convenient initializer to instantiate a `UICollectionView` and configue it with a `UICollectionViewCarouselLayout`
  /// - Parameters:
  ///   - frame: The CGRect frame to assign to the `UICollectionView` when creating it.
  ///   - collectionViewCarouselLayout: The `UICollectionViewCarouselLayout` instance to use when instantiating the `UIcollectionview`.
  convenience init(frame: CGRect = .zero, collectionViewCarouselLayout: UICollectionViewCarouselLayout) {
    self.init(frame: frame, collectionViewLayout: collectionViewCarouselLayout)
    decelerationRate = UIScrollView.DecelerationRate.fast
  }

  /// Returns an instance of `collectionViewLayout` downcasted to `CarouselCollectionViewFlowLayout`.
  var carouselFlowLayout: UICollectionViewCarouselLayout {
    collectionViewLayout as! UICollectionViewCarouselLayout
  }
}
