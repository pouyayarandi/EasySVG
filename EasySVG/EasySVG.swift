//
//  EasySVG.swift
//  EasySVG
//
//  Created by Pouya on 1/21/19.
//  Copyright © 2019 pouya yarandi. All rights reserved.
//

import Foundation
import WebKit

open class EasySVG {
    fileprivate static func changeColor(data: Data, color: UIColor) -> Data? {
        guard let hexColor = getHexString(color: color) else { return nil }
        let regex = try! NSRegularExpression(pattern: "#[0-9A-Fa-f]{6}", options: .caseInsensitive)
        let s = String(data: data, encoding: String.Encoding.utf8) ?? ""
        let newString = regex.stringByReplacingMatches(in: s,
                                                       options: [],
                                                       range: NSMakeRange(0, s.count),
                                                       withTemplate: hexColor)
        return newString.data(using: .utf8)
    }
    
    fileprivate static func getHexString(color: UIColor?) -> String? {
        if color == nil { return nil }
        var components = (color?.cgColor.components ?? [0.0, 0.0, 0.0, 0.0]).map({ Int($0 * 255) })
        components = components.count == 2 ? [components[0],components[0],components[0],components[1]] : components
        if components.count < 4 { return nil }
        let hexColor = String(format: "#%02x%02x%02x",
                              components[0],
                              components[1],
                              components[2])
        return hexColor
    }
    
    private static var svgCountKey = "svgCount"
    
    fileprivate static func addQueueCount() {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: EasySVG.svgCountKey) + 1,
                                  forKey: EasySVG.svgCountKey)
    }
    
    fileprivate static func subQueueCount() {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: EasySVG.svgCountKey) - 1,
                                  forKey: EasySVG.svgCountKey)
    }
    
    fileprivate static func getQueueCount() -> Int {
        return UserDefaults.standard.integer(forKey: EasySVG.svgCountKey)
        
    }
    
    fileprivate static func getUrl(fileName: String) -> URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.pouyayarandi.EasySVG.\(fileName).png")
    }
    
    fileprivate static func addKeyToLoadedList(key: String?) {
        guard let key = key else { return }
        var array = EasySVG.getLoadedList()
        if !array.contains(key) { array.append(key) }
        UserDefaults.standard.set(array, forKey: "com.pouyayarandi.EasySVG.LoadedList")
    }
    
    fileprivate static func getLoadedList() -> [String] {
        return UserDefaults.standard.array(forKey: "com.pouyayarandi.EasySVG.LoadedList") as? [String] ?? []
    }
    
    /// A boolean determines whether cache is enabled or not, enabling cache can increase performance and disk usage
    public static var allowCache: Bool {
        get { return UserDefaults.standard.bool(forKey: "com.pouyayarandi.EasySVG.allowCache") }
        set {
            if !newValue { EasySVG.removeCache() }
            UserDefaults.standard.set(newValue, forKey: "com.pouyayarandi.EasySVG.allowCache")
        }
    }
    
    /// Removes vectors that cached
    public static func removeCache() {
        EasySVG.getLoadedList().forEach ({
            try? FileManager.default.removeItem(at: EasySVG.getUrl(fileName: $0))
        })
    }
}

@IBDesignable class EasyImageView: UIImageView {
    @IBInspectable var fileName: String? {
        didSet {
            guard let name = fileName else { return }
            
            if let data = NSData(contentsOf: EasySVG.getUrl(fileName: name)) {
                let image = UIImage(data: data as Data)
                self.image = image
                return
            } else {
                self.setSVG(name)
            }
        }
    }
    
    @IBInspectable var vectorColor: UIColor? {
        didSet {
            self.setColorOfSVG(vectorColor)
        }
    }
}

extension UIImageView: WKNavigationDelegate {
    /// Set vector as image of UIImageView
    public func setSVG(_ fileUrl: URL, withColor color: UIColor? = nil) {
        self.image = nil
        
        var file = fileUrl.lastPathComponent.components(separatedBy: ".").first
        if let hexString = EasySVG.getHexString(color: color) {
            file?.append("_\(hexString)")
        }
        
        if let data = NSData(contentsOf: EasySVG.getUrl(fileName: file ?? "")) {
            let image = UIImage(data: data as Data)
            self.image = image
            if let color = color { self.setImageColor(color: color) }
            return
        }
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.frame = self.bounds
        webView.isOpaque = false
        
        do {
            let data = try Data(contentsOf: fileUrl)
            var newData = data
            if let color = color, let dataWithColor = EasySVG.changeColor(data: data, color: color) {
                newData = dataWithColor
            }
            self.alpha = 0
            EasySVG.addKeyToLoadedList(key: file)
            webView.load(newData, mimeType: "svg", characterEncodingName: "utf8", baseURL: URL(string: "about:blank")!)
            webView.accessibilityIdentifier = file
            self.subviews.filter({ $0 is WKWebView }).forEach({ $0.removeFromSuperview() })
            self.addSubview(webView)
        } catch {
            fatalError("Can't read vector file")
        }
    }
    
    /// Set vector as image of UIImageView
    public func setSVG(_ fileName: String, withColor color: UIColor? = nil) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "svg") {
            self.setSVG(url, withColor: color)
        }
    }
    
    /// Set color of SVG, original color of vector will render if no color
    public func setColorOfSVG(_ color: UIColor?) {
        if self.image != nil, let color = color {
            self.setImageColor(color: color)
            return
        }
        UIView.animate(withDuration: 0.1) { self.alpha = 0 }
        if let fileName = getWebView()?.accessibilityIdentifier?.components(separatedBy: "_").first {
            self.setSVG(fileName, withColor: color)
        }
    }
    
    open override func layoutSubviews() {
        getWebView()?.frame = self.bounds
    }
    
    private func getWebView() -> WKWebView? {
        return self.subviews.filter({ $0 is WKWebView }).first as? WKWebView
    }
    
    private func saveSnapshot(from webView: WKWebView) {
        let config = WKSnapshotConfiguration()
        webView.takeSnapshot(with: config, completionHandler: { (image, error) in
            let url = EasySVG.getUrl(fileName: webView.accessibilityIdentifier ?? "")
            try? image?.pngData()?.write(to: url, options: .atomic)
        })
    }
    
    private func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    //MARK: - navigation delegate
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let scale = min (
                webView.frame.width / webView.scrollView.contentSize.width,
                webView.frame.height / webView.scrollView.contentSize.height
            )
            webView.scrollView.transform = CGAffineTransform(scaleX: scale, y: scale)
            if self.alpha == 0 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 1
                }, completion: { _ in
                    if EasySVG.allowCache { self.saveSnapshot(from: webView) }
                    self.image = nil
                })
            }
        }
    }
}
