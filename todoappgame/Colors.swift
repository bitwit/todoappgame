
import UIKit

struct Colors {
    
    static var scheme:ColorTheme = BootstrapDarkTheme()
    
    static func conformAppearanceToTheme() {
        let a = UINavigationBar.appearance()
        
        Colors.conformNavigationBarToTheme(a)
        
        UIApplication.sharedApplication().statusBarStyle = Colors.scheme.statusBarStyle
    }
    
    private static func conformNavigationBarToTheme(bar:UINavigationBar) {
    
        bar.tintColor = Colors.scheme.tintColor
        bar.titleTextAttributes = [NSForegroundColorAttributeName:Colors.scheme.textColor]
        bar.setBackgroundImage(UIImage.fromColor(Colors.scheme.base), forBarMetrics: .Default)
    }
    
}

protocol ColorTheme {
    
    var type:ColorThemeType { get }

    var base: UIColor { get }
    
    var primary:UIColor { get }
    var success:UIColor { get }
    var info:UIColor { get }
    var warning:UIColor { get }
    var danger:UIColor { get }
    
    var inactive:UIColor { get }
    var inactiveLight:UIColor { get }
    
    var textColor:UIColor { get }
    
    var tintColor:UIColor { get }
    var statusBarStyle:UIStatusBarStyle { get }

}

enum ColorThemeType: String {
    case Bootstrap = "Bootstrap"
    case BootstrapDark = "BootstrapDark"
    
    func colorTheme() -> ColorTheme {
        switch self {
        case .Bootstrap:
            return BootstrapTheme()
        case .BootstrapDark:
            return BootstrapDarkTheme()
        }
    }
    
    static let allValues:[ColorThemeType] = [.Bootstrap, .BootstrapDark]
}

struct BootstrapTheme: ColorTheme {
    
    var type:ColorThemeType = .Bootstrap
    
    var base = UIColor.whiteColor()
    
    var primary = UIColor(hex:0x337ab7)
    var success = UIColor(hex:0x5cb85c)
    var info = UIColor(hex:0x5bc0de)
    var warning = UIColor(hex:0xf0ad4e)
    var danger = UIColor(hex:0xd9534f)
    
    var inactive = UIColor.grayColor()
    var inactiveLight = UIColor.lightGrayColor()
    
    var textColor = UIColor.blackColor()
    
    var tintColor = UIColor.blackColor()
    var statusBarStyle = UIStatusBarStyle.Default
    
}

struct BootstrapDarkTheme: ColorTheme {
    
    var type:ColorThemeType = .BootstrapDark
    
    var primary = UIColor(hex:0x337ab7)
    
    var base: UIColor { return primary }
    
    var success = UIColor(hex:0x5cb85c)
    var info = UIColor(hex:0x5bc0de)
    var warning = UIColor(hex:0xf0ad4e)
    var danger = UIColor(hex:0xd9534f)
    
    var inactive = UIColor.grayColor()
    var inactiveLight = UIColor.lightGrayColor()
    
    var textColor = UIColor.whiteColor()
    
    var tintColor = UIColor.whiteColor()
    var statusBarStyle = UIStatusBarStyle.LightContent
    
}

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIColor {
    
    convenience init(hex:Int) {
        self.init(hex:hex, alpha:1.0)
    }
    
    convenience init(hex:Int, alpha:CGFloat) {
        let red = CGFloat((hex >> 16) & 0xff) / 255.0
        let green = CGFloat((hex >> 8) & 0xff) / 255.0
        let blue = CGFloat(hex & 0xff) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func adjust(red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}
