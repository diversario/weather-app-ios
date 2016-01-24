//
//  File.swift
//  animation-test
//
//  Created by Ilya Shaisultanov on 1/21/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import Foundation
import UIKit

class FloatingImageViews {
    private var _views: [UIView]
    private let _superview: UIView
    private let _imgName: String
    private let _speed: Double
    private let _speed_variance: Double
    private var _view_speeds: [CGFloat]
    private let _alpha_base: Double
    private let _alpha_variance: Double
    private let _scale_base: CGFloat
    private let _scale_variance: CGFloat
    
    private var _stop = false
    
    init (superview: UIView, imageName: String, speedBase: Double = 10, speedVariance: Double = 20, alphaBase: Double = 0.5, alphaVariance: Double = 0.2, scaleBase: Double = 1, scaleVariance: Double = 1) {
        self._superview = superview
        self._imgName = imageName
        self._views = [UIView]()
        
        self._speed = speedBase < 1 ? 1 : speedBase
        self._speed_variance = speedVariance
        
        self._view_speeds = [CGFloat]()
        
        self._alpha_base = alphaBase
        self._alpha_variance = alphaVariance
        
        self._scale_base = CGFloat(scaleBase)
        self._scale_variance = CGFloat(scaleVariance)
    }
    
    func animate (numberOfViews: Int) {
        for _ in 0...numberOfViews {
            let v = self._createView()
            self._configureView(v)
            self._views.append(v)
            self._superview.addSubview(v)
            _view_speeds.append(CGFloat(self._getValueWithVariance(self._speed, range: self._speed_variance)))
            _move(v, cb: _recycle)
        }
    }
    
    func fadeAndStop () {
        UIView.animateWithDuration(2, animations: { () -> Void in
            for view in self._views {
                view.alpha = 0
            }
        }) { (_) -> Void in
            self._stop = true
            for view in self._views {
                view.removeFromSuperview()
            }
        }
    }
    
    private func _recycle (v: UIImageView) {
        if self._stop {
            return
        }
        
        self._configureView(v)
        _move(v, cb: _recycle)
    }
    
    private func _createView () -> UIImageView {
        let img = UIImage(named: self._imgName)
        let view = UIImageView()
        view.image = img
        
        return view
    }
    
    private func _configureView (view: UIImageView) {
        let img = view.image

        var scale = self._scale_base
        
        let scale_variance = CGFloat(_getValueWithVariance(Double(self._scale_base), range: Double(self._scale_variance)))
        
        if coinToss() {
            scale *= scale_variance
        } else  {
            scale /= scale_variance
        }

        let alpha = CGFloat(_getValueWithVariance(Double(self._alpha_base), range: Double(self._alpha_variance)))

        let width = img!.size.width * -1 * scale
        let height = img!.size.height * scale
        let x = CGFloat(0)
        let y = CGFloat(arc4random_uniform(UInt32(self._superview.frame.height)))
        let x_offset = CGFloat(arc4random_uniform(UInt32(100))) * -1
        let y_offset = CGFloat(arc4random_uniform(UInt32(height/2))) * -1
        
        let rect = CGRectMake(
            x + x_offset,
            y + y_offset,
            width,
            height
        )

        view.frame = rect
        view.image = img
        view.alpha = alpha
    }
        
    private func _move (v: UIImageView, cb: (v: UIImageView)->()) {
        UIView.animateWithDuration(1, delay: 0, options: [.CurveLinear], animations: { () -> Void in
            if let view_index = self._views.indexOf(v) {
                let speed = self._view_speeds[view_index]
                v.center.x += speed
            }
        }) { (_) -> Void in
            if v.frame.origin.x < self._superview.frame.width {
                self._move(v, cb: cb)
            } else {
                cb(v: v)
            }
        }
    }
    
    private func coinToss () -> Bool {
        return arc4random_uniform(2) % 2 == 0
    }
    
    private func _randInRange(from: UInt32, _ to: UInt32) -> Int {
        var r = arc4random_uniform(to) + from
        
        if r > to {
            r = to
        }
        
        return Int(r)
    }
    
    private func _getValueWithVariance (base: Double, range: Double) -> Double {
        let from = UInt32(1000)
        let to = UInt32(range * 1000)
        let result: Double
        
        let variance = Double(_randInRange(from, to)) / 1000.0
        
        if coinToss() {
            result = base * variance
        } else  {
            result = base / variance
        }
        
        return result
    }
}


