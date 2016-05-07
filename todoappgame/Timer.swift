
import Foundation

class Timer:NSObject {

    private static let instance = Timer()
    private static var timer:NSTimer?
    
    static func start() {
    
        Timer.timer?.invalidate() // Safety measure, though timer calls *should* be balanced
        Timer.timer = NSTimer.scheduledTimerWithTimeInterval(Game.timerInterval, target: Timer.instance, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    static func stop() {
        Timer.timer?.invalidate()
        Timer.timer = nil
    }
    
    func tick() {
        Game.tick()
    }
    
}
