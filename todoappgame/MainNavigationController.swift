//
//  MainNavigationController.swift
//  todoappgame
//
//  Created by Kyle Newsome on 2016-05-06.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    private var isFirstAppearance = true
    
    internal private(set) var scoreView:ScoreView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreView = ScoreView(navigationBar: self.navigationBar)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            displayIntro()
            isFirstAppearance = false
        }
    }
    
    func displayIntro() {
        
        let intro = StoryboardReference("Main", "Introduction").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func displayGameOver() {
        
        let intro = StoryboardReference("Main", "GameOver").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
}
