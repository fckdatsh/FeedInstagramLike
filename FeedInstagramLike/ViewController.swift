//
//  ViewController.swift
//  FeedInstagramLike
//
//  Created by Rob on 19/4/22.
//

import UIKit
import AVFoundation

class FeedCell: UITableViewCell {
    
    var model: Model = .init(url: "")
    var playerLayer = AVPlayerLayer()
    var isPlaying: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleVideo))
        contentView.addGestureRecognizer(tap)
        contentView.layer.addSublayer(playerLayer)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.blue.cgColor
    }
    
    func configure(model: Model){
        self.model = model
        guard let url = URL(string: model.url) else { return }
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            switch asset.statusOfValue(forKey: "playable", error: nil) {
            case .loading:
                print("spinner")
            case .loaded:
                DispatchQueue.main.async {
                    self?.playerLayer.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
                }
            default:
                print("not ready")
            }
        }
    }
    
    @objc private func toggleVideo() {
        isPlaying ? playerLayer.player?.pause() : playerLayer.player?.play()
        isPlaying = !isPlaying
    }
    struct Model {
        var url: String
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer.player?.replaceCurrentItem(with: nil)
        playerLayer.player = nil
    }
    
    func playVideo() {
        playerLayer.player?.play()
    }
    
    func stopVideo() {
        playerLayer.player?.pause()
    }
}

class ViewController: UIViewController {
    private var dataSource: [String] {
        [
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/rbsp_launch_1080p.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4",
        "http://s3.amazonaws.com/akamai.netstorage/HD_downloads/Shuttle_Doc_Long_Version.mp4"
        ]
    }
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FeedCell.self, forCellReuseIdentifier: FeedCell.description())
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.description(), for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        cell.configure(model: .init(url: dataSource[indexPath.row]))
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.visibleCells.forEach { cell in
            let center = scrollView.contentOffset.y + (scrollView.bounds.height * 0.5)
            guard let feedCell = cell as? FeedCell else { return }
            if center > feedCell.frame.origin.y && center < feedCell.frame.origin.y + feedCell.frame.size.height {
                feedCell.playVideo()
            } else {
                feedCell.stopVideo()
            }
        }
    }
}

