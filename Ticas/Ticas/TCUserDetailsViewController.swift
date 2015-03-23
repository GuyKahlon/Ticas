//
//  TCUserDetailsViewController.swift
//  Ticas
//
//  Created by Guy Kahlon on 3/22/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit

class TCUserDetailsViewController: UIViewController {

    @IBOutlet weak var callSignLabel: UILabel!
    @IBOutlet weak var aircraftTypeLabel: UILabel!
    @IBOutlet weak var pilotNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = PFUser.currentUser(){
            callSignLabel.text = currentUser.username
            pilotNameLabel.text = currentUser[ParseKeys.Pilotname] as? String
            aircraftTypeLabel.text = currentUser[ParseKeys.AircraftType] as? String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
