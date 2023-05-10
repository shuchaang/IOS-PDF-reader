//
//  ViewController.swift
//  PDF-Demo
//
//  Created by lan on 2017/6/27.
//  Copyright © 2017年 com.tzshlyt.demo. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    var pdfPath:URL!

    private var rollBtn: UIButton!
    private var backBtn: UIButton!
    private var pdfdocument: PDFDocument?
    private var pdfview: PDFView!
    private var pdfScrollView: UIScrollView!
    private var stepper: UIStepper!
    private var sppedLabel: UILabel!
    private lazy var toolView = ToolView.instanceFromNib()
    private weak var observe : NSObjectProtocol?

    var isRolling = false
    var isSliderHidden = true
    var timer: Timer?
    var scrollSpeed: CGFloat = 0
    var speedShowMul:CGFloat = 2
    var timeInterval = 0.05
    private var db:UserDefaults!
    
    init(param: URL,speed:CGFloat) {
        self.pdfPath=param
        self.scrollSpeed = speed
        self.db = UserDefaults.standard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfview = PDFView()
        pdfdocument = PDFDocument(url: pdfPath!)
        pdfview.document = pdfdocument
        pdfview.displayMode = .singlePageContinuous
        pdfview.autoScales = true
        for view in pdfview.subviews {
                if let scrollView = view as? UIScrollView {
                           self.pdfScrollView = scrollView
                           break
                       }
        }
        view.addSubview(pdfview)
        stepper = UIStepper()
        stepper.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        stepper.minimumValue=1
        stepper.maximumValue=10
        stepper.value=scrollSpeed*speedShowMul
        stepper.stepValue=1
        stepper.isContinuous=true
        stepper.wraps=true
        pdfview.addSubview(stepper)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.trailingAnchor.constraint(equalTo: pdfview.trailingAnchor, constant: -20).isActive = true
        stepper.bottomAnchor.constraint(equalTo: pdfview.bottomAnchor, constant: -70).isActive = true
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        sppedLabel = UILabel(frame: CGRect(x: 0, y:0, width: 200, height: 50))
        sppedLabel.textAlignment = .center
        sppedLabel.font = UIFont.systemFont(ofSize: 18)
        sppedLabel.text = String(format: "滚动速度:\(scrollSpeed*speedShowMul)")
        pdfview.addSubview(sppedLabel)
        sppedLabel.translatesAutoresizingMaskIntoConstraints = false
        sppedLabel.trailingAnchor.constraint(equalTo: pdfview.trailingAnchor, constant: -20).isActive = true
        sppedLabel.bottomAnchor.constraint(equalTo: pdfview.bottomAnchor, constant: -120).isActive = true
     
        
        rollBtn = UIButton(type: .system)
        rollBtn.frame = CGRect(x:10, y:100, width:50, height:50)
        rollBtn.setTitle("滚", for:.normal)
        rollBtn.layer.cornerRadius = 5
        rollBtn.layer.masksToBounds = true
        rollBtn.setTitleColor(UIColor.white,for: .normal)
        rollBtn.backgroundColor = UIColor.purple
        rollBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rollBtn.addTarget(self, action: #selector(autoRollClick), for: .touchUpInside)
        pdfview.addSubview(rollBtn)

        backBtn = UIButton(type: .system)
        backBtn.frame = CGRect(x:5, y:5, width:50, height:50)
        backBtn.setImage(UIImage(named: "arrow_left"), for: .normal)
        backBtn.setTitle("back",for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        pdfview.addSubview(backBtn)
        
        view.addSubview(toolView)
        toolView.bringSubviewToFront(view)
        toolView.thumbBtn.addTarget(self, action: #selector(thumbBtnClick), for: .touchUpInside)
        toolView.editBtn.addTarget(self, action: #selector(setRollSpeedClick), for: .touchUpInside)
        toolView.translatesAutoresizingMaskIntoConstraints = false
        toolView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        toolView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        toolView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        toolView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        pdfview.translatesAutoresizingMaskIntoConstraints = false
        pdfview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
                
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(tapgesture)
    }
    
    @objc func tapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.toolView.alpha = 1 - self.toolView.alpha
        }
    }
    @objc func stepperValueChanged(_ sender: UIStepper) {
        let roundedValue = round(sender.value)
        db.set(roundedValue, forKey: pdfPath.absoluteString)
        sppedLabel.text = String(format: "滚动速度:" + sender.value.description)
        let c = CGFloat(roundedValue)/speedShowMul
        self.scrollSpeed = c
    }
 
    
    @objc func thumbBtnClick(sender: UIButton!) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        
        let width = (view.frame.width - 10 * 4) / 3
        let height = width * 1.5
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        let thumbnailGridViewController = ThumbnailGridViewController(collectionViewLayout: layout)
        thumbnailGridViewController.pdfDocument = pdfdocument
        thumbnailGridViewController.delegate = self
        
        let nav = UINavigationController(rootViewController: thumbnailGridViewController)
        present(nav, animated: false, completion:nil)
    }
    
    @objc func outlineBtnClick(sender: UIButton) {
        
        if let pdfoutline = pdfdocument?.outlineRoot {
            let oulineViewController = OulineTableviewController(style: UITableView.Style.plain)
            oulineViewController.pdfOutlineRoot = pdfoutline
            oulineViewController.delegate = self
            
            let nav = UINavigationController(rootViewController: oulineViewController)
            self.present(nav, animated: false, completion:nil)
        }
    }
    
    @objc func searchBtnClick(sender: UIButton) {
        let searchViewController = SearchTableViewController()
        searchViewController.pdfDocument = pdfdocument
        searchViewController.delegate = self
        
        let nav = UINavigationController(rootViewController: searchViewController)
        self.present(nav, animated: false, completion:nil)
    }
    
    @objc func setRollSpeedClick(sender: UIButton) {
        if isSliderHidden {
            isSliderHidden=false
            stepper.isHidden=isSliderHidden
        }else{
            isSliderHidden=true
            stepper.isHidden=isSliderHidden
        }
    }

    
    @objc func backClick(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func autoRollClick(sender: UIButton) {
        if(isRolling){
            // 停止定时器
            rollBtn.setTitle("滚",for:.normal)
            timer?.invalidate()
            timer = nil
            isRolling=false
            
        }else{
            // 启动定时器，实现自动滚动
            rollBtn.setTitle("停",for:.normal)
            timer = newTimer()
            isRolling=true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PDFViewController: OulineTableviewControllerDelegate {
    func oulineTableviewController(_ oulineTableviewController: OulineTableviewController, didSelectOutline outline: PDFOutline) {
        let action = outline.action
        if let actiongoto = action as? PDFActionGoTo {
            pdfview.go(to: actiongoto.destination)
        }
    }
}

extension PDFViewController: ThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        pdfview.go(to: page)
    }
}

extension PDFViewController: SearchTableViewControllerDelegate {
    func searchTableViewController(_ searchTableViewController: SearchTableViewController, didSelectSerchResult selection: PDFSelection) {
        selection.color = UIColor.yellow
        pdfview.currentSelection = selection
        pdfview.go(to: selection)
    }
       
    @objc func autoScroll() {
        // 检查当前滚动位置是否已经滚动到底部
                let bottomEdge = pdfScrollView.contentOffset.y + pdfScrollView.bounds.size.height
                if bottomEdge >= pdfScrollView.contentSize.height {
                    timer?.invalidate()
                    timer = nil
                } else {
                    // 计算下一步的偏移量
                    let nextPageOffset = CGPoint(x: 0, y: pdfScrollView.contentOffset.y + scrollSpeed)
                    pdfScrollView.setContentOffset(nextPageOffset, animated: false)
                }
          
    }
       // MARK: - UIScrollViewDelegate
       func scrollViewWillBeginDragging(_ pdfScrollView: UIScrollView) {
           // 用户开始拖动时停止自动滚动
           timer?.invalidate()
           timer = nil
       }
       func scrollViewDidEndDragging(_ pdfScrollView: UIScrollView, willDecelerate decelerate: Bool) {
           // 用户结束拖动时重新启动自动滚动
           timer =  newTimer()
       }
    
    func newTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
}
