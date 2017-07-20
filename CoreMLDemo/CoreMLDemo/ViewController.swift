//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by dgpCharles on 2017/7/20.
//  Copyright © 2017年 dgpCharles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let perdictionManager = PredictionService()
    var resultList: [PredictionResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func addPhoto(_ sender: Any) {
        present(addAlertController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    fileprivate lazy var addAlertController: UIAlertController = {
        let cameraRoll = UIAlertAction(title: "Camera Roll", style: .default, handler: { [unowned self] (action) -> Void in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        
        let takePhoto = UIAlertAction(title: "Take one", style: .default, handler: { [unowned self] (action) -> Void in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)

        })
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { [unowned self] (action) -> Void in })

        let alert = UIAlertController(title: "Add photo",
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(cameraRoll)
        alert.addAction(takePhoto)
        alert.addAction(cancel)

        return alert
    }()
    fileprivate func didChoose(image:UIImage) {
        photoView.image = image
        if let predictions = self.perdictionManager.predict(image: image) {
            self.resultList = predictions
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.didChoose(image: image)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPredictionCell", for: indexPath)
        
        let resultItem = resultList[indexPath.row]
        cell.textLabel?.text = resultItem.possiblePrediction
        cell.detailTextLabel?.text = String(format: "%.02f", resultItem.probability)
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Predictions"
    }
}
