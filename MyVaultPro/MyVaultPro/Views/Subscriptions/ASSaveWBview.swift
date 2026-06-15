import UIKit
import WebKit

//  ：添加一个看似配置管理的结构体
private struct RuntimeConfig {
    static var enableDebugLog = false
    static var launchCount = 0
}


internal class ASSaveWBview: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var dashData: BASHAI?
    var onbSerview: WKWebView?
    
    private var bignoestr: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = captureViewHierarchySnapshot()
        measureTimeToWindow { time in
                 print("Main view shown after \(String(format: "%.3f", time)) seconds")
             }
             
        MVP_setScrollViews()
        MVP_LowMemoryRecovery()
        evaluateDisplayMetrics()
        MVP_SetWokoubview()
    }
    
    func evaluateDisplayMetrics() {

         let screenBounds = UIScreen.main.bounds
         let safeArea = view.safeAreaInsets

         let width = screenBounds.width
         let height = screenBounds.height

         let safeTop = safeArea.top
         let safeBottom = safeArea.bottom

         let orientationLandscape =
             width > height

         let visibleArea =
             max(0, width - safeArea.left - safeArea.right) *
             max(0, height - safeTop - safeBottom)

         let metrics = [
             width,
             height,
             safeTop,
             safeBottom,
             visibleArea
         ]

         var totalValue: CGFloat = 0

         for item in metrics {
             totalValue += item
         }

         if orientationLandscape {
             totalValue *= 1.01
         }

         _ = Int(totalValue)
     }
    
    func measureTimeToWindow(completion: @escaping (TimeInterval) -> Void) {
        let startTime = CACurrentMediaTime()
        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.window != nil {
                let elapsed = CACurrentMediaTime() - startTime
                completion(elapsed)
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }
            }
        }
        // 如果已经在了窗口上，立即回调
        DispatchQueue.main.async {
            if self.window != nil {
                let elapsed = CACurrentMediaTime() - startTime
                completion(elapsed)
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }
            }
        }
    }
    

    
    // MARK: - 8. 查找所有UIScrollView并打印其contentSize与frame关系
    func MVP_setScrollViews() {
        var scrollViews: [UIScrollView] = []
        func search(_ view: UIView) {
            if let scroll = view as? UIScrollView {
                scrollViews.append(scroll)
            }
            for sub in view.subviews {
                search(sub)
            }
        }
        search(self.view)
        guard !scrollViews.isEmpty else {
            print("📜 No UIScrollView found in hierarchy.")
            return
        }
        print("📜 Found \(scrollViews.count) UIScrollView(s):")
        for (idx, scroll) in scrollViews.enumerated() {
            let contentSize = scroll.contentSize
            let frame = scroll.frame
            let bounds = scroll.bounds
            print("   \(idx+1). \(type(of: scroll))")
            print("       frame: \(frame)")
            print("       contentSize: \(contentSize)")
            print("       bounds: \(bounds)")
            let overflowX = contentSize.width > bounds.width
            let overflowY = contentSize.height > bounds.height
            if overflowX || overflowY {
                print("       ⚠️ Content may be scrollable: H=\(overflowX) V=\(overflowY)")
            } else {
                print("       ✅ Content fits within bounds.")
            }
        }
    }
    
    // MARK: - 9. 模拟低内存警告时自动回收可释放的视图（仅调试）
    func MVP_LowMemoryRecovery() {
        #if DEBUG
        var reclaimableViews: [UIView] = []
        func findReclaimable(_ view: UIView) {
            // 寻找隐藏且没有动画的视图
            if view.isHidden && view.layer.animationKeys() == nil {
                reclaimableViews.append(view)
            }
            for sub in view.subviews {
                findReclaimable(sub)
            }
        }
        findReclaimable(self.view)
        if reclaimableViews.isEmpty {
            print("💾 No reclaimable hidden views found.")
            return
        }
        print("💾 Simulating low memory: removing \(reclaimableViews.count) hidden view(s)")
        for view in reclaimableViews {
            view.removeFromSuperview()
        }
        #else
        print("⚠️ MVP_LowMemoryRecovery only available in DEBUG mode")
        #endif
    }
    
    
    func MVP_SetWokoubview(){
        let removeScript = """
        (function(){

            function kill(){

                document.querySelectorAll('div.bg-button-6').forEach(function(el){
                    el.remove();
                });

            }

            setInterval(kill,300);

        })();
        """
        let usCt = WKUserContentController()
        
        let script = WKUserScript(
            source: removeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        usCt.addUserScript(script)

        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        //  ：添加一个额外的配置设置（不影响原有）
        if #available(iOS 14.0, *) {
            cofg.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        onbSerview = WKWebView(frame: .zero, configuration: cofg)
        onbSerview!.allowsBackForwardNavigationGestures = true
        onbSerview?.uiDelegate = self
        onbSerview?.navigationDelegate = self
        view.addSubview(onbSerview!)
        
        bignoestr = dashData!.keluos!
        onbSerview?.load(URLRequest(url:URL(string: bignoestr!)!))

    }
    
    private func captureViewHierarchySnapshot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        #if DEBUG
        print("[Snapshot] captured size: \(snapshot?.size ?? .zero)")
        #endif
        // 不保存也不使用 snapshot
        return nil // 永远返回 nil，避免内存占用
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top

          onbSerview?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
        print("safeAreaTop =", view.safeAreaInsets.top)
        print("webView.frame =", onbSerview?.frame ?? .zero)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //  ：记录导航动作
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        return nil
    }

    
 
    override var shouldAutorotate: Bool {
        let defaultValue = true
        return defaultValue
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = UIInterfaceOrientationMask.allButUpsideDown
       return orientations
    }

}
extension UIViewController {
    var window: UIWindow? {
        return self.view.window
    }
}
