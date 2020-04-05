//
//  Toosie Slide
// 

import UIKit

public extension UICollectionView {
  /// Returns an instance of `collectionViewLayout` downcasted to `CarouselCollectionViewFlowLayout`.
  var carouselFlowLayout: CarouselCollectionViewFlowLayout {
    collectionViewLayout as! CarouselCollectionViewFlowLayout
  }
}
