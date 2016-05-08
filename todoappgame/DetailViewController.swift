//
//  DetailViewController.swift
//  todoappgame
//
//  Created by Kyle Newsome on 2016-05-05.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var detailItem: Task?
    
    var completedDictionary:[Int:Bool] = [:]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadGameStatusView()
    }
    
    func loadGameStatusView() {
        
        let nib = NSBundle.mainBundle().loadNibNamed("GameStatusView", owner: nil, options: nil)
        for object in nib {
            if let o = object as? GameStatusView {
                o.prepare()
                o.titleLabel.text = "Subtasks"
                navigationItem.titleView = o
                break
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func save() {
        
        Chirp.sharedManager.playSoundType(.Save)
        detailItem?.isReadyForCompletion = true
        navigationController?.popViewControllerAnimated(true)
    }
    
    func enableSaveButton() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: detailItem!.subtasks.count, inSection: 0)) as! SaveCell
        cell.enable()
    }

    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = InsetLabel(frame: CGRectMake(00,0, UIScreen.mainScreen().bounds.width, 60))
        label.text = (detailItem?.title ?? "")
        label.textColor = Colors.scheme.textColor
        label.backgroundColor = Colors.scheme.settings
        label.font = UIFont.systemFontOfSize(20.0, weight: UIFontWeightBold)
        label.numberOfLines = 0
        return label
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row < detailItem?.subtasks.count {
            return 60
        } else {
            return 340
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (detailItem?.subtasks.count ?? 0) + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == detailItem?.subtasks.count {
            //save button row
            let cell = tableView.dequeueReusableCellWithIdentifier("SaveCell", forIndexPath: indexPath) as! SaveCell
            return cell
        } else {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("SubtaskCell", forIndexPath: indexPath) as! SubtaskCell
            cell.titleLabel.text = detailItem?.subtasks[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return (indexPath.row < detailItem?.subtasks.count) ? true : false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard indexPath.row < detailItem?.subtasks.count else {
            return
        }
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? SubtaskCell else {
            return
        }
        
        guard cell.tag == 0 else {
            return //we already selected this cell
        }
        
        cell.tag = 1
        cell.checkboxImageView.image = UIImage(named: "checkbox-done")
        
        Chirp.sharedManager.playSoundType(.Checkmark)
        
        completedDictionary[indexPath.row] = true
        
        if completedDictionary.count == detailItem?.subtasks.count {
        
            enableSaveButton()
        }
    }
    
}

