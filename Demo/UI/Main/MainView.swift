//
//  Toosie Slide
// 

import ToosieSlide
import UIKit

class MainView: UIView {
  
  // MARK: - UIElements
  
  private let button = UIButton()
  
  lazy var collection: UICollectionView = {
    let carouselFlow = UICollectionViewCarouselLayout()
    carouselFlow.itemSize = CGSize(width: DemoCell.width, height: DemoCell.height)
    carouselFlow.minimumLineSpacing = 50
    let collection = UICollectionView(collectionViewCarouselLayout: carouselFlow)
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
    addSubview(button)
    
    collection.dataSource = self
    collection.delegate = self
    
    button.addTarget(self, action: #selector(scrollToCell), for: .touchUpInside)
  }
  
  func style() {
    backgroundColor = .white
    button.setTitle("scroll to random cell", for: .normal)
    button.setTitleColor(.blue, for: .normal)
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
    
    button.translatesAutoresizingMaskIntoConstraints = false
    button.topAnchor.constraint(equalTo: collection.bottomAnchor, constant: 40).isActive = true
    button.centerXAnchor.constraint(equalTo: collection.centerXAnchor).isActive = true
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }
}

// MARK: - Action

extension MainView {
  @objc func scrollToCell() {
    let randomInt = Int.random(in: 0..<8)
    print("scroll to cell \(randomInt)")
    collection.scrollToCell(at: randomInt)
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

extension MainView: UICollectionViewDelegateCarouselLayout {
  func collectionView(_ collectionView: UICollectionView, willDisplayCellAt cellIndex: CellIndex) {
    print("Will Display Cell at \(cellIndex)")
  }
}
