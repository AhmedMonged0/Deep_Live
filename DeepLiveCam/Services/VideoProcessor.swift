import Foundation
import AVFoundation
import CoreImage
import UIKit

class VideoProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    
    private let context = CIContext()
    
    func processVideo(
        inputURL: URL,
        outputURL: URL,
        sourceImage: UIImage,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        isProcessing = true
        progress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.performVideoProcessing(
                    inputURL: inputURL,
                    outputURL: outputURL,
                    sourceImage: sourceImage
                )
                
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.progress = 1.0
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(false, error)
                }
            }
        }
    }
    
    private func performVideoProcessing(
        inputURL: URL,
        outputURL: URL,
        sourceImage: UIImage
    ) throws {
        let asset = AVAsset(url: inputURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            throw VideoProcessingError.noVideoTrack
        }
        
        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VideoProcessingError.compositionCreationFailed
        }
        
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: asset.duration),
            of: videoTrack,
            at: .zero
        )
        
        // Create video composition for processing
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = videoTrack.naturalSize
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Export the video
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoProcessingError.exportSessionCreationFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.videoComposition = videoComposition
        
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        
        exportSession.exportAsynchronously {
            if exportSession.status == .failed {
                exportError = exportSession.error
            }
            semaphore.signal()
        }
        
        // Update progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                self.progress = Double(exportSession.progress)
            }
            
            if exportSession.status != .exporting {
                timer.invalidate()
            }
        }
        
        semaphore.wait()
        
        if let error = exportError {
            throw error
        }
    }
    
    func createThumbnail(from videoURL: URL, at time: CMTime) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error creating thumbnail: \(error)")
            return nil
        }
    }
    
    func getVideoDuration(from videoURL: URL) -> CMTime? {
        let asset = AVAsset(url: videoURL)
        return asset.duration
    }
    
    func getVideoSize(from videoURL: URL) -> CGSize? {
        let asset = AVAsset(url: videoURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else { return nil }
        return videoTrack.naturalSize
    }
}

enum VideoProcessingError: Error, LocalizedError {
    case noVideoTrack
    case compositionCreationFailed
    case exportSessionCreationFailed
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            return "No video track found in the input file"
        case .compositionCreationFailed:
            return "Failed to create video composition"
        case .exportSessionCreationFailed:
            return "Failed to create export session"
        case .processingFailed:
            return "Video processing failed"
        }
    }
}
