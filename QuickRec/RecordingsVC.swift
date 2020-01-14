//
//  RecordingsVC.swift
//  QuickRec
//
//  Created by renks on 14.01.2020.
//  Copyright © 2020 renks. All rights reserved.
//

import UIKit
import AVFoundation

struct Recording {
    var name: String
    var path: URL
}

class RecordingsVC: UITableViewController {
    
    var audioPlayer: AVAudioPlayer!
    var recordings: [Recording] = []
    
    var numberOfRecordings: Int = 0
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
//        setupTableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRecordings()
    }
    
    fileprivate func configureViewController() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            view.backgroundColor = .white
        }
    }
    
    // Getting the path to recordings directory
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadRecordings() {
        self.recordings.removeAll()
        let filemanager = FileManager.default
        let path = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let paths = try filemanager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            for path in paths {
                let recording = Recording(name: path.lastPathComponent, path: path)
                self.recordings.append(recording)
            }
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
//        cell.textLabel?.text = String(indexPath.row + 1)
        let recording = self.recordings[indexPath.row]
        cell.textLabel?.text = recording.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDocumentsDirectory().appendingPathComponent("recording\(indexPath.row + 1).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            
        }
    }
}
