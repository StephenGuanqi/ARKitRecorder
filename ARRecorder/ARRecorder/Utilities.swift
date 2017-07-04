//
//  Utilities.swift
//  MyARDemo
//
//  Created by Guanqi Yu on 22/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

import Foundation
import ARKit

extension SCNMaterial {
    static func material(withDiffuse diffuse: Any?, respondsToLighting: Bool = true) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = diffuse
        material.isDoubleSided = true
        if respondsToLighting {
            material.locksAmbientWithDiffuse = true
        } else {
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = diffuse
        }
        return material
    }
}

func createPlane(size: CGSize, contents: AnyObject) -> SCNPlane {
    let plane = SCNPlane(width: size.width, height: size.height)
    plane.materials = [SCNMaterial.material(withDiffuse: contents)]
    return plane
}

// MARK: - Get File Path to Write
func getDocumentsDirectory() -> String {
    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    return dirPath
}

func getFilePath(fileFolder folderName:String, fileName fileName: String) -> String {
    let dirPath = getDocumentsDirectory()
    let filePath = NSURL(fileURLWithPath: dirPath).appendingPathComponent(folderName)?.path
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath!) == false{
        do {
            try  fileManager.createDirectory(atPath: filePath!, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    let pathArray = [filePath!, fileName]
    return pathArray.joined(separator: "/")
}

// MARK: - Matrix Transform

func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
    return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
}

func arrayFromTransform(_ transform: matrix_float4x4) -> [[Float]] {
    var array: [[Float]] = Array(repeating: Array(repeating:Float(), count: 4), count: 4)
    array[0] = [transform.columns.0.x, transform.columns.1.x, transform.columns.2.x, transform.columns.3.x]
    array[1] = [transform.columns.0.y, transform.columns.1.y, transform.columns.2.y, transform.columns.3.y]
    array[2] = [transform.columns.0.z, transform.columns.1.z, transform.columns.2.z, transform.columns.3.z]
    array[3] = [transform.columns.0.w, transform.columns.1.w, transform.columns.2.w, transform.columns.3.w]
    return array
}

func arrayFromTransform(_ transform: matrix_float3x3) -> [[Float]] {
    var array: [[Float]] = Array(repeating: Array(repeating:Float(), count: 3), count: 3)
    array[0] = [transform.columns.0.x, transform.columns.1.x, transform.columns.2.x]
    array[1] = [transform.columns.0.y, transform.columns.1.y, transform.columns.2.y]
    array[2] = [transform.columns.0.z, transform.columns.1.z, transform.columns.2.z]
    return array
}

func dictFromVector3(_ vector: SCNVector3) -> [String: Float] {
    return ["x": vector.x, "y": vector.y, "z": vector.z]
}

func dictFromVector3(_ vector: vector_float3) -> [String: Float] {
    return ["x": vector.x, "y": vector.y, "z": vector.z]
}

func arrayFromPointCloud(_ pointCloud: ARPointCloud?) -> [[Float]] {
    var array = [[Float]]()
    if let points = pointCloud?.points {
        for featurePoint in UnsafeBufferPointer(start: points, count: pointCloud!.count) {
            array.append([featurePoint.x, featurePoint.y, featurePoint.z])
        }
    }
    return array
}

// MARK: - File Name
func getCurrentTime() -> String {
    let date = Date()
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let second = calendar.component(.second, from: date)
    return String(day)+"-"+String(hour)+"-"+String(minutes)+"-"+String(second)
}

func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext(options: nil)
    let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
    let uiImage = UIImage(cgImage: cgImage!)
    return uiImage
}
