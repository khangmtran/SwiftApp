import GoogleMobileAds
import SwiftUI

struct CTAdBannerView: UIViewControllerRepresentable {
    @EnvironmentObject var storeManager: StoreManager
    @StateObject private var networkMonitor = NetworkMonitor.shared

    let bannerView = BannerView(adSize: AdSizeBanner)
    // THIS FLAG TO DISABLE BANNER ADS
    private let adsDisabled = false
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        if adsDisabled {
            return viewController
        }
        
        // Only setup the ad if user hasn't purchased ad removal
        if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected{
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174" //Test ID
            //bannerView.adUnitID = "ca-app-pub-7559937369988658/2534269159" //Real ID
            bannerView.rootViewController = viewController
            viewController.view.addSubview(bannerView)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if adsDisabled {
            return
        }
        // Only load ads if user hasn't purchased ad removal
        if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected{
            bannerView.load(Request())
        }
    }
}
