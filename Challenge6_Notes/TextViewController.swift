//
//  TextViewController.swift
//  Challenge6_Notes
//
//  Created by Levit Kanner on 30/05/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit

class TextViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var textView: UITextView!
    var note: Note?
    var savedNotes = [Note]()
    var index: Int?
   
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNotes()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        
        let deleteBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        let cameraBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraTapped))
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbarItems = [deleteBtn , spacer , cameraBtn , spacer , compose]
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        configureView(note: note)
        getNotes()
    }
    
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let KeyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return}
        let keyboardFrame = KeyboardValue.cgRectValue
        
        let keyboardViewEndFrame = view.convert(keyboardFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        }else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    
    
    func configureView(note: Note?) {
        textView.text = note?.text ?? ""
    }
    
    
    
    @objc func shareNote() {
        let shareController = UIActivityViewController(activityItems: [textView.text ?? "note"], applicationActivities: [])
        shareController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(shareController, animated: true, completion: nil)
    }
    
    
    
    @objc func deleteNote() {
        guard let index = index else { return }
        _ = savedNotes.remove(at: index)
        
        let encoder = JSONEncoder()
        guard let notesData = try? encoder.encode(savedNotes) else { return }
        let location = getDocumentDirectory().appendingPathComponent("notes")
        do{
            try notesData.write(to: location, options: [.atomicWrite])
        }catch{
            debugPrint(error)
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func cameraTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        }else {
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @objc func composeTapped() {
        navigationController?.popViewController(animated: true)
        guard let noteView = storyboard?.instantiateViewController(identifier: "noteview") as? TextViewController else { return }
        navigationController?.pushViewController(noteView, animated: true)
    }
    
    
    
    func saveNotes() {
        guard !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&  textView.text != note?.text  else  { return }
        
        let newNote = Note(text: textView.text)
        
        if let index = index {
            savedNotes[index] = newNote
        }else{
            savedNotes.insert(newNote, at: 0)
        }
        
        
        //Save Notes to file directory
        let encoder = JSONEncoder()
        guard let notesData = try? encoder.encode(savedNotes) else { return }
        let location = getDocumentDirectory().appendingPathComponent("notes")
        do{
            try notesData.write(to: location, options: [.atomicWrite])
        }catch{
            debugPrint(error)
        }
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
        }catch{
            debugPrint(error)
        }
    }
}
