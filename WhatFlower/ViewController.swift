//
//  ViewController.swift
//  WhatFlower
//
//  Created by David Deschamps on 28/06/2021.
//

import UIKit
import Vision
import CoreML
import Alamofire
import SwiftyJSON
import MLKitTranslate

class ViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    
    var flowerManager = FlowerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        flowerManager.delegate = self
        
    }

    @IBAction func photoButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(flowerImage: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerImageClassifier1().model) else {
            fatalError("Error getting model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Error convert result")
            }
            
            if let flowerName = result.first?.identifier {
                
                self.flowerManager.fetchData(flowerName: flowerName.capitalized)
            }
            
            
            
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do {
            try handler.perform([request])

        } catch  {
            print("Errors : \(error)")
        }
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let image = CIImage(image: userPickedImage) else {
                fatalError("Could not convert image")
            }
            
            detect(flowerImage: image)
                
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension ViewController: FlowerManagerDelegate {
    func didUpdate(_ flowerManager: FlowerManager, _ result: FlowerDataModel) {
        DispatchQueue.main.async {
            self.descriptionLabel.text = result.description == "" ? "Aucune description disponible" : result.description
            self.navigationItem.title = result.name.capitalized 
            self.imageView.sd_setImage(with: URL(string: result.imageUrl))
//            self.translate(name: result.name, description: result.description)
        }
    }
    
    func didFailWithError(error: Error) {
        print("\n------ ERROR : \(error) ------")
    }
    
    func translate(name: String, description: String) {
        
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: .french)
        
        let enToFrTranslator = Translator.translator(options: options)
        
        let cond = ModelDownloadConditions(allowsCellularAccess: true, allowsBackgroundDownloading: true)
        
        enToFrTranslator.downloadModelIfNeeded(with: cond) { error in
            guard error == nil else { return }
            
            enToFrTranslator.translate(name) { translatedText, error in
                if error != nil {
                    print(error)
                } else {
                    if let translatedName = translatedText {
                        self.navigationItem.title = translatedName.capitalized
                    }
                    
                }
            }
            
            enToFrTranslator.translate(description) { translatedText, error in
                if error != nil {
                    print(error)
                } else {
                    if let translatedDescription = translatedText {
                        self.descriptionLabel.text = translatedDescription
                    }
                    
                }
            }
            
        }
        
    }
    
    
    
}
