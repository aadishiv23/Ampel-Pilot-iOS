import Foundation
import UIKit
import CoreML

@available(iOS 12.0, *)
class YOLO {
    public static let inputWidth = 416//416//1088
    public static let inputHeight = 416//416//1088
    public static let maxBoundingBoxes = 10
    
    // Tweak these values to get more or fewer predictions.
    var confidenceThreshold: Double = 0.3
    var iouThreshold: Double = 0.45

    struct Prediction {
        let classIndex: Int
        let score: Float
        let rect: CGRect
    }

    let model = CrossBudV3()

    public init() { }
    
    public func predict(image: CVPixelBuffer) -> [Prediction]? {
        //let resizedImage = resizeImage(image, to: CGSize(width: YOLO.inputWidth, height: YOLO.inputHeight))
        //let resizedImage = resizePixelBuffer(image, width: 416, height: 416) ?? image
        let output = try? model.prediction(imagePath: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)

        if let boxesTensor = output?.coordinates,
           let confidencesTensor = output?.confidence {
            let boxes = boxesTensor
            let confidences = confidencesTensor
            
            return computeBoundingBoxes(boxes: boxes, confidences: confidences)
        } else {
            return nil
        }
    }

    func convertToDoubleArray(mlMultiArray: MLMultiArray) -> [Double] {
        let pointer = UnsafeMutablePointer<Double>(OpaquePointer(mlMultiArray.dataPointer))
        let count = mlMultiArray.count
        
        var doubleArray = [Double]()
        for i in 0..<count {
            let value = pointer[i]
            doubleArray.append(value)
        }
        
        return doubleArray
    }

    
    /*public func predict(image: CVPixelBuffer) -> [Prediction]? {
        let output = try? model.prediction(imagePath: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)

        let boxesTensor = output?.coordinates
        let confidencesTensor = output?.confidence
        
        if let boxesTensor = boxesTensor, let confidencesTensor = confidencesTensor {
            let boxes = boxesTensor.buffer.asReadOnly().float64Array
            let confidences = confidencesTensor.buffer.asReadOnly().float64Array
            
            return computeBoundingBoxes(boxes: boxes, confidences: confidences)
        } else {
            return nil
        }
    }*/


    /*public func predict(image: CVPixelBuffer) -> [Prediction]? {
        if let output = try? model.prediction(imagePath: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold),

           let boxesTensor = output.coordinates,
           let confidencesTensor = output.confidence {
            
            let boxes = boxesTensor.buffer.asReadOnly().float64Array
            let confidences = confidencesTensor.buffer.asReadOnly().float64Array
          
            return computeBoundingBoxes(boxes: boxes, confidences: confidences)
        } else {
            return nil
        }
    }*/

    //oldy w/ doubles
    /*public func computeBoundingBoxes(boxes: [Double], confidences: [Double]) -> [Prediction] {
        assert(boxes.count == confidences.count)

        var predictions = [Prediction]()
        let numBoxes = min(boxes.count / 4, confidences.count)

        for boxIndex in 0..<numBoxes {
            let xOffset = boxIndex * 4
            let yOffset = boxIndex

            let x = CGFloat(boxes[xOffset])
            let y = CGFloat(boxes[xOffset + 1])
            let width = CGFloat(boxes[xOffset + 2])
            let height = CGFloat(boxes[xOffset + 3])

            let confidence = Double(confidences[yOffset])

            if confidence > confidenceThreshold {
                let rect = CGRect(x: x, y: y, width: width, height: height)

                let prediction = Prediction(classIndex: 0, score: Float(confidence), rect: rect)
                predictions.append(prediction)
            }
        }
    
        
        // The new model already includes bounding box pruning, so no need for non-maximum suppression.
        return predictions
    }*/
    
    public func computeBoundingBoxes(boxes: MLMultiArray, confidences: MLMultiArray) -> [Prediction] {
        assert(boxes.shape[0].intValue == confidences.shape[0].intValue)
        
        var predictions = [Prediction]()
        let numBoxes = min(boxes.shape[0].intValue / 4, confidences.shape[0].intValue)
        
        for boxIndex in 0..<numBoxes {
            let xOffset = boxIndex * 4
            let yOffset = boxIndex
            
            let x = CGFloat(truncating: boxes[xOffset])
            let y = CGFloat(truncating: boxes[xOffset + 1])
            let width = CGFloat(truncating: boxes[xOffset + 2])
            let height = CGFloat(truncating: boxes[xOffset + 3])
            
            let confidence = Double(truncating: confidences[yOffset])
            
            let epsilon = 0.000001
            if confidence >= (confidenceThreshold+epsilon) {
                let rect = CGRect(x: x, y: y, width: width, height: height)
                
                let prediction = Prediction(classIndex: 0, score: Float(confidence), rect: rect)
                predictions.append(prediction)
            }
        }
        
        return predictions
    }
    
    
    
    /*func resizeImage(_ image: CVPixelBuffer, to size: CGSize) -> CVPixelBuffer? {
        var resizedPixelBuffer: CVPixelBuffer?
        let ciImage = CIImage(cvPixelBuffer: image)
        
        let scaleX = size.width / CGFloat(CVPixelBufferGetWidth(image))
        let scaleY = size.height / CGFloat(CVPixelBufferGetHeight(image))
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        //let outputImage = ciImage.transformed(by: scaleTransform)
        let outputImage = CIImage(cvImageBuffer: image)

        /*let options: [CIImageOption: Any] = [
            .colorSpace: CGColorSpaceCreateDeviceRGB(),
            .kCIImagePixelFormat: kCVPixelFormatType_32BGRA
        ]*/
        
        guard let resizedCIImage = outputImage.transformed(by: scaleTransform),
                 let resizedCGImage = ciContext.createCGImage(resizedCIImage, from: resizedCIImage.extent) else {
               return nil
           }
        
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, nil, &resizedPixelBuffer)
        if let resizedPixelBuffer = resizedPixelBuffer {
            CVPixelBufferLockBaseAddress(resizedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(resizedPixelBuffer)
            
            let bytesPerRow = CVPixelBufferGetBytesPerRow(resizedPixelBuffer)
            let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            context?.draw(resizedCGImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            CVPixelBufferUnlockBaseAddress(resizedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        return resizedPixelBuffer
    }*/
}
