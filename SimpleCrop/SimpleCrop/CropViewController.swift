//
//  CropViewController.swift
//  SimpleCrop
//
//  Created by Jing Lin on 3/1/19.
//  Copyright © 2019 Jing Lin. All rights reserved.
//

import UIKit
import AVFoundation

class CropViewController: UIViewController {

    let captureSession = AVCaptureSession()
    let previewView = PreviewView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(self.previewView)
        addConstraints()
        
        checkAuthorizationStatus()
    }
    
    func addConstraints() {
        self.view.addConstraints(SConstraint.paddingPositionConstraints(view: self.previewView, sides: [.top, .left, .bottom, .right], padding: 0))
    }
    
    func checkAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized: // The user previously granted access to the camera
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if (granted) {
                    self.setupCaptureSession()
                }
            }
        case .denied:
            return
        case .restricted:
            return
        }
    }
    
    func setupCaptureSession() {
        configureSession()
        runSession()
    }
    
    func configureSession() {
        self.captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            self.captureSession.canAddInput(videoDeviceInput)
            else { return }
        
        self.captureSession.addInput(videoDeviceInput)
        
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        self.captureSession.commitConfiguration()
        
        self.previewView.videoPreviewLayer.session = self.captureSession
    }
    
    func runSession() {
        self.captureSession.startRunning()
    }

}

