
struct Game {
    
    static let timerInterval: Double = 0.75
    static let maxTime: Double = 30.0
    static let multiplierCooldownTime: Double = 1.0
    
    static var time: Double = 0
    static var score: Int = 0
    static var multiplier: Int = 1
    
    private static var timeSinceLastTaskCompletion: Double = 0
    
    static func onReset() {
        
        Game.time = 0
        Game.score = 0
        Game.multiplier = 0
        Game.timeSinceLastTaskCompletion = 0
    }
    
    static func onTick() {
        
        Game.time += Game.timerInterval
        Game.timeSinceLastTaskCompletion += Game.timerInterval
        
        if Game.timeSinceLastTaskCompletion > Game.multiplierCooldownTime && Game.multiplier > 1 {
            Game.multiplier -= 1
        }
    }
    
    static func onTaskCompletion(points:Int) -> (multiplier:Int, points:Int) {
        
        Game.timeSinceLastTaskCompletion = 0
        
        let totalPoints = points * Game.multiplier
        let result = (multiplier: Game.multiplier, points:totalPoints)
        
        Game.score += totalPoints
        Game.multiplier += 1
        
        return result
    }
}
