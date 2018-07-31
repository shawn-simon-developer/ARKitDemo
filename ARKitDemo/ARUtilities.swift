//
//  ARUtilities.swift
//  ARKitDemo
//
//  Created by Shawn Simon on 2018-07-31.
//  Copyright © 2018 Shawn Simon. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ARUtilities {
    
    /// Provides a rough representation of a found horizontal plane for a temp
    /// amount of time.
    ///
    /// - Parameters:
    ///   - node: Found node
    ///   - anchor: Found anchor
    static func createTempPlaneObjectFor(node: SCNNode, andAnchor anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let size = planeAnchor.extent.x > planeAnchor.extent.z ? planeAnchor.extent.x : planeAnchor.extent.z
        let width = CGFloat(size)
        let height = CGFloat(size)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor(red: 41/255.0, green: 128/255.0, blue: 185/255.0, alpha: 0.7)
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            planeNode.removeFromParentNode()
        })
    }
}
