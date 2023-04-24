//
//  ViewController.swift
//  PDF-Demo
//
//  Created by 畅束 on 2023/4/23.
//  Copyright © 2023 com.tzshlyt.demo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var selectPDF: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectPDF = UIButton(type: .system)
        selectPDF.frame = CGRect(x:5, y:100, width:100, height:30)
        selectPDF.setTitle("sample.pdf", for:.normal)
        selectPDF.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        selectPDF.addTarget(self, action: #selector(readPDF), for: .touchUpInside)
        view.addSubview(selectPDF)
    }
    
    @objc func readPDF(sender: UIButton) {
        let separatedStrings = sender.currentTitle!.components(separatedBy: ".")
        if separatedStrings.count == 2 && separatedStrings[1]=="pdf"{
            let name = separatedStrings[0]
            self.present(PDFViewController(param: name),animated: true,completion: nil)
        } else {
            print("error ")
        }
        
    }
}
