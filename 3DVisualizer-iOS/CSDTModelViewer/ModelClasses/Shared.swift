//
//  Shared.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/2/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit


func customGreen() -> UIColor {
    return UIColor(red: 34/255, green: 105/255, blue: 7/255, alpha: 1)
}

enum lightSettings{
    case ambientSetting
    case directionalSetting
    case omniSetting
    case probeSetting
    case spotSetting
}
enum blendModeSettings{
    case alphaSetting
    case addSetting
    case multiplySetting
    case subtractSetting
    case screenSetting
    case replaceSetting
}
enum animationSettings{
    case none
    case rotate
}

let stringToLightType: Dictionary<String, SCNLight.LightType> =
    ["Omnidirectional": .omni, "Ambient":.ambient, "Directional":.directional, "Probe": .probe, "Spot": .spot]
let stringToBlendMode: Dictionary<String, SCNBlendMode> =
    ["Add": .add, "Alpha": .alpha, "Multiply": .multiply, "Replace": .replace, "Screen": .screen, "Subtract": .subtract]
let stringToPlaneDetection: Dictionary<String, ARWorldTrackingConfiguration.PlaneDetection> =
    ["Horizontal":.horizontal, "Vertical": .vertical]

func determineLightType(with light:SCNLight) -> String{
    switch light.type{
    case .omni:
        return "Omnidirectional"
    case .ambient:
        return "Ambient"
    case .directional:
        return "Directional"
    case .probe:
        return "Probe"
    case .spot:
        return "Spot"
    default: break
    }
    return "Omnidirectional"
}

func determineBlendMode(with mode:SCNBlendMode) -> String{
    switch mode{
    case .add:
        return "Add"
    case .alpha:
        return "Alpha"
    case .multiply:
        return "Multiply"
    case .replace:
        return "Replace"
    case .screen:
        return "Screen"
    case .subtract:
        return "Subtract"
    default: break
    }
    return "Alpha"
}

func determinePlaneDetectionMode(with mode: ARWorldTrackingConfiguration.PlaneDetection) -> String{
    switch mode {
    case .horizontal:
        return "Horizontal"
    case .vertical:
        return "Vertical"
    default:
        return "Horizontal"
    }
}

func overlayTextWithVisualEffect(using text:String, on view: UIView){
    let blurEffect = UIBlurEffect(style: .prominent)
    let blurredEffectView = UIVisualEffectView(effect: blurEffect)
    let effectBounds = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width/2 - 150, y: UIScreen.main.bounds.height/2 - 50),size: CGSize(width: 300, height: 100))
    blurredEffectView.frame = effectBounds
    blurredEffectView.layer.cornerRadius = 30.0
    blurredEffectView.clipsToBounds = true
    let label = UILabel(frame: effectBounds)
    label.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    label.textAlignment = .center
    label.text = text
    label.font = label.font.withSize(30.0)
    label.textColor = UIColor.black
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.6
    label.numberOfLines = 0
    
    view.addSubview(blurredEffectView)
    view.addSubview(label)
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false){ _ in
        UIView.transition(with: blurredEffectView, duration: 0.25, options: [.transitionCrossDissolve],
                          animations: {blurredEffectView.alpha = 0}){ _ in
                            blurredEffectView.removeFromSuperview()
        }
        UIView.transition(with: label, duration: 0.25, options: [.transitionCrossDissolve],
                          animations: {label.alpha = 0}){ _ in
                            label.removeFromSuperview()
        }
    }
}

func planeRectangle() -> UIBezierPath{
    let path = UIBezierPath()
    path.lineWidth = 5.0
    path.move(to: CGPoint(x: 0.0, y: 0.0))
    path.addLine(to: CGPoint(x: 0.0, y: 100.0))
    path.addLine(to: CGPoint(x: 100.0, y: 100.0))
    path.addLine(to: CGPoint(x: 100.0, y: 0.0))
    path.close()
    return path
}

func configureDropShadow(with button:UIButton){
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowRadius = 3.0
    button.layer.shadowOpacity = 1.0
    button.layer.shadowOffset = CGSize(width: 4, height: 4)
    button.layer.masksToBounds = false
}

func setupCollectionViewLayout(with collectionView: UICollectionView?,
                                    andSize sizeClass: UIUserInterfaceSizeClass){
    let widthFactor: CGFloat = (sizeClass == .compact) ? 2.0 : 3.0
    let heightFactor: CGFloat = (sizeClass == .compact) ? 1.71 : 3.0
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let width = UIScreen.main.bounds.width
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.itemSize = CGSize(width: width / widthFactor, height: width / heightFactor)// 2.05 & 1.75
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 27)
    collectionView?.collectionViewLayout = layout
}

extension UIColor{
    class func rgb(r red:CGFloat, g green:CGFloat, b blue:CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension Notification.Name{
    static let onLightSwitchChange = Notification.Name("on-light-switch-change")
    static let viewARPeekDidDismiss = Notification.Name("viewARPeekDidDismiss");
}

