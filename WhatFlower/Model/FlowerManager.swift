//
//  flowerManager.swift
//  WhatFlower
//
//  Created by David Deschamps on 28/06/2021.
//

import Foundation
import MLKitTranslate
import Alamofire
import SwiftyJSON
import SDWebImage

protocol FlowerManagerDelegate {
    func didUpdate(_ flowerManager: FlowerManager, _ result: FlowerDataModel)
    func didFailWithError(error: Error)
}

class FlowerManager {
    
    var delegate : FlowerManagerDelegate?
    
    var translatedName: String?
        
    let wikipediaURl = "https://fr.wikipedia.org/w/api.php"
    
    func fetchData(flowerName: String) {
        getWikiData(flowerName: flowerName)
    }
    
    
    private func getWikiData(flowerName: String) {
        
        print("\n--- Les nom traduit : \(flowerName) ---")
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts|pageimages",
        "exintro" : "",
        "explaintext" : "",
        "titles" : flowerName,
        "indexpageids" : "",
        "redirects" : "1",
        "pithumbsize": "500",
        ]

        AF.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
                case .success(let value):
                    print("\n------ LEs datas \(value)")
                    self.parseJSON(JSON(value), flowerName: flowerName)
                                        
                case .failure(let error):
                    self.delegate?.didFailWithError(error: error)
                
            }
        }
        
    }
    
    private func parseJSON(_ data: JSON, flowerName: String) {
        let query = data["query"]
        let pageId = query["pageids"][0].stringValue
        let description = query["pages"][pageId]["extract"].stringValue
        let imageUrl = query["pages"][pageId]["thumbnail"]["source"].stringValue
        
        print("\n---- woooow desc : \(description)")
        
        self.delegate?.didUpdate(self, FlowerDataModel(name: flowerName, description: description, imageUrl: imageUrl))
        
    }
    

}
