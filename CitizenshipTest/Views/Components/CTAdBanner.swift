import GoogleMobileAds
import SwiftUI

struct CTAdBannerView: UIViewControllerRepresentable {
    @EnvironmentObject var storeManager: StoreManager
    
    let bannerView = BannerView(adSize: AdSizeBanner)
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Only setup the ad if user hasn't purchased ad removal
        if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            bannerView.rootViewController = viewController
            viewController.view.addSubview(bannerView)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Only load ads if user hasn't purchased ad removal
        if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            bannerView.load(Request())
        }
    }
}
