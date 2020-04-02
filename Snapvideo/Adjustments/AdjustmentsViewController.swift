//
//  ToolEditingViewController.swift
//  Snapvideo
//
//  Created by Anastasia Petrova on 13/02/2020.
//  Copyright © 2020 Anastasia Petrova. All rights reserved.
//

import UIKit
import AVFoundation

final class AdjustmentsViewController: UIViewController {
    let toolBar = UIToolbar(
        frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44))
    )
    let asset: AVAsset
    let videoViewController: VideoViewController
    lazy var listView = ParameterListView(parameters: [
        ParameterListView.Parameter(name: "Brightness", value: 10),
        ParameterListView.Parameter(name: "Contrast", value: 25),
        ParameterListView.Parameter(name: "Saturation", value: 40),
        ParameterListView.Parameter(name: "Ambience", value: -23),
        ParameterListView.Parameter(name: "Highlight", value: 10),
        ParameterListView.Parameter(name: "Shadows", value: 3),
        ParameterListView.Parameter(name: "Warms", value: -5),
    ]) { [weak self] parameter in
        self?.sliderView.name = parameter.name
        self?.sliderView.value = CGFloat(parameter.value)
    }
    
    let sliderView = AdjustmentSliderView(name: "Brightness", value: -50)
    lazy var resumeImageView = UIImageView(image: UIImage(named: "playCircle")?.withRenderingMode(.alwaysTemplate))
    
    var previousTranslationY: CGFloat = 0
    
    lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(handlePanGesture)
    )
    
    var trackDuration: Float {
        guard let trackDuration = videoViewController.player.currentItem?.asset.duration else {
            return 0
        }
        return Float(CMTimeGetSeconds(trackDuration))
    }
    
    init(url: URL, tool: AnyTool) {
        asset = AVAsset(url: url)
        videoViewController = VideoViewController(asset: asset)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(videoViewController.view)
        view.addSubview(sliderView)
        view.addSubview(listView)
        view.addSubview(toolBar)
        
        setUpVideoViewController()
        setUpSliderView()
        setUpToolBar()
        setUpParameterListView()
        setUpPanGestureRecognizer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpSliderView() {
        sliderView.translatesAutoresizingMaskIntoConstraints = false 
        NSLayoutConstraint.activate([
            sliderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sliderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            sliderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    private func setUpParameterListView() {
        listView.isHidden = true
        listView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            listView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            listView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setUpToolBar() {
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        func spacer() -> UIBarButtonItem {
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let cancelButton = UIBarButtonItem(
            title: "✕",
            style: .plain,
            target: self,
            action: #selector(cancelAdjustment)
        )
        
        let menuButton = UIBarButtonItem()
        menuButton.image = UIImage(systemName: "slider.horizontal.3")
        menuButton.style = .plain
        menuButton.target = self
        menuButton.action = #selector(applyAdjustment)
        
        let applyButton = UIBarButtonItem(
            title: "✓",
            style: .done,
            target: self,
            action: #selector(applyAdjustment)
        )
        
        let items = [cancelButton, spacer(), menuButton, spacer(), applyButton]
        toolBar.tintColor = .darkGray
        toolBar.setItems(items, animated: false)
    }
    
    private func setUpVideoViewController() {
        videoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate ([
            videoViewController.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            videoViewController.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            videoViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            videoViewController.view.bottomAnchor.constraint(equalTo: toolBar.topAnchor)
        ])
    }
    
    private func setUpPanGestureRecognizer() {
        videoViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: videoViewController.view)
        let deltaY = previousTranslationY - translation.y
        previousTranslationY = translation.y
        listView.translateY(deltaY)
        switch recognizer.state {
        case .began:
            listView.setHiddenAnimated(false, duration: 0.3)
        case .ended:
            listView.setHiddenAnimated(true, duration: 0.2)
            previousTranslationY = 0
        default: break
        }
    }
    
    @objc func applyAdjustment() {
        
    }
    
    @objc func cancelAdjustment() {
        
    }
}
