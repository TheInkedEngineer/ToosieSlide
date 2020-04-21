//
//  Toosie Slide
// 

import UIKit

/// The ``UICollectionViewDelegateFlowLayout` protocol defines methods that lets you know when and what cell will and is currently being displayed.
/// Methods in this protocol are optional.
/// This protocol conforms to `UICollectionViewDelegateFlowLayout`.
public protocol UICollectionViewDelegateCarouselLayout: UICollectionViewDelegateFlowLayout {
  /// Tells the delegate that the cell at a given `CellIndex` has been shown on screen.
  ///
  /// This method will only be invoked if the layout's `currentVisibleCell` value changes.
  /// - Parameters:
  ///   - collectionView: The collection view calling this method.
  ///   - didShowCellAt: The `CellIndex` of the cell currently being displayed.
  func collectionView(_ collectionView: UICollectionView, didDisplayCellAt cellIndex: CellIndex)
  
  /// Tells the delegate that the cell at a given `CellIndex` will be shown on screen.
  ///
  /// This is meant to replace `func collectionView(UICollectionView, willDisplay: UICollectionViewCell, forItemAt: IndexPath)`.
  /// The default methods messes up the `IndexPath` when an uncomplete snap takes place.
  /// This method will only be invoked if the layout's `currentVisibleCell` value changes.
  /// - Parameters:
  ///   - collectionView: The collection view calling this method.
  ///   - willShowCellAt: The `CellIndex` of the cell being displayed.
  func collectionView(_ collectionView: UICollectionView, willDisplayCellAt cellIndex: CellIndex)
}

public extension UICollectionViewDelegateCarouselLayout {
  func collectionView(_ collectionView: UICollectionView, didDisplayCellAt cellIndex: CellIndex) {}
  func collectionView(_ collectionView: UICollectionView, willDisplayCellAt cellIndex: CellIndex) {}
}
