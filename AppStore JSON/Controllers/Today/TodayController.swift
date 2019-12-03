//
//  TodayController.swift
//  AppStore JSON
//
//  Created by renks on 30.11.2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class TodayController: BaseListController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var startingFrame: CGRect?
    static let cellSize: CGFloat = 500
    
    var items = [TodayItem]()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.color = .darkGray
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let blurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurVisualEffectView)
        blurVisualEffectView.fillSuperview()
        blurVisualEffectView.alpha = 0
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerInSuperview()
        
        fetchData()
                
        navigationController?.navigationBar.isHidden = true
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9489304423, green: 0.9490665793, blue: 0.94890064, alpha: 1)
        
        collectionView.register(TodayCell.self, forCellWithReuseIdentifier: TodayItem.CellType.single.rawValue)
        collectionView.register(TodayMultipleAppCell.self, forCellWithReuseIdentifier: TodayItem.CellType.multiple.rawValue)
        
        setupVisualBlurEffectView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.superview?.setNeedsLayout()
    }
    
    fileprivate func fetchData() {
        // dispatch group
        
        let dispatchGroup = DispatchGroup()
        
        var topGrossingGroup: AppGroup?
        var popularAppsGroup: AppGroup?
        
        dispatchGroup.enter()
        Service.shared.fetchTopGrossing { (appGroup, err) in
            if let err = err {
                print("Failed to fetch top grossing apps:", err)
                return
            }
            topGrossingGroup = appGroup
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        Service.shared.fetchPopularApps { (appGroup, err) in
            if let err = err {
                print("Failed to fetch popular apps:", err)
                return
            }
            popularAppsGroup = appGroup
            dispatchGroup.leave()
        }
        
        // completion block
        dispatchGroup.notify(queue: .main) {
            print("Finished fetching")
            self.activityIndicatorView.stopAnimating()
            
            self.items = [
                TodayItem.init(category: "LIFE HACK", title: "Utilizing your time", image: #imageLiteral(resourceName: "garden"), description: "All the tools and apps you need to intelligently organize you life the right way.", backgroundColor: .white, cellType: .single, apps: []),
                
                TodayItem.init(category: "Daily List", title: topGrossingGroup?.feed.title ?? "", image: #imageLiteral(resourceName: "garden"), description: "", backgroundColor: .white, cellType: .multiple, apps: topGrossingGroup?.feed.results ?? []),
                
                TodayItem.init(category: "Daily List", title: popularAppsGroup?.feed.title ?? "", image: #imageLiteral(resourceName: "garden"), description: "", backgroundColor: .white, cellType: .multiple, apps: popularAppsGroup?.feed.results ?? []),
                
                TodayItem.init(category: "HOLIDAYS", title: "Travel on a budget", image: #imageLiteral(resourceName: "holiday"), description: "Find out all you need to know on how to travel without packing everything!", backgroundColor: #colorLiteral(red: 0.9853913188, green: 0.9642749429, blue: 0.7255596519, alpha: 1), cellType: .single, apps: [])
            ]
            self.collectionView.reloadData()
        }
        
    }
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    var appFullscreenController: AppFullscreenController!
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch items[indexPath.item].cellType {
        case .multiple:
            showDailyListFullscreen(indexPath)
        default:
            showSingleAppFullscreen(indexPath: indexPath)
        }
    }
    
    fileprivate func showDailyListFullscreen(_ indexPath: IndexPath) {
        let fullController = TodayMultipleAppsController(mode: .fullscreen)
        fullController.apps = self.items[indexPath.item].apps
        let navFullController = BackEnabledNavigationController(rootViewController: fullController)
        navFullController.modalPresentationStyle = .fullScreen
        present(navFullController, animated: true)
    }
    
    fileprivate func setupSingleAppFullscreenController(_ indexPath: IndexPath) {
        let appFullscreenController = AppFullscreenController()
        appFullscreenController.todayItem = items[indexPath.row]
        appFullscreenController.dismissHandler = {
            self.handleAppFullscreenDismissal()
        }
        self.appFullscreenController = appFullscreenController
        appFullscreenController.view.layer.cornerRadius = 16
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag))
        gesture.delegate = self
        appFullscreenController.view.addGestureRecognizer(gesture)

    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    var appFullScreenBeginOffset: CGFloat = 0
    
    @objc fileprivate func handleDrag(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            appFullScreenBeginOffset = appFullscreenController.tableView.contentOffset.y
            
        }
        
        let translationY = gesture.translation(in: appFullscreenController.view).y
        
        if appFullscreenController.tableView.contentOffset.y > 0 {
            return
        }
        
        if gesture.state == .changed {
            if translationY > 0 {
                
                let trueOffset = translationY - appFullScreenBeginOffset
                var scale = 1 - trueOffset / 1000
                
                scale = min(1, scale)
                scale = max(0.5, scale)
                
                let transform: CGAffineTransform = .init(scaleX: scale, y: scale)
                self.appFullscreenController.view.transform = transform
                print(translationY)
                appFullscreenController.closeButton.alpha = 0.9 - (translationY / 200)
            }
        } else if gesture.state == .ended {
            if translationY > 0 && translationY > 160 {
                handleAppFullscreenDismissal()
            } else {
                self.blurVisualEffectView.alpha = 0
                appFullscreenController.closeButton.alpha = 0.9
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
                    self.appFullscreenController.view.transform = .identity
                })
            }
        }
    }
    
    fileprivate func setupStartingCellFrame(_ indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            
            // absolute coordinates of cell
            guard let startingFrame = cell.superview?.convert(cell.frame, to: nil) else { return }
        
            self.startingFrame = startingFrame
    }
    
    fileprivate func setupSingleAppFullscreenStartingPosition(_ indexPath: IndexPath) {
        let fullscreenView = appFullscreenController.view!
        
        view.addSubview(fullscreenView)
        
        addChild(appFullscreenController)
        
        self.collectionView.isUserInteractionEnabled = false
        
        setupStartingCellFrame(indexPath)
        
        guard let startingFrame = self.startingFrame else { return }
        
        //auto layout constraint animation
        
        self.anchoredConstraint = fullscreenView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: startingFrame.origin.y, left: startingFrame.origin.x, bottom: 0, right: 0), size: .init(width: startingFrame.width, height: startingFrame.height))
        
        self.view.layoutIfNeeded()
    }
    
    var anchoredConstraint: AnchoredConstraints?
    
    fileprivate func beginAnimationAppFullScreen() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            
            self.blurVisualEffectView.alpha = 1
            
            self.anchoredConstraint?.top?.constant = 0
            self.anchoredConstraint?.leading?.constant = 0
            self.anchoredConstraint?.width?.constant = self.view.frame.width
            self.anchoredConstraint?.height?.constant = self.view.frame.height
            
            self.view.layoutIfNeeded() // starts animation
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.size.height
            
            guard let cell = self.appFullscreenController.tableView.cellForRow(at: [0,0]) as? AppFullscreenHeaderCell else { return }
            cell.todayCell.topConstraint.constant = 48
            cell.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    fileprivate func showSingleAppFullscreen(indexPath: IndexPath) {
        // #1
        setupSingleAppFullscreenController(indexPath)
        
        // setup fullscreen in its starting position
        setupSingleAppFullscreenStartingPosition(indexPath)
        
        // begin the fullscreen animation
        beginAnimationAppFullScreen()
        
    }
    
    @objc fileprivate func handleAppFullscreenDismissal() {
       
        // access starting frame
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
                        
            guard let startingFrame = self.startingFrame else { return }
            
            self.blurVisualEffectView.alpha = 0
            self.appFullscreenController.view.transform = .identity
            
            self.appFullscreenController.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            self.anchoredConstraint?.top?.constant = startingFrame.origin.y
            self.anchoredConstraint?.leading?.constant = startingFrame.origin.x
            self.anchoredConstraint?.width?.constant = startingFrame.width
            self.anchoredConstraint?.height?.constant = startingFrame.height
            
            self.view.layoutIfNeeded() // starts animation
            
            if let tabBarFrame = self.tabBarController?.tabBar.frame {
                self.tabBarController?.tabBar.frame.origin.y = self.view.frame.size.height - tabBarFrame.height
            }
            
            guard let cell = self.appFullscreenController.tableView.cellForRow(at: [0,0]) as? AppFullscreenHeaderCell else { return }
            self.appFullscreenController.closeButton.alpha = 0
            cell.todayCell.topConstraint.constant = 24
            cell.layoutIfNeeded()
            
        }, completion: { _ in
            self.appFullscreenController.view?.removeFromSuperview()
            self.appFullscreenController.removeFromParent()
            self.collectionView.isUserInteractionEnabled = true
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = items[indexPath.item].cellType.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BaseTodayCell
        cell.todayItem = items[indexPath.item]
        
        (cell as? TodayMultipleAppCell)?.multipleAppsController.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMultipleAppsTap)))
        
        return cell
        
    }
    
    @objc fileprivate func handleMultipleAppsTap(gesture: UITapGestureRecognizer) {
        
        let collectionView = gesture.view
        
        // figure out which cell we're clicking into
        
        var superview = collectionView?.superview
        
        while superview != nil {
            if let cell = superview as? TodayMultipleAppCell {
                
                guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
                
                let apps = self.items[indexPath.item].apps
                
                let fullController = TodayMultipleAppsController(mode: .fullscreen)
                fullController.modalPresentationStyle = .fullScreen
                fullController.apps = apps
                let navFullController = BackEnabledNavigationController(rootViewController: fullController)
                navFullController.modalPresentationStyle = .fullScreen
                present(navFullController, animated: true)
                return
            }
            superview = superview?.superview
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: TodayController.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 32, left: 0, bottom: 32, right: 0)
    }
}
