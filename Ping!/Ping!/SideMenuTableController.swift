//
//  SideMenuTableController.swift
//  Ping!
//
//  Created by Darya Coolidge on 1/31/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuTableController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect in case it changed
        tableView.reloadData()
        
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
        
    }
    
    
}
