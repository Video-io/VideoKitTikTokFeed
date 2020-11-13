//
//  AppDelegate.swift
//  VideoKitTikTokFeed
//
//  Created by Dennis Stücken on 11/11/20.
//
import UIKit
import VideoKitCore
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(forName: .VKAccountStateChanged, object: self, queue: nil) { (notification) in
            if VKSession.current.state == .connected {
                print("VideoKit Connected.")
            }
        }
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            VKSession.current.start(
                apiToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2lkIjoiMmlUbGdDSHB4cVdSQ01LWGRSZDciLCJyb2xlIjoiYXBwIiwiaWF0IjoxNjAyMjY2NTYyLCJpc3MiOiJ2aWRlby5pbyIsImp0aSI6IjUyTnBNcFpvenA3cGxPa2dPVFFWLTBudmh6In0.8d6rhHDLSB0K1OQgUg5iEtXfkvrMr1OUmIzBppJEjxc",
                identity: UUID().uuidString) { (sessionState, sessionData, error) in
                group.leave()
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        
        group.wait()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

