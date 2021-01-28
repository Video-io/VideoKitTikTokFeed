//
//  AllVideosFeedDataSource.swift
//  VideoKitTikTokFeed
//
//  Created by Dennis Stücken on 11/12/20.
//
import Foundation
import VideoKitCore

protocol FeedDataSource {
    func loadNextVideos(currentPage: Int, completion: @escaping ([VKVideo]) -> Void)
    func hasMoreVideos(currentPage: Int) -> Bool
}

extension FeedDataSource {
    func hasMoreVideos(currentPage: Int) -> Bool {
        return true
    }
}

class AllVideosFeedDataSource: FeedDataSource {
    var hasMoreVideos: Bool = true
    
    func loadNextVideos(currentPage: Int, completion: @escaping ([VKVideo]) -> Void) {
        let filter = VKVideoFilter()

        filter.page = currentPage
        filter.limit = 10

        _ = VKVideos.shared.get(byFilter: filter, sortOrder: .asc) { [weak self] (response, error) in
            guard self != nil else { return }

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let response = response {
                if response.totalCount == 0 {
                    self?.hasMoreVideos = false
                }
                
                completion(response.videos)
            }
        }
    }
    
    func hasMoreVideos(currentPage: Int) -> Bool {
        return hasMoreVideos
    }
}
