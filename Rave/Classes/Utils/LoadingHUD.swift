//
//  LoadingHUD.swift
//  GetBarter
//
//  Created by Olusegun Solaja on 04/08/2018.
//  Copyright © 2018 Olusegun Solaja. All rights reserved.
//

import UIKit
import Lottie

public class LoadingHUD: UIView {

    var animation:LOTAnimationView!
    
    var bgColor: UIColor? = .clear
    var applyBlur = true
    var animationFile = "Loader_YW"
    var blurView:UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()
    
    public class func shared() -> LoadingHUD{
        struct Static {
            static let loader = LoadingHUD(frame: (UIApplication.shared.keyWindow?.frame)!)
            
        }
        return Static.loader
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI(){
        
    }
    
 
    @available(iOS 9.0, *)
    public func show(){
        backgroundColor = bgColor
        if(applyBlur){
            insertSubview(blurView, at: 0)
            blurView.leftAnchor.constraint(equalTo:leftAnchor).isActive = true
            blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        animation = LOTAnimationView(name: animationFile)
        animation.loopAnimation = true
        animation.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animation)
        animation.centerXAnchor.constraint(equalTo:centerXAnchor).isActive = true
        animation.centerYAnchor.constraint(equalTo:centerYAnchor).isActive = true
        animation.widthAnchor.constraint(equalToConstant: 80).isActive = true
        animation.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.animation.play()
        UIApplication.shared.keyWindow?.addSubview(self)
        isHidden = false
    }
   
    @available(iOS 9.0, *)
    public func showInView(view:UIView){
        backgroundColor = bgColor
        if(applyBlur){
            insertSubview(blurView, at: 0)
            blurView.leftAnchor.constraint(equalTo:leftAnchor).isActive = true
            blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        animation = LOTAnimationView(name: animationFile)
        animation.loopAnimation = true
        animation.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animation)
        animation.centerXAnchor.constraint(equalTo:centerXAnchor).isActive = true
        animation.centerYAnchor.constraint(equalTo:centerYAnchor).isActive = true
        animation.widthAnchor.constraint(equalToConstant: 80).isActive = true
        animation.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.animation.play()
        view.addSubview(self)
        isHidden = false
    }
    
    public func hide(){
        animation.stop()
        isHidden = true
        removeFromSuperview()
    }
    
    
}

