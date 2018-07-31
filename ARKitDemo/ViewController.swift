//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Shawn Simon on 2018-07-31.
//  Copyright © 2018 Shawn Simon. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @objc func handleTap(tap: UITapGestureRecognizer) {
        let results = self.sceneView.hitTest(tap.location(in: sceneView), types: [ARHitTestResult.ResultType.estimatedHorizontalPlane])
        guard let hitResult = results.last else {
            statusLabel.text = "Point on plane not valid."
            return
        }
        guard let anchor = sceneView.session.currentFrame?.anchors.last else {
            statusLabel.text = "No horizontal surface found yet."
            return
        }
        let hitTransform = SCNMatrix4.init(hitResult.worldTransform)
        let hitVector = SCNVector3(hitTransform.m41, anchor.transform.columns.3.y, hitTransform.m43)
        statusLabel.text = "\(hitVector.x), \(hitVector.y), \(hitVector.z)"
        createItem(position: hitVector)
    }

    func createItem(position: SCNVector3) {
        let itemNode = SCNScene(named: "art.scnassets/Tree.scn")!.rootNode
        itemNode.position = position
        sceneView.scene.rootNode.addChildNode(itemNode)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    // Tells the delegate that a SceneKit node corresponding to a new AR anchor has been added
    // to the scene. In this case, the plane.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = "Horizontal plane found!"
        }
        // Add plane anchor to session for less drift.
        sceneView.session.add(anchor: anchor)
        ARUtilities.createTempPlaneObjectFor(node: node, andAnchor: anchor)
    }
}
