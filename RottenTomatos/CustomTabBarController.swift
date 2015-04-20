//
//  CustomTabBarController.swift
//  RottenTomatos
//
//  Created by Chris Beale on 4/19/15.
//  Copyright (c) 2015 Chris Beale. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let viewControllers = self.viewControllers! as! [UIViewController]
                
        var navController = viewControllers[0] as! UINavigationController
        let movieVC = navController.viewControllers[0] as! MoviesViewController
        
        movieVC.tabBarItem.title = "Box Office"
        
        navController = viewControllers[1] as! UINavigationController
        let dvdVC = navController.viewControllers[0] as! MoviesViewController
        dvdVC.setCategory(.DVD)
        dvdVC.tabBarItem.title = "DVD"
        dvdVC.tabBarItem.image = UIImage(named: "iconmonstr-disc-3-icon-24")
        
        self.tabBar.sizeToFit()
        self.tabBar.tintColor = UIColor(red: 0.0, green: 0.0, blue: 255.0, alpha: 0.5)
    }
   
}
