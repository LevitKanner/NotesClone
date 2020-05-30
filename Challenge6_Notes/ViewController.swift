//
//  ViewController.swift
//  Challenge6_Notes
//
//  Created by Levit Kanner on 30/05/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var savedNotes = [Note(text: "this is going to be fun")]
    var count: UIBarButtonItem?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        getNotes()
        tableView.reloadData()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let create = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNote))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        count = UIBarButtonItem(title: savedNotes.count == 1 ? "\(savedNotes.count) note" : "\(savedNotes.count) notes", style: .plain, target: self, action: nil)
        count?.tintColor = .black
        
        toolbarItems = [spacer, count! , spacer , create]
        navigationController?.isToolbarHidden = false
        navigationController?.view.tintColor = .brown
        
        getNotes()
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        savedNotes.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath)
        let note = savedNotes[indexPath.row]
        cell.textLabel?.text = note.title
        return cell
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let noteView = storyboard?.instantiateViewController(identifier: "noteview") as? TextViewController else { return }
        let note = savedNotes[indexPath.row]
        noteView.note = note
        noteView.index = indexPath.row
        navigationController?.pushViewController(noteView, animated: true)
    }
    
    
    
    func getDocumentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    
    
    func getNotes() {
        let url = getDocumentDirectory().appendingPathComponent("notes")
        
        guard let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        
        do {
            savedNotes = try decoder.decode([Note].self, from: data)
            count?.title = savedNotes.count == 1 ? "\(savedNotes.count) note" : "\(savedNotes.count) notes"
            tableView.reloadData()
        }catch{
            debugPrint(error)
        }
    }
    
    
    
    @objc func createNote() {
        guard let noteView = storyboard?.instantiateViewController(identifier: "noteview") as? TextViewController else { return }
        navigationController?.pushViewController(noteView, animated: true)
    }
    
}

