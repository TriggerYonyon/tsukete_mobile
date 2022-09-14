//
//  testPageViewController.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/13.
//

import UIKit

class testPageViewController: UIViewController {
    
    @IBOutlet weak var testButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        testButton.addTarget(self, action: #selector(test2), for: .touchUpInside)

    }
    
    @objc func test2() {
        self.dismiss(animated: true)
    }
    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
