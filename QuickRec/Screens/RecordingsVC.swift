//
//  RecordingsVC.swift
//  QuickRec
//
//  Created by renks on 14.01.2020.
//  Copyright © 2020 renks. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingsVC: UITableViewController {
    
    // MARK: - Properties
    
    var audioPlayer: AVAudioPlayer!
    var recordings: [Recording] = []
    let cellId = "cellId"
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRecordings()
        
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeValue = nil
        }
    }
    
    // MARK: - Setup
    
    fileprivate func configureViewController() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            view.backgroundColor = .white
        }
    }
    
    // MARK: - Data
    
    fileprivate func loadRecordings() {
        self.recordings.removeAll()
        var unsorted: [Recording] = []
        let filemanager = FileManager.default
        let path = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let paths = try filemanager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            for path in paths {
                
                let recording = Recording(name: path.lastPathComponent, path: path)
                unsorted.append(recording)
            }
            self.recordings = unsorted.sorted {$0.name < $1.name}
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Playback
    
    fileprivate func play(url: URL) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.caf.rawValue)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        if let player = self.audioPlayer {
            player.delegate = self
//            player.prepareToPlay()
//            player.volume = 1.0
            player.play()
        }
    }
    
    
    fileprivate func stopPlay() {
        if let paths = self.tableView.indexPathsForSelectedRows {
            for path in paths {
                self.tableView.deselectRow(at: path, animated: true)
            }
        }
        
        if let player = self.audioPlayer {
            player.pause()
        }
        self.audioPlayer = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    fileprivate func isPlaying() -> Bool {
        if let player = self.audioPlayer {
            return player.isPlaying
        }
        return false
    }
    
    
    
    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let recording = self.recordings[indexPath.row]
        cell.textLabel?.text = recording.name
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isPlaying() {
            self.stopPlay()
        }
        let recording = recordings[indexPath.row]
        self.play(url: recording.path)
    }
   
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let filemanager = FileManager.default
            let recording = self.recordings[indexPath.row]
            do {
                try filemanager.removeItem(at: recording.path)
                self.recordings.remove(at: indexPath.row)
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Error while deleteing", error.localizedDescription)
            }
        }
    }
}


extension RecordingsVC: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        self.stopPlay()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stopPlay()
    }
}
