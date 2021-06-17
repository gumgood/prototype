//
//  RecognizeText.swift
//  prototype
//
//  Created by 이상원 on 2021/06/17.
//

import SwiftUI
import MLKit
import AVFoundation

extension CameraViewController {
    
    // MARK:- Main Task
    
    internal func recognizeText(image: VisionImage){
        
        var resultBlocks: [TextBlock] = []
        
        do{
            // vertical recognition
            // ?
            
            // horizon recognition
            image.orientation = .right
            resultBlocks.append(contentsOf: try TextRecognizer.textRecognizer().results(in: image).blocks)
            
            // top-bottom recognition
            image.orientation = .up
            resultBlocks.append(contentsOf: try TextRecognizer.textRecognizer().results(in: image).blocks)
            
            // bottom-top recognition
            image.orientation = .down
            resultBlocks.append(contentsOf: try TextRecognizer.textRecognizer().results(in: image).blocks)
            
        } catch{ return }
        
        DispatchQueue.main.sync{
            self.removeBox()
            
            for block in resultBlocks {
                for line in block.lines{
            
                    if showAllBox {
                        drawBox(frame: line.frame, color: UIColor.green.cgColor)
                    }else {
                        let ratio = matchingRatio(text: line.text)
                        if(filterRatio >= ratio) {
                            let color = determineColor(ratio: ratio)
                            self.drawBox(frame: line.frame, color: color)
                        } else{
                            for element in line.elements {
                                let ratio = matchingRatio(text: element.text)
                                if filterRatio >= ratio {
                                    let color = determineColor(ratio: ratio)
                                    self.drawBox(frame: element.frame, color: color)
                                }
                            }
                        }
                    }
                    
                }
            } // End of resultBlocks
            
        } // End of DispatchQueue
        
    } // End of recognizeText
    
    // MARK:- Calculate Matcing Ratio
    
    private func matchingRatio(text: String) -> Double{
        let text = text.replacingOccurrences(of: " ", with: "").lowercased()
        
        let n = bookTitle.count, m = text.count
        var dp = [[Int]](repeating: Array(repeating: 0, count: m+1), count: n+1)
        
        for (i, _) in bookTitle.enumerated() {
            dp[i+1][0] = i+1
        }
        for (j, _) in text.enumerated() {
            dp[0][j+1] = j+1
        }
        for (i, s) in bookTitle.enumerated(){
            for (j, t) in text.enumerated(){
                if s == t {
                    dp[i+1][j+1] = dp[i][j]
                } else {
                    dp[i+1][j+1] = min(dp[i][j], dp[i+1][j], dp[i][j+1]) + 1
                }
            }
        }
        
        return Double(dp[n][m]) / Double(n)
    }
    
    // MARK:- Determine Color
    
    private func determineColor(ratio: Double) -> CGColor {
        // ratio : 0.0 ~ 2.0
        if ratio <= 0.3 {
            return CGColor(red: CGFloat(0.0), green: CGFloat(1.0), blue: CGFloat(0.0), alpha: CGFloat(1.0)) // Green
        } else if ratio <= 0.5{
            return CGColor(red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0)) // Red
        } else {
            return CGColor(red: CGFloat(0.3), green: CGFloat(0.3), blue: CGFloat(0.3), alpha: CGFloat(1.0)) // Gray
        }
    }
}
