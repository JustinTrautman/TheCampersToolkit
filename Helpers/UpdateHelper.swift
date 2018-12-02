//
//  UpdateHelper.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 11/15/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

// TODO: - Design popup for update alert

struct UpdateHelper {
    
    static func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                DispatchQueue.main.async {
                    completion(nil, VersionError.invalidBundleInfo)
                }
                
                return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let result = try JSONDecoder().decode(LookupResult.self, from: data)
                guard let info = result.results.first else { throw VersionError.invalidResponse }
                
                completion(info, nil)
            } catch  {
                completion(nil, error)
            }
        }
        
        task.resume()
        return task
    }
    
    enum VersionError: Error {
        case invalidBundleInfo, invalidResponse
    }
    
    static func checkVersion() {
        let info = Bundle.main.infoDictionary
        let currentVersion = info?["CFBundleShortVersionString"] as? String
        _ = getAppInfo(completion: { (info, error) in
            if let error = error {
                print(error)
            } else if info?.version == currentVersion {
                print("Up to date")
            } else {
                print("A new version is available")
            }
        })
    }
}
