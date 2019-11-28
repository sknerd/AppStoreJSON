//
//  Service.swift
//  AppStore JSON
//
//  Created by renks on 27.11.2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import Foundation

class Service {
    static let shared = Service() // singleton
    
    func fetchApps(searchTerm: String, completion: @escaping ([Result], Error?) -> ()) {
        print("Fetching iTunes Apps from Service layer")
        
        let urlString = "https://itunes.apple.com/search?term=\(searchTerm)&entity=software"
        
        guard let url = URL(string: urlString) else { return }
        
        // fetch data from internet
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            if let err = err {
                print("Failed to fetch apps:", err)
                completion([], nil)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(searchResult.results, nil)
            } catch let jsonErr {
                print("Failed to decode JSON:", jsonErr)
                completion([], jsonErr)
            }
        }.resume() // fires off the request
    }
    
    func fetchPopularApps(completion: @escaping (AppGroup?, Error?) -> ()) {
        
        
        
        fetchAppGroup(urlString: "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/25/explicit.json", completion: completion)
    }
    
    func fetchTopFree(completion: @escaping (AppGroup?, Error?) -> ()) {
        fetchAppGroup(urlString: "https://rss.itunes.apple.com/api/v1/us/ios-apps/top-free/all/50/explicit.json", completion: completion)
    }
    
    func fetchTopGrossing(completion: @escaping (AppGroup?, Error?) -> ()) {
        fetchAppGroup(urlString: "https://rss.itunes.apple.com/api/v1/us/ios-apps/top-grossing/all/25/explicit.json", completion: completion)
    }
    
    // helper function
    func fetchAppGroup(urlString: String, completion: @escaping (AppGroup?, Error?) -> Void)  {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch results from iTunes:", err)
                completion(nil, err)
                return
            }
            guard let data = data else { return }
            do {
                let appGroup = try JSONDecoder().decode(AppGroup.self, from: data)
                completion(appGroup, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func fetchSocialApps(completion: @escaping ([SocialApp]?, Error?) -> Void) {
        let urlString = "https://api.letsbuildthatapp.com/appstore/social"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch results from iTunes:", err)
                completion(nil, err)
                return
            }
            guard let data = data else { return }
            do {
                let appGroup = try JSONDecoder().decode([SocialApp].self, from: data)
                completion(appGroup, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
