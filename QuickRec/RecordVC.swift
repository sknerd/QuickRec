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
    var stopButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: URL!
    
    var numberOfRecordings: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureRecordingSession()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    fileprivate func configureViewController() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            view.backgroundColor = .white
        }
    }
    
    fileprivate func configureRecordingSession() {
        // Setting up recording session
        recordingSession = AVAudioSession.sharedInstance()
        
        if let number: Int = UserDefaults.standard.object(forKey: "myNumberOfRecordings") as? Int {
            numberOfRecordings = number
        }
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [weak self] allowed in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if allowed {
                        self.configureRecordButton()
                        self.configureStopButton()
                    } else {
                        self.displayAlert(title: "Failed to record", message: "We can't use microphone without your permission")
                    }
                }
            }
        } catch {
            displayAlert(title: "Whoops", message: "Failed to activate recording session")
        }
    }
    
    
    fileprivate func configureRecordButton() {
        recordButton = QRButton(backgroundColor: .systemRed, title: "Record")
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
//            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
//            recordButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    fileprivate func configureStopButton() {
        stopButton = QRButton(backgroundColor: .systemGray, title: "Stop")
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        stopButton.isEnabled = false
        view.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            stopButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
            stopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    fileprivate func startRecording() {
        
        audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(numberOfRecordings).m4a")
        
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
    
    
    fileprivate func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            UserDefaults.standard.set(numberOfRecordings, forKey: "myNumberOfRecordings")
            recordButton.setTitle("Record", for: .normal)
            recordButton.backgroundColor = .systemRed
        } else {
            recordButton.setTitle("Record", for: .normal)
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
    
    @objc func stopTapped() {
        print("Stop")
    }
    
    
    // Getting the path to recordings directory
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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

