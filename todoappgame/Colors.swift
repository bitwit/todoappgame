
import UIKit

struct Colors {
    
    static var scheme:ColorTheme = SophiaTheme()
    
    static func conformAppearanceToTheme() {
        let a = UINavigationBar.appearance()
        
        Colors.conformNavigationBarToTheme(a)
        
        UIApplication.sharedApplication().statusBarStyle = Colors.scheme.statusBarStyle
    }
    
    private static func conformNavigationBarToTheme(bar:UINavigationBar) {
    
        bar.tintColor = Colors.scheme.tintColor
        bar.titleTextAttributes = [NSForegroundColorAttributeName:Colors.scheme.textColor]
        bar.setBackgroundImage(UIImage.fromColor(Colors.scheme.navigationBarColor), forBarMetrics: .Default)
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
    
    var settings:UIColor { get }
    var inactive:UIColor { get }
    var inactiveLight:UIColor { get }
    
    var textColor:UIColor { get }
    
    var tintColor:UIColor { get }
    var statusBarStyle:UIStatusBarStyle { get }
    
    var navigationBarColor: UIColor { get }
    var cellTextColor: UIColor { get }
}

enum ColorThemeType: String {
    case Sophia = "Sophia"
    
    func colorTheme() -> ColorTheme {
        switch self {
        case .Sophia:
            return SophiaTheme()
        }
    }
    
    static let allValues:[ColorThemeType] = [.Sophia]
}

struct SophiaTheme {
    
    var red = UIColor(hex:0xff5858)
    var mainGreen = UIColor(hex:0x0d9f9f)
    var darkerGreen = UIColor(hex:0x36756c)
    var offBlack = UIColor(hex:0x1e1e1e)
    var mutedGreen = UIColor(hex:0x769377)
    var midGray = UIColor(hex:0xa3afa3)
    var grayishGreen = UIColor(hex:0xc1cec2)
    
    var type:ColorThemeType = .Sophia
}

extension SophiaTheme: ColorTheme {
    //Protocol
    
    var primary: UIColor { return mainGreen }
    
    var base:UIColor { return UIColor.whiteColor() }
    
    var success: UIColor { return darkerGreen }
    
    var info: UIColor { return grayishGreen }
    var warning: UIColor { return mutedGreen }
    
    var danger:UIColor { return red }
    
    var settings:UIColor { return mainGreen }
    
    var inactive: UIColor { return midGray }
    var inactiveLight: UIColor { return grayishGreen }
    
    var textColor:UIColor { return UIColor.whiteColor() }
    var tintColor:UIColor { return midGray }
    
    var statusBarStyle:UIStatusBarStyle { return UIStatusBarStyle.LightContent }
    
    var navigationBarColor:UIColor { return offBlack }
    var cellTextColor: UIColor { return offBlack }
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
