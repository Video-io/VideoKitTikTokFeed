//
//  PlayerNode.swift
//  VideoKitTikTokFeed
//
//  Created by Dennis Stücken on 11/13/20.
//
import AsyncDisplayKit
import VideoKitPlayer
import VideoKitCore

protocol PlayerNodeDelegate {
    func requestPlayer(forVideo video: VKVideo, completion: @escaping VKPlayersManager.PlayerRequestCompletion)
    func releasePlayer(forVideo video: VKVideo)
}

class PlayerNode: ASDisplayNode {
    var delegate: PlayerNodeDelegate?
    var video: VKVideo
    var player: VKPlayerViewController?
    var shouldPlay: Bool = false

    init(video: VKVideo) {
        self.video = video
    }
    
    override func didEnterVisibleState() {
        requestPlayer()
    }
    
    override func didEnterDisplayState() {
        requestPlayer()
    }
    
    override func didEnterPreloadState() {
        releasePlayer()
    }
    
    func requestPlayer() {
        guard player == nil else { return }
        
        delegate?.requestPlayer(forVideo: self.video) { [weak self] (player, error) in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                guard self.player == nil else { return }
                
                self.player = player
                self.player!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.player!.view.clipsToBounds = true
                self.view.addSubview(self.player!.view)
                
                if (self.shouldPlay) {
                    self.play()
                }
            }
        }
    }
    
    func releasePlayer() {
        guard self.player != nil else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            guard let player = self.player else { return }

            player.pause()
            player.removeFromParent()
            self.player = nil
            self.delegate?.releasePlayer(forVideo: self.video)
        }
    }
    
    func isPlaying() -> Bool {
        return player?.playState == .playing
    }
    
    func play() {
        if let player = self.player {
            player.play()
        } else {
            shouldPlay = true
        }
    }
    
    func pause() {
        player?.pause()
        shouldPlay = false
    }
    
    func togglePlayback() {
        guard let player = self.player else { return }
        
        player.playState == .playing ? pause() : play()
    }
    
    func mute() {
        player?.muted = true
    }
    
    func unmute() {
        player?.muted = false
    }
}
