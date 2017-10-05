//
//  ViewController.swift
//  tryAR
//
//  Created by Tong Lin on 10/5/17.
//  Copyright © 2017 tonglin.t91@gmail.com. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var nodeModel:SCNNode!
    let nodeName = "ship"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        sceneView.antialiasingMode = .multisampling4X
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        self.nodeModel =  scene.rootNode.childNode(withName: nodeName, recursively: true)
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
//
//        var hitTestOptions = [SCNHitTestOption: Any]()
//        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
//        let hitResults: [SCNHitTestResult] = sceneView.hitTest(location, options: hitTestOptions)
//
//        for hit in hitResults {
//            if let node = getParent(hit.node) {
//                node.removeFromParentNode()
//                return
//            }
//        }
        
        
        let hitResultsFeaturePoints: [ARHitTestResult] = sceneView.hitTest(location, types: .featurePoint)
        
        if let hit = hitResultsFeaturePoints.first {
            // Get a transformation matrix with the euler angle of the camera
            let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
            
            // Combine both transformation matrices
            let finalTransform = simd_mul(hit.worldTransform, rotate)
            
            // Use the resulting matrix to position the anchor
            self.cleanScene(sceneView.scene.rootNode)
            sceneView.session.add(anchor: ARAnchor(transform: finalTransform))
            // sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
        }
    }
    
    func cleanScene(_ rootNode: SCNNode?) {
        guard let root = rootNode else { return }
        
        for node in root.childNodes {
//            if node.name == nodeName {
                node.removeFromParentNode()
//            }
        }
        
//        if let node = nodeFound {
//            if node.name == nodeName {
//                return node
//            } else if let parent = node.parent {
//                return getParent(parent)
//            }
//        }
//        return nil
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
}

extension ViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("Session Failed - probably due to lack of camera access")
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        
    }
    
    /*
     Called when a SceneKit node corresponding to a
     new AR anchor has been added to the scene.
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone = self.nodeModel.clone()
                modelClone.position = SCNVector3Zero
                // Add model as a child of the node
                node.addChildNode(modelClone)
            }
        }
    }
    
    /*
     Called when a SceneKit node's properties have been
     updated to match the current state of its corresponding anchor.
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // ...
    }
    
    /*
     Called when SceneKit node corresponding to a removed
     AR anchor has been removed from the scene.
     */
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // ...
    }
}
