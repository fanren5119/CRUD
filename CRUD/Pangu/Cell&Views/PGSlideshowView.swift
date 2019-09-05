//
//  ImageScrollView.swift
//  Store
//
//  Created by hong tianjun on 2018/10/17.
//  Copyright © 2018 hong tianjun. All rights reserved.
//

import UIKit
import Kingfisher
import CocoaLumberjack
import AVKit
import Photos

public class PGVideoView: UIView {
    
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.black
        let item = AVPlayerItem(url: URL(string: "https://outin-5f8b7af651ce11e9a37f00163e1c955c.oss-cn-shanghai.aliyuncs.com/a6f78d74411f4a9897e74899db37e055/642f176dff07ac5caea63afdf5f285d4-fd.mp4?Expires=1558168129&OSSAccessKeyId=LTAItL9Co9nUDU5r&Signature=z7zKdWhyG8bhjiQX7yaDZZl6XY0%3D")!)
        player = AVPlayer(playerItem: item)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        self.layer.addSublayer(playerLayer!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        
        playerLayer?.frame = self.bounds
        super.layoutSubviews()
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let _ = newWindow {
            player?.play()
        }else {
            player?.pause()
        }
    }
}


/*
 这是一个轮播的视图，支持图片和视频，但视频还没有实现完成，只是加了基本功能 ，检测是否可以支持
*/


public class PGSlideshowView: UIView {
    
    public typealias TapClosureType = (Int) -> Void
    
    var timer: Timer? = nil
    
    // 定时移动时间间隔
    public var interval = TimeInterval(3.0)
    // 默认显示图像
    public var placeholderImage: UIImage?
    // 点击图像的事件
    public var tapImageHandler: TapClosureType?
    
    // 当前显示图像列表
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    lazy private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        return  pageControl
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(contentView)
        self.addSubview(scrollView)
        
        pageControl.tintColor = UIColor.white
        self.addSubview(pageControl)
        self.setNeedsUpdateConstraints()
    }
    
    public func setImages(_ urls: [URL]) {
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        for url in urls {
            
            if url.path.range(of: "mp4") != nil {
                let videoView = PGVideoView()
                contentView.addSubview(videoView)
                
            }else {
            
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor.red
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.clipsToBounds = true
            imageView.kf.setImage(with: url, placeholder: placeholderImage)
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
            contentView.addSubview(imageView)
            }
        }
        pageControl.currentPage = 0
        pageControl.numberOfPages = urls.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func updateConstraints() {
        scrollView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (maker) in
            // 此处是个坑，如果使用top.left.bottom约束将不能拖动子视图，是为什么呢？
            maker.edges.equalToSuperview()
            maker.height.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-30)
        }
        
        var previousView: UIView?
        
        for view in contentView.subviews {
            
            view.snp.makeConstraints { (maker) in
                maker.top.bottom.equalToSuperview()
                maker.height.equalToSuperview()
                maker.width.equalTo(scrollView.snp.width)
                
                if let imgView = previousView {
                    maker.left.equalTo(imgView.snp.right)
                }else {
                    maker.left.equalToSuperview()
                }
                
            }
            previousView = view
        }
        if previousView != nil {
            contentView.snp.makeConstraints { (maker) in
                maker.right.equalTo(previousView!)
            }
        }
        super.updateConstraints()
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let _ = newWindow {
            self.startAutoAnimation()
        }else {
            self.stopAutoAnimation()
        }
    }
    
    @objc func tap(_ gestureRecognizer:UIGestureRecognizer) {
        guard let handler = self.tapImageHandler else {
            return
        }
        let page = Int((gestureRecognizer.view?.frame.origin.x)! / scrollView.bounds.width)
        handler(page)
    }
    
    private func startAutoAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self](timer) in
            guard let pages = self?.pageControl.numberOfPages,
                let page = self?.pageControl.currentPage else {
                    return
            }
            
            if pages == 0 { return }
            
            let nextPage = (page + 1) % pages
            self?.pageControl.currentPage = nextPage
            let position: Float = Float(CGFloat(nextPage) * (self?.bounds.width)!)
            self?.scrollView.setContentOffset(CGPoint(x: Int(position), y: 0), animated: true)
            self?.bringSubviewToFront((self?.pageControl)!)
        })
    }
    
    private func stopAutoAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

extension PGSlideshowView : UIScrollViewDelegate {
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.stopAutoAnimation()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopAutoAnimation()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.startAutoAnimation()
    }
}
