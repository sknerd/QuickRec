//
//  ViewController.swift
//  QuickRec
//
//  Created by renks on 14.01.2020.
//  Copyright © 2020 renks. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

class RecordVC: UIViewController {
    
    // MARK: - Properties
    
    var recordButton: UIButton!
    var stopButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: URL!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureRecordingSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    
    // MARK: - Setup Methods
    
    fileprivate func configureViewController() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            view.backgroundColor = .white
        }
    }
    
    
    fileprivate func configureRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
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
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            recordButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    fileprivate func configureStopButton() {
        stopButton = QRButton(backgroundColor: .systemGray, title: "Stop")
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        stopButton.isEnabled = false
        view.addSubview(stopButton)
        stopButton.alpha = 0.1
        
        NSLayoutConstraint.activate([
            stopButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
            stopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Recording
    
    fileprivate func startRecording() {
        audioFilename = self.createAudioFilePath()
        
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
            
            recordButton.isEnabled = false
            stopButton.isEnabled = true
            recordButton.setTitle("Recording...", for: .normal)
            recordButton.setTitleColor(.systemRed, for: .normal)
            recordButton.layer.borderColor = UIColor.gray.cgColor
            recordButton.layer.borderWidth = 1
            
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = .systemRed
                self.recordButton.backgroundColor = .white
                self.stopButton.alpha = 1
                self.stopButton.setTitleColor(.white, for: .normal)
                self.stopButton.setTitle("Stop and save", for: .normal)
                self.stopButton.backgroundColor = .systemBlue
            }
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    fileprivate func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Record", for: .normal)
            recordButton.setTitleColor(.white, for: .normal)
            recordButton.backgroundColor = .systemRed
            
            if let tabItems = tabBarController?.tabBar.items {
                let tabItem = tabItems[1]
                tabItem.badgeValue = "New"
            }
            
        } else {
            recordButton.setTitle("Record", for: .normal)
            recordButton.backgroundColor = .systemRed
            displayAlert(title: "Ouch", message: "Recording failed")
        }
    }
    
    // MARK: - Actions
    
    @objc fileprivate func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc fileprivate func stopTapped() {
        if audioRecorder != nil {
            finishRecording(success: true)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                if #available(iOS 13.0, *) {
                    self.view.backgroundColor = .systemBackground
                } else {
                    self.view.backgroundColor = .white
                }
                    self.stopButton.alpha = 0.3
                    self.stopButton.setTitle("Saved!", for: .normal)
                    self.stopButton.setTitleColor(.systemGray, for: .normal)
                    self.stopButton.backgroundColor = .white
                    self.recordButton.isEnabled = true
                    self.recordButton.layer.borderWidth = 0
                })
        }
    }
    
    // MARK: - File path
    fileprivate func createAudioFilePath() -> URL? {
        let format = DateFormatter()
        format.dateFormat = "yyyy.MM.dd_HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date()))" + ".m4a"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appendingPathComponent(currentFileName)
        return url
    }
    

    fileprivate func displayAlert(title: String, message: String) {
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

