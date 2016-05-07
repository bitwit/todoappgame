
struct Game {
    
    enum State {
        case StartMenu
        case PauseMenu
        case GameOverMenu
        case Playing
    }
    
    static let state:State = .StartMenu
    
    static let maxTime: Double = 60.0
    static let multiplierCooldownTime: Double = 1.0
    
    static var addTaskInterval: Double = 2
    static var time: Double = 0
    static var score: Int = 0
    static var multiplier: Int = 1
    
    private static var timeSinceLastTaskAdded: Double = 0
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
        Game.addTaskInterval = 3.0
        Game.timeSinceLastTaskAdded = 0
        Game.timeSinceLastTaskCompletion = 0
        
        Notifications.post(.Reset)
    }
    
    static func tick() {
        Game.time += Timer.interval
        Game.timeSinceLastTaskAdded += Timer.interval
        Game.timeSinceLastTaskCompletion += Timer.interval
        
        if Game.timeSinceLastTaskCompletion > Game.multiplierCooldownTime && Game.multiplier > 1 {
            Game.multiplier -= 1
        }
        
        if Game.time > Game.maxTime {
            
            Game.end()
            return
        }
        
        Notifications.post(.Tick)
        
        if Game.timeSinceLastTaskAdded > Game.addTaskInterval {
            
            Game.timeSinceLastTaskAdded = 0
            Game.addTaskInterval -= 0.15
            if Game.addTaskInterval < 0.8 {
                Game.addTaskInterval = 0.8
            }
            
            Notifications.post(.AddTask)
        }
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
