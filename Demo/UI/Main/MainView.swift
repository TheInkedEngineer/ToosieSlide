//
//  Toosie Slide
// 

import ToosieSlide
import UIKit

class MainView: UIView {
  
  // MARK: - UIElements
  
  lazy var collection: UICollectionView = {
    let carouselFlow = CarouselCollectionViewFlowLayout()
    carouselFlow.itemSize = CGSize(width: DemoCell.width, height: DemoCell.height)
    carouselFlow.minimumLineSpacing = 50
    let collection = UICollectionView(carouselCollectionViewFlowLayout: carouselFlow)
    collection.register(DemoCell.self, forCellWithReuseIdentifier: DemoCell.identifier)
    return collection
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configure()
    style()
    update()
    layout()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    configure()
    style()
    update()
    layout()
  }
  
  // MARK: - CSUL
  
  func configure() {
    addSubview(collection)
    collection.dataSource = self
  }
  
  func style() {
    backgroundColor = .white
    
    collection.backgroundColor = .clear
    collection.showsHorizontalScrollIndicator = false
  }
  
  func update() {}
  
  func layout() {
    collection.translatesAutoresizingMaskIntoConstraints = false
    collection.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    collection.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    collection.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    collection.heightAnchor.constraint(equalToConstant: 300).isActive = true
  }
}

// MARK: - Data Source

extension MainView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    8
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    collectionView.dequeueReusableCell(withReuseIdentifier: DemoCell.identifier, for: indexPath) as? DemoCell ?? UICollectionViewCell()
  }
}
