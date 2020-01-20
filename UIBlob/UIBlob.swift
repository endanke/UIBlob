//
//  UIBlob.swift
//  UIBlob
//
//  Created by Daniel Eke on 20/01/2020.
//  Copyright © 2020 Daniel Eke. All rights reserved.
//

import UIKit

open class UIBlob: UIView {
    
    private static var displayLink: CADisplayLink?
    private static var blobs: [UIBlob] = []
    
    private var points: [UIBlobPoint] = []
    private var numPoints = 32
    fileprivate var radius: CGFloat = 0
    
    @IBInspectable public var color: UIColor = .black {
        didSet { self.setNeedsDisplay() }
    }
    public var stopped = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        backgroundColor = .clear
        clipsToBounds = false
        for i in 0...numPoints {
            let point = UIBlobPoint(azimuth: self.divisional() * CGFloat(i + 1), parent: self)
            points.append(point)
        }
        UIBlob.blobs.append(self)
    }
    
    deinit {
        destroy()
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        destroy()
    }
    
    private func destroy() {
        UIBlob.blobs.removeAll{ $0 == self }
        UIBlob.blobStopped()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        radius = frame.size.width / 3
    }
    
    // MARK: Public interfaces
    
    public func shake() {
        var randomIndices: [Int] = Array(0...numPoints)
        randomIndices.shuffle()
        randomIndices = Array(randomIndices.prefix(5))
        for index in randomIndices {
            points[index].acceleration = -0.3 + CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 0.6
        }
        stopped = false
        UIBlob.blobStarted()
    }
    
    public func stopShake() {
        for i in 0...numPoints {
            let point = points[i]
            point.acceleration = 0
            point.speed = 0
            point.radialEffect = 0
        }
    }
    
    // MARK: Rendering
    
    public override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()?.flush()
        render(frame: rect)
    }
    
    private func render(frame: CGRect) {
        if points.count < numPoints { return }
        
        let p0 = points[numPoints-1].getPosition()
        var p1 = points[0].getPosition()
        let _p2 = p1;
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: (p0.x + p1.x) / 2.0, y: (p0.y + p1.y) / 2.0 ))
        
        for i in 0...numPoints-1 {
            let p2 = points[i].getPosition()
            let xc = (p1.x + p2.x) / 2.0
            let yc = (p1.y + p2.y) / 2.0
            
            bezierPath.addQuadCurve(to: CGPoint(x: xc, y: yc), controlPoint: CGPoint(x: p1.x, y: p1.y))
            p1 = p2
        }
        
        let xc = (p1.x + _p2.x) / 2.0
        let yc = (p1.y + _p2.y) / 2.0
        bezierPath.addQuadCurve(to: CGPoint(x: xc, y: yc), controlPoint: CGPoint(x: p1.x, y: p1.y))

        bezierPath.close()
        color.setFill()
        bezierPath.fill()
    }
    
    private func divisional() -> CGFloat {
        return .pi * 2.0 / CGFloat(numPoints)
    }
    
    fileprivate func center() -> CGPoint {
        return CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
    }
    
    // TODO: Create dynamic shake animation based on tap location
    private func closestPointTo(tap: CGPoint) -> Int {
        var closest = 0
        var minDist = self.bounds.size.width
        for (index, point) in points.enumerated() {
            let distance = sqrt(pow(point.getPosition().x - tap.x, 2) + pow(point.getPosition().y - tap.y, 2))
            if distance < minDist {
                closest = index
                minDist = distance
            }
        }
        return closest
    }
    
    // MARK: Animation update logic
    
    static func blobStarted() {
        guard (displayLink == nil) else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(updateDeltaTime))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    static func blobStopped() {
        guard (blobs.filter{ $0.stopped == false }.count == 0) else { return }
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private static func updateDeltaTime(link: CADisplayLink) {
        blobs.filter{ $0.stopped == false }.forEach{ $0.update() }
        usleep(10)
    }
    
    @objc private func update() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var allDone = true
            var stopped = self.points[0].solveWith(leftPoint: self.points[self.numPoints-1], rightPoint: self.points[1])
            if !stopped { allDone = false }
            for i in 1...self.numPoints {
                if i + 1 < self.numPoints {
                    stopped = self.points[i].solveWith(leftPoint: self.points[i-1], rightPoint: self.points[i+1])
                } else {
                    stopped = self.points[i].solveWith(leftPoint: self.points[i-1], rightPoint: self.points[0])
                }
                if !stopped { allDone = false }
            }
            
            DispatchQueue.main.async { [weak self] in
                if allDone {
                    self?.stopped = true
                    UIBlob.blobStopped()
                }
                self?.setNeedsDisplay()
            }
        }
    }
    
}

fileprivate class UIBlobPoint {
    
    private weak var parent: UIBlob?
    private let azimuth: CGFloat
    fileprivate var speed: CGFloat = 0 {
        didSet {
            radialEffect += speed * 3
        }
    }
    fileprivate var acceleration: CGFloat = 0 {
        didSet {
            speed += acceleration * 2
        }
    }
    fileprivate var radialEffect: CGFloat = 0
    private var elasticity: CGFloat = 0.001
    private var friction: CGFloat = 0.0085
    private var x: CGFloat = 0
    private var y: CGFloat = 0
    
    init(azimuth: CGFloat, parent: UIBlob) {
        self.parent = parent
        self.azimuth = .pi - azimuth
        let randomZeroToOne = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        self.acceleration = -0.3 + randomZeroToOne * 0.6
        self.x = cos(self.azimuth)
        self.y = sin(self.azimuth)
    }
    
    func solveWith(leftPoint: UIBlobPoint, rightPoint: UIBlobPoint) -> Bool {
        self.acceleration = (-0.3 * self.radialEffect
            + ( leftPoint.radialEffect - self.radialEffect )
            + ( rightPoint.radialEffect - self.radialEffect ))
            * self.elasticity - self.speed * self.friction;
        
        // Consider the point stopped if the acceleration is below the treshold
        let isStill = abs(acceleration) < 0.0001
        return isStill
    }
    
    func getPosition() -> CGPoint {
        guard let parent = self.parent else { return .zero }
        return CGPoint(
            x: parent.center().x + self.x * (parent.radius + self.radialEffect),
            y: parent.center().y + self.y * (parent.radius + self.radialEffect)
        )
    }
    
}
