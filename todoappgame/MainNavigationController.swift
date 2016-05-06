//
//  MainNavigationController.swift
//  todoappgame
//
//  Created by Kyle Newsome on 2016-05-06.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    internal private(set) var scoreView:ScoreView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreView = ScoreView(navigationBar: self.navigationBar)
        
    }
    
}
