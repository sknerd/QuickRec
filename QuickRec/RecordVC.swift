//
//  ViewController.swift
//  QuickRec
//
//  Created by renks on 14.01.2020.
//  Copyright © 2020 renks. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVC: UIViewController {
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var numberOfRecordings = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up recording session
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        #warning("Add Alert")// failed to record!
                    }
                }
            }
        } catch {
            #warning("Add Alert")// failed to record!
        }
    }
    
    
    func loadRecordingUI() {
        recordButton = QRButton(backgroundColor: .systemRed, title: "Tap to Record")
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            recordButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    func startRecording() {
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(numberOfRecordings).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
            recordButton.backgroundColor = .systemGray
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            recordButton.backgroundColor = .systemRed
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            recordButton.backgroundColor = .systemRed
            displayAlert(title: "Ouch", message: "Recording failed")
        }
    }
    
    
    @objc func recordTapped() {
        // Checking if we have an active recorder
        if audioRecorder == nil {
            numberOfRecordings += 1
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    
    // Getting the path to recordings directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Displaying alert
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
}

extension RecordVC: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

