//
//  Toosie Slide
// 

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    self.window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
    guard let window = self.window else { return false }
    
    let mainVC = MainViewController()
    window.rootViewController = mainVC
    window.makeKeyAndVisible()
    
    return true
  }
}
