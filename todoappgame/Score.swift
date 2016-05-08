import Foundation

struct Score {
    
    static let HighScoreStorageKey = "highScore"
    
    typealias ScoreEntry = (title:String, points:Int, multiplier:Int)
    
    static var history: [ScoreEntry] = []
    static var total: Int = 0
    
    static var highScore: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(Score.HighScoreStorageKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: Score.HighScoreStorageKey)
        }
    }
    
    static func reset() {
        
        Score.history.removeAll()
        Score.total = 0
    }
    
    static func appendToHistory(title:String, points:Int, multiplier:Int) {
    
        let entry:ScoreEntry = (title, points, multiplier)
        Score.history.append(entry)
        
        Score.total += points
    }
    
    static func saveFinalScore() {
    
        if Score.total > Score.highScore {
           Score.highScore = Score.total
        }
    }
    
}
