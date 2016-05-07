
struct Game {
    
    enum State {
        case StartMenu
        case PauseMenu
        case GameOverMenu
        case Playing
    }
    
    static let state:State = .StartMenu
    
    static let timerInterval: Double = 2
    static let maxTime: Double = 20.0
    static let multiplierCooldownTime: Double = 1.0
    
    static var time: Double = 0
    static var score: Int = 0
    static var multiplier: Int = 1
    
    private static var timeSinceLastTaskCompletion: Double = 0
    
    static func new() {
        Notifications.post(.New)
    }
    
    static func start() {
        
        Game.reset()
        Chirp.sharedManager.playSoundType(.Start)
        
        Timer.start()
    }
    
    static func pause() {
    
        Chirp.sharedManager.playSoundType(.Pause)
        Timer.stop()
        
        Notifications.post(.Pause)
    }
    
    static func resume() {
        
        Timer.start()
        Notifications.post(.Resume)
    }
    
    static func reset() {
        
        Game.time = 0
        Game.score = 0
        Game.multiplier = 1
        Game.timeSinceLastTaskCompletion = 0
        
        Notifications.post(.Reset)
    }
    
    static func tick() {
        
        Game.time += Game.timerInterval
        Game.timeSinceLastTaskCompletion += Game.timerInterval
        
        if Game.timeSinceLastTaskCompletion > Game.multiplierCooldownTime && Game.multiplier > 1 {
            Game.multiplier -= 1
        }
        
        if Game.time > Game.maxTime {
            
            Game.end()
            return
        }
        
        Notifications.post(.Tick)
    }
    
    static func end() {
    
        Chirp.sharedManager.playSoundType(.GameOver)
        Timer.stop()
        
        Notifications.post(.End)
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
