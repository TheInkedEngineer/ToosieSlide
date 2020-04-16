# ToosieSlide

`ToosieSlide` is a library that offers a custom flow that simulates a paginated collection view, with the cell always staying in the middle.

This still at early stages of development and currently support the horizontal carousel layout, done via code.

Future versions will bring more features:

- vertical carousel
- support for storyboards
- Custom out of the box layouts to plug and use

# 1. Requirements and Compatibility

| Swift               | ToosieSlide     |  iOS     |
|-----------------|----------------|---------|
|       5.1+          | 0.1.x               |  10+     |

# 2. Installation

## Cocoapods

Add the following line to your Podfile
` pod 'ToosieSlide' ~> '0.0.1' `

# 3. Documentation

`ToosieSlide` is fully documented. 
A documentation file will be generated with the release of 1.0.0

# 4. Code Example

```swift
lazy var collection: UICollectionView = {
  let carouselFlow = UICollectionViewCarouselLayout()
  carouselFlow.itemSize = CGSize(width: DemoCell.width, height: DemoCell.height)
  carouselFlow.minimumLineSpacing = 50
  let collection = UICollectionView(collectionViewCarouselLayout: carouselFlow)
  collection.register(DemoCell.self, forCellWithReuseIdentifier: DemoCell.identifier)
  return collection
}()
```

# 5. Contribution

**Working on your first Pull Request?** You can learn how from this *free* series [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)

## Generate the project

To generate this project locally, you need [xcodegen](https://github.com/yonaskolb/XcodeGen). It is a great tool to customize a project and generate it on the go.

You can either install it manually following their steps, or just run my `setup.sh` script. It automatically installs [Homebrew](https://brew.sh) if it is missing, installs `xcodegen`, removes existing (if present) `.xcodeproj`, run `xcodegen` and moves configuratiom files to their appropriate place.

