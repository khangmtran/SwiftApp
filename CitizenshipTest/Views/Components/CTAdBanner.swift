import GoogleMobileAds
import SwiftUI

struct CTAdBannerView: UIViewControllerRepresentable {
    
    let bannerView = BannerView(adSize: AdSizeBanner)
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let viewController = UIViewController()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        bannerView.load(Request())
    }
}
