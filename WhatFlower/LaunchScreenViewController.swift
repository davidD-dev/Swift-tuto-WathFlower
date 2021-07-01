//
//  LaunchScreenViewController.swift
//  WhatFlower
//
//  Created by David Deschamps on 30/06/2021.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    private let logoView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        
        imageView.image = UIImage(named: "logoNoBg")
        return imageView
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoView)
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        logoView.center = view.center
        logoView.backgroundColor = .blue

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.animate()
        }
    }
    
    private func animate() {
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 1.5
            
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.logoView.frame = CGRect(x: -(diffX/2) , y: diffY/2, width: size, height: size)
        })
    }
    

}
