//
//  AddViewController.swift
//  ArtBook
//
//  Created by Admin on 21.08.2021.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var artistField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var isCustomImageSelected = false
    var paintingId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewTap = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        view.addGestureRecognizer(viewTap)
        
        imageView.isUserInteractionEnabled = true;
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(onImageTap))
        imageView.addGestureRecognizer(imageTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("paintingId", paintingId?.uuidString ?? "none")
        isCustomImageSelected = false
        saveButton.isEnabled = false
        if paintingId != nil {
            saveButton.isHidden = true
            getPainting()
        } else {
            // navigationController?.navigationBar.topItem?.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveBar))]
            
            // same issue without using the array
            navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveBar))
        }
    }
    
    func getPainting(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        request.predicate = NSPredicate(format: "id = %@", paintingId!.uuidString)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
            if results.count != 1 {
                print("not found only one")
                return
            }
            let result = results[0]
            
            let _name = result.value(forKey: "name") as? String
            let _artist = result.value(forKey: "artist") as? String
            let _yearInt = result.value(forKey: "year") as? Int
            let _imageData = result.value(forKey: "image") as? Data
            if _name != nil && _artist != nil && _yearInt != nil && _imageData != nil {
                nameField.text = _name
                artistField.text = _artist
                yearField.text = String(_yearInt!)
                imageView.image = UIImage(data: _imageData!)
            }
        } catch {
            print("error on gePainting")
        }
        
    }

    @IBAction func onSave(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let data = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        
        data.setValue(UUID(), forKey: "id")
        
        if imageView.image == nil {
            return
        }
        if let imageData = imageView.image?.jpegData(compressionQuality: 0.8) {
            data.setValue(imageData, forKey: "image")
        }
        if let name = nameField.text {
            data.setValue(name, forKey: "name")
        } else {
            return
        }
        if let artist = artistField.text {
            data.setValue(artist, forKey: "artist")
        } else {
            return
        }
        if let yearString = yearField.text {
            if let year = Int(yearString) {
                data.setValue(year, forKey: "year")
            } else {
                return
            }
        } else {
            return
        }
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func onImageTap(){
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        if selectedImage != nil {
            imageView.image = selectedImage
            isCustomImageSelected = true
        }
        dismiss(animated: true, completion: nil)
        checkIfCanSave()
    }
    
    @objc func onViewTap(){
        view.endEditing(true)
    }
    
    @objc func onSaveBar(){
        print("onSave BarButton")
    }
    
    func checkIfCanSave(){
        saveButton.isEnabled = true
        if isCustomImageSelected == false {
            saveButton.isEnabled = false
        }
        if let nameText = nameField.text {
            if nameText.count < 1 {
                saveButton.isEnabled = false
            }
        }
        if let artistText = artistField.text {
            if artistText.count < 1 {
                saveButton.isEnabled = false
            }
        }
        if let yearText = yearField.text {
            if yearText.count < 4 {
                saveButton.isEnabled = false
            }
        }
    }
    
    @IBAction func onNameEdited(_ sender: Any) {
        checkIfCanSave()
    }
    
    @IBAction func onArtistEdited(_ sender: Any) {
        checkIfCanSave()
    }
    
    @IBAction func onYearEdited(_ sender: Any) {
        checkIfCanSave()
    }
}
