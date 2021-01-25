//
//  ViewController.swift
//  VideoKitTikTokFeed
//
//  Created by Dennis Stücken on 11/11/20.
//
import UIKit
import VideoKitPlayer
import VideoKitCore
import AsyncDisplayKit

class ViewController: UIViewController {
    var currentPage = 1
    var shouldPlay = true
    var tableNode: ASTableNode!
    var currentActiveVideoNode: VideoNode?
    var videoDataSource: FeedDataSource = AllVideosFeedDataSource()
    var playlist = VKPlaylist(videos: [])
    var playersManager = VKPlayersManager(prerenderDistance: 3, preloadDistance: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        self.tableNode = ASTableNode(style: .plain)
        self.tableNode.delegate = self
        
        self.tableNode.automaticallyAdjustsContentOffset = false
        self.tableNode.leadingScreensForBatching = 2.0;
        self.tableNode.allowsSelection = false
        self.tableNode.insetsLayoutMarginsFromSafeArea = true
        self.tableNode.view.contentInsetAdjustmentBehavior = .never
        
        // Add tablenodes view as a subview to current view
        self.view.addSubview(self.tableNode.view)
        
        // Table node styling
        self.tableNode.view.backgroundColor = .black
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.isPagingEnabled = true
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.contentOffset = .zero
        self.tableNode.contentInset = .zero
        
        // Make table node view full screen
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.tableNode.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.tableNode.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        // Setup delegates
        self.playersManager.delegate = self
        
        // Wait until VideoKit's session is initialized, then set datasource and load videos
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionStateChanged(_:)), name: .VKAccountStateChanged, object: nil)
        
        // Or set it now in case session is already connected
        if VKSession.current.state == .connected {
            tableNode.dataSource = self
        }
    }
    
    @objc func sessionStateChanged(_ notification: NSNotification? = nil) {
        DispatchQueue.main.async {
            if VKSession.current.state == .connected {
                self.tableNode.dataSource = self
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Play current active video
        if shouldPlay, let currentActiveVideoNode = currentActiveVideoNode {
            currentActiveVideoNode.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shouldPlay = currentActiveVideoNode?.isPlaying() ?? false
        tableNode.visibleNodes.forEach({ ($0 as? VideoNode)?.pause() })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension ViewController {
    func retrieveNextPageWithCompletion(block: @escaping ([VKVideo]) -> Void) {
        videoDataSource.loadNextVideos(currentPage: currentPage) { (videos) in
            if videos.count > 0 {
                self.currentPage += 1
                
                DispatchQueue.main.async {
                    block(videos)
                }
            }
        }
    }
    
    func insertNewRowsInTableNode(videos: [VKVideo]) {
        guard videos.count > 0 else {
            return
        }
        
        self.tableNode.performBatchUpdates({
            let indexPaths = (0..<videos.count).map { index in
              IndexPath(row: index, section: 0)
            }
            playlist.addVideos(videos)
            playersManager.setPlaylist(self.playlist)
            
            if indexPaths.count > 0 {
                self.tableNode.insertRows(at: indexPaths, with: .none)
            }
        })
    }
}

extension ViewController: PlayerNodeDelegate {
    
    func requestPlayer(forVideo video: VKVideo, completion: @escaping VKPlayersManager.PlayerRequestCompletion) {
        playersManager.getPlayerFor(videoId: video.videoID, completion: completion)
    }
    
    func releasePlayer(forVideo video: VKVideo) {
        playersManager.releasePlayerFor(id: video.videoID)
    }
    
}

extension ViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard self.playlist.count > indexPath.row else { return { ASCellNode() } }
        let video = self.playlist.videoAt(indexPath.row)!
        
        return {
            print("Video: \(video.videoID)")
            let node = VideoNode(with: self.playlist.videoAt(indexPath.row)!)
            
            node.delegate = self
            node.style.preferredSize = tableNode.calculatedSize
            
            return node
        }
    }
}

extension ViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        if !videoDataSource.hasMoreVideos(currentPage: currentPage) {
            return false
        }
        
        return true
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        retrieveNextPageWithCompletion { (videos) in
            self.insertNewRowsInTableNode(videos: videos)
            context.completeBatchFetching(true)
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        if let vNode = node as? VideoNode, let indexPath = vNode.indexPath {
            playersManager.setPlaylistIndex(indexPath.row)
            vNode.play()
            currentActiveVideoNode = vNode
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        if let vNode = node as? VideoNode {
            vNode.pause()
        }
    }
}

extension ViewController: VKPlayersManagerProtocol {
    public func vkPlayersManagerNewPlayerCreated(_ manager: VKPlayersManager, _ player: VKPlayerViewController) {
        // Setup video player
        player.aspectMode = .resizeAspectFill
        player.showControls = false
        player.showSpinner = true
        player.showErrorMessages = false
        player.loop = true
    }
}
