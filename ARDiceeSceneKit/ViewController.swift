//
//  ViewController.swift
//  ARDiceeSceneKit
//
//  Created by Sekaye Knutson on 10/6/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
   
   @IBOutlet var sceneView: ARSCNView!
   var diceArray: [SCNNode] = [ ]

   @IBAction func reRollPressed(_ sender: UIButton) {
      rollAll()
   }
   @IBAction func resetPressed(_ sender: UIButton) {
      if !diceArray.isEmpty {
         for dice in diceArray {
            dice.removeFromParentNode()
         }
      }
   }
   
   override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
      rollAll()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
//      self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
      
      // Set the view's delegate
      sceneView.delegate = self
      
      sceneView.autoenablesDefaultLighting = true
      
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      // Create a session configuration
      let configuration = ARWorldTrackingConfiguration()
      
      configuration.planeDetection = .horizontal
      
      // Run the view's session
      sceneView.session.run(configuration)
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      
      // Pause the view's session
      sceneView.session.pause()
   }
   
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first {
         let touchLocation = touch.location(in: sceneView)
         
         //convert 2d touch to 3d location
         
         let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)
         
         guard let safeQuery = query
         else { print("query is nil")
            return
         }
         
         let results: [ARRaycastResult] = sceneView.session.raycast(safeQuery)
         
         if results.isEmpty {
            print("no results detected")
         }
         else {
            
            let diceScene = SCNScene(named: "art.scnassets/dice.scn")
            
            let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true)
            
            let touchResult = results.first
            
            diceNode?.position = SCNVector3(
               touchResult!.worldTransform.columns.3.x,
               touchResult!.worldTransform.columns.3.y + diceNode!.boundingSphere.radius,
               touchResult!.worldTransform.columns.3.z)
            
            guard let safeNode = diceNode else {
               fatalError("failed to add node to scene")
            }
            
            
            diceArray.append(safeNode)
            sceneView.scene.rootNode.addChildNode(safeNode)
            roll(dice: safeNode)
         
            
//            diceNode?.runAction(SCNAction.move(by: SCNVector3(0, -0.2, 0), duration: 0.5))

         }
         
         
      }
   }
   // responds to new planes being detected, allowing you to render objects
   func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      if anchor is ARPlaneAnchor {
         
         let planeAnchor = anchor as! ARPlaneAnchor
         
//         let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
         
         let planeNode = SCNNode()
         
         planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
         
         planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
         
//         let gridMaterial = SCNMaterial()
//
//         gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/texture")
//
//         plane.materials = [gridMaterial]
         
//         planeNode.geometry = plane
         
         node.addChildNode(planeNode)
      }
   }
   
   func rollAll() {
      if !diceArray.isEmpty {
         for dice in diceArray {
            roll(dice: dice)
         }
      }
   }
   
   func roll(dice: SCNNode) {
      let randomX = Float(arc4random_uniform(4) + 1) * Float.pi/2
      
      let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi/2
      
      
      dice.runAction(SCNAction.move(by: SCNVector3(0, 0.1, 0), duration: 0.2))
      dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
      Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
         dice.runAction(SCNAction.move(by: SCNVector3(0, -0.1, 0), duration: 0.2))
      }
   }
   
   
}
