//
//  FailedDataTaskCatcher.swift
//  ToDo
//
//  Created by TerryTorres on 6/14/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import Foundation

protocol FailedRequestCatcher: class {

    var failedRequestPackages : [(urlRequest: URLRequest, username: String, method: APIService.PostMethod)] { get set }
    func retryFailedRequests(completion:(()->())?)
    
}

extension FailedRequestCatcher {
    
    /*
     This is called on a refresh (automatically, when the app entered the foreground, or manually, when the user pulls down on the tableview).
     The completion handler runs when the last failed request is reattempted.
     Currenly the only completion handler being run is the NetworkCoordinator's getDataFromAPI().
     So: refresh() first calls this function to retry failed requests, THEN get remote data via the API.
    */
    func retryFailedRequests(completion:(()->())? = nil) {
        guard failedRequestPackages.count > 0 else { completion?(); return }
        for (index, requestPackage) in failedRequestPackages.enumerated().reversed() {
            failedRequestPackages.remove(at: index)
            let dataTask = URLSession.shared.dataTask(with: requestPackage.urlRequest) { (data, response, error) in
                guard error == nil else {
                    print("error \(error.debugDescription)");
                    self.failedRequestPackages.append(requestPackage)
                    return }
                guard let data = data else { print("no data"); return }
                if let dataString = String.init(data: data, encoding: .utf8)  {
                    print("data from post request is\n\(dataString)")
                    if dataString.range(of: "success") != nil && requestPackage.method == .insert {
                        // *****
                        let pns = PushNotificationService()
                        if let deviceToken = UserDefaults.standard.object(forKey: UserKeys.deviceToken.rawValue) as? String {
                            pns.pushNotification(username: requestPackage.username, passphrase: PUSH_PASSPHRASE, token: deviceToken)
                        } else {
                            pns.pushNotification(username: requestPackage.username, passphrase: PUSH_PASSPHRASE)
                        }
                    }
                }
            }
            if index == 0 { // Once we've finished the last failed request
                // Run the compleition handler
                completion?()
            }
            dataTask.resume()
        }
        
    }
    
}
