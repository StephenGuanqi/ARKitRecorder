//
//  ViewController.swift
//  ARRecorder
//
//  Created by Guanqi Yu on 26/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    var jsonObject = [String:Any]()
    var recordStartTime: String?
    
    enum RecordingState {
        case recording
        case notRecording
    }
    
    var currentState = RecordingState.notRecording
    var previousState = RecordingState.notRecording
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //other sceneView configuration
        sceneView.preferredFramesPerSecond = 30
        sceneView.automaticallyUpdatesLighting = false
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
        
        //register tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureRecognize:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.isLightEstimationEnabled = true
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
    
    // MARK: - Handle Tap
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
        
    }
    
    func currentFrameInfoToDic(currentFrame: ARFrame) -> [String: Any] {
        
        let currentTime:String = String(format:"%f", currentFrame.timestamp)
        let imageName = currentTime + ".jpg"
        let jsonObject: [String: Any] = [
            "imageName": imageName,
            "timeStamp": currentFrame.timestamp,
            "cameraPos": dictFromVector3(positionFromTransform(currentFrame.camera.transform)),
            "cameraEulerAngle": dictFromVector3(currentFrame.camera.eulerAngles),
            "cameraTransform": arrayFromTransform(currentFrame.camera.transform),
            "cameraIntrinsics": arrayFromTransform(currentFrame.camera.intrinsics),
            "imageResolution": [
                "width": currentFrame.camera.imageResolution.width,
                "height": currentFrame.camera.imageResolution.height
            ],
            "lightEstimate": currentFrame.lightEstimate?.ambientIntensity,
            "ARPointCloud": [
                "count": currentFrame.rawFeaturePoints?.count,
                "points": arrayFromPointCloud(currentFrame.rawFeaturePoints)
            ]
        ]
        
        return jsonObject
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if recordButton!.isHighlighted {
            currentState = RecordingState.recording
            if recordStartTime == nil {
                recordStartTime = getCurrentTime()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let jsonNode = self.currentFrameInfoToDic(currentFrame: frame)
                self.jsonObject[jsonNode["imageName"] as! String] = jsonNode
                let jpgImage = UIImageJPEGRepresentation(pixelBufferToUIImage(pixelBuffer: frame.capturedImage), 1.0)
                try? jpgImage?.write(to: URL(fileURLWithPath: getFilePath(fileFolder: self.recordStartTime!, fileName: jsonNode["imageName"] as! String)))
            }
            
        } else if previousState == RecordingState.recording {
            print("state into not highlighted")
            currentState = RecordingState.notRecording
            DispatchQueue.global(qos: .userInitiated).async {
                let valid = JSONSerialization.isValidJSONObject(self.jsonObject)
                if valid {
                    let json = JSON(self.jsonObject)
                    let representation = json.rawString([.castNilToNSNull: true])
                    let jsonFilePath = getFilePath(fileFolder: self.recordStartTime!, fileName: getCurrentTime()+".json")
                    do {
                        try representation?.description.write(toFile: jsonFilePath, atomically: false, encoding: String.Encoding.utf8)
                        
                    }catch {
                            print("write json failed...")
                    }
                } else {
                    print("the json object to write is not valid")
                }
                self.jsonObject.removeAll()
                self.recordStartTime = nil
            }
        }
        previousState = currentState
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
