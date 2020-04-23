//
//  Toosie Slide
// 

import UIKit

class DemoCell: UICollectionViewCell {
  
  /// The unique identifier of the cell.
  static let identifier = String(describing: DemoCell.self)
  /// The height of the card cell.
  static let height: CGFloat = 0.66 * DemoCell.width
  /// The width of the card cell.
  static let width: CGFloat = 295
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    style()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func style() {
    backgroundColor = .black
  }
}
