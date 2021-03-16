//
//  VideoNode.swift
//  VideoKitTikTokFeed
//
//  Created by Dennis Stücken on 11/12/20.
//
import AsyncDisplayKit
import VideoKitCore
import VideoKitPlayer

class VideoNode: ASCellNode {
    var delegate: PlayerNodeDelegate? {
        didSet {
            playerNode.delegate = delegate
        }
    }
    
    var playerNode: PlayerNode
    
    init(with video: VKVideo) {
        self.playerNode = PlayerNode(video: video)
        
        super.init()
        self.addSubnode(self.playerNode)
        self.backgroundColor = .black
    }
    
    func getThumbnailURL() -> URL? {
        return playerNode.video.thumbnailImageURL
    }
    
    func isPlaying() -> Bool {
        return playerNode.isPlaying()
    }
    
    func play() {
        playerNode.play()
        print("Playing video \(playerNode.video.videoID)")
    }
    
    func pause() {
        playerNode.pause()
    }
    
    func mute() {
        playerNode.mute()
    }
    
    func unmute() {
        playerNode.mute()
    }
    
    @objc func overlayTapped() {
        self.playerNode.togglePlayback()
    }
}
