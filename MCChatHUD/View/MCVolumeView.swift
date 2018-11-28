//
//  MCVolumeView.swift
//  MCChatHUD
//
//  Created by duwei on 2018/1/30.
//  Copyright © 2018年 Dywane. All rights reserved.
//

import UIKit

class MCVolumeView: UIView {

    //MARK: Private Properties
    /// 声音表数组
    private var soundMeters: [Float] = []
    
    private var type: HUDType = .bar
    
    let threshold = Int(UIScreen.main.bounds.width / 6)
    //MARK: Init
    convenience init(frame: CGRect, type: HUDType) {
        self.init(frame: frame)
        self.type = type
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentMode = .redraw   //内容模式为重绘，因为需要多次重复绘制音量表
        
        switch type {
        case .bar:
            let line = UIView(frame: CGRect(x: 0, y: self.center.y - 1, width: self.bounds.width, height: 2))
            line.backgroundColor = .white
            addSubview(line)
        default: break
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notice:)), name: NSNotification.Name.init("updateMeters"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if soundMeters.count > 0 {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineCap(.round)
            context?.setLineJoin(.round)
            context?.setStrokeColor(UIColor.white.cgColor)
            
            let noVoice = -46.0     // 该值代表低于-46.0的声音都认为无声音
            let maxVolume = 55.0    // 该值代表最高声音为55.0
            
            switch type {
            case .bar:
                context?.setLineWidth(3)
                for (index, item) in soundMeters.enumerated() {
                    let barHeight = maxVolume - (Double(item) - noVoice)    //通过当前声音表计算应该显示的声音表高度
                    
                    // -70 + 46
                    // -50 + 46
                    let middle = VolumeViewHeight / 2 + 4
                
                    let reverseBarHeight = Double(VolumeViewHeight) + Double(item) - noVoice - maxVolume
                    let width = Int(self.bounds.width)
                    
                    context?.move(to: CGPoint(x: width - (index * 6 + 3), y: VolumeViewHeight/2 - 4))
                    context?.addLine(to: CGPoint(x: width - (index * 6 + 3), y: Int(barHeight)))
                    
                    print(barHeight)
       
                    context?.move(to: CGPoint(x: width - (index * 6 + 3), y: VolumeViewHeight/2 + 4))
                    context?.addLine(to: CGPoint(x: width - (index * 6 + 3), y: Int(reverseBarHeight)))
                }
            case .line:
                context?.setLineWidth(1.5)
                for (index, item) in soundMeters.enumerated() {
                    let position = maxVolume - (Double(item) - noVoice)     //计算对应线段高度
                    context?.addLine(to: CGPoint(x: Double(index * 6 + 3), y: position))
                    context?.move(to: CGPoint(x: Double(index * 6 + 3), y: position))
                }
            }
            context?.strokePath()
        }
    }
    
    @objc private func updateView(notice: Notification) {
        
        let newMeters = notice.object as! [Float]
        
        soundMeters.insert(contentsOf: newMeters, at: 0)
        setNeedsDisplay()
        if soundMeters.count > threshold {
            soundMeters.removeLast(newMeters.count)
        }
        
        
    }

}
