//
//  ViewController.swift
//  ArtBook
//
//  Created by Admin on 21.08.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var paintings = [NSManagedObject]()
    var selectedPaintingId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd))]
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedPaintingId = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name?.init(NSNotification.Name.init("newData")), object: nil)
    }
    
    @objc func getData(){
        paintings.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
            for result in results {
                paintings.append(result)
            }
        } catch {
            print("error on getData")
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paintings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = paintings[indexPath.row].value(forKey: "name") as? String ?? "Corrupted Data"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaintingId = paintings[indexPath.row].value(forKey: "id") as? UUID
        performSegue(withIdentifier: "toAddViewController", sender: self);
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(paintings[indexPath.row])
        do {
            try context.save()
            paintings.remove(at: indexPath.row)
            tableView.reloadData()
        } catch {
            print("failed to save")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "toAddViewController" {
            return
        }
        if let addViewController = segue.destination as? AddViewController {
            addViewController.paintingId = selectedPaintingId
        }
    }

    @objc func onAdd(){
        performSegue(withIdentifier: "toAddViewController", sender: self);
    }

}

