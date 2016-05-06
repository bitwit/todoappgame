
struct Game {
    
    static let timerInterval: Double = 0.75
    static let maxTime: Double = 20.0
    
    static var time: Double = 0
    
    static var score: Int = 0
    static var multiplier: Int = 1
    
    private static var timeSinceLastTaskCompletion:Double = 0
    
    static func onReset() {
        
        Game.time = 0
        Game.score = 0
    }
    
    static func onTick() {
        
        Game.time += Game.timerInterval
        Game.timeSinceLastTaskCompletion += Game.timerInterval
        
        if Game.timeSinceLastTaskCompletion > 3 && Game.multiplier > 1 {
            Game.multiplier -= 1
        }
    }
    
    static func onTaskCompletion(points:Int) -> Int{
        
        let totalPoints = points * Game.multiplier
        
        Game.score += totalPoints
        Game.multiplier += 1
        
        return totalPoints
    }
}
