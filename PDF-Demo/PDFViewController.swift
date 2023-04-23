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
    
    var pdfPath:String?

    private var rollBtn: UIButton!
    private var backBtn: UIButton!
    private var pdfdocument: PDFDocument?
    private var pdfview: PDFView!
    private var pdfScrollView: UIScrollView!
    private var pdfThumbView: PDFThumbnailView!
    private lazy var toolView = ToolView.instanceFromNib()
    private weak var observe : NSObjectProtocol?
    var isRolling = false
    var timer: Timer?
    var scrollSpeed: CGFloat = 1.0 // 滚动速率，可根据需要调整

    
     init(param: String) {
        self.pdfPath=param
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfview = PDFView()
        
        let url = Bundle.main.url(forResource: pdfPath, withExtension: "pdf")
        pdfdocument = PDFDocument(url: url!)
        
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
        
        rollBtn = UIButton(type: .system)
        rollBtn.frame = CGRect(x:5, y:100, width:100, height:30)
        rollBtn.setTitle("滚", for:.normal)
        rollBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rollBtn.addTarget(self, action: #selector(autoRollClick), for: .touchUpInside)
        pdfview.addSubview(rollBtn)

        backBtn = UIButton(type: .system)
        backBtn.frame = CGRect(x:0, y:20, width:100, height:30)
        backBtn.setTitle("BACK", for:.normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        pdfview.addSubview(backBtn)

        
        pdfThumbView = PDFThumbnailView()
        pdfThumbView.layoutMode = .horizontal
        pdfThumbView.pdfView = pdfview
        pdfThumbView.backgroundColor = UIColor.red
        view.addSubview(pdfThumbView)
        
        view.addSubview(toolView)
        toolView.bringSubviewToFront(view)
        
        toolView.thumbBtn.addTarget(self, action: #selector(thumbBtnClick), for: .touchUpInside)
        toolView.outlineBtn.addTarget(self, action: #selector(outlineBtnClick), for: .touchUpInside)
        toolView.searchBtn.addTarget(self, action: #selector(searchBtnClick), for: .touchUpInside)
        toolView.editBtn.addTarget(self, action: #selector(setRollSpeedClick), for: .touchUpInside)
       
        pdfThumbView.translatesAutoresizingMaskIntoConstraints = false
        pdfThumbView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfThumbView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfThumbView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfThumbView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        toolView.translatesAutoresizingMaskIntoConstraints = false
        toolView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        toolView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        toolView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        toolView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        pdfview.translatesAutoresizingMaskIntoConstraints = false
        pdfview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfview.topAnchor.constraint(equalTo: pdfThumbView.bottomAnchor, constant: 0).isActive = true
        pdfview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(tapgesture)
    }
    
    @objc func tapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.toolView.alpha = 1 - self.toolView.alpha
        }
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
        // 创建一个提示框
               let alertController = UIAlertController(title: "设置滚动速度", message: nil, preferredStyle: .alert)
               // 添加一个文本框到提示框
               alertController.addTextField { textField in
                   textField.keyboardType = .numberPad // 设置键盘类型为数字键盘
               }
               // 添加一个取消按钮
               alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
               // 添加一个确定按钮
               alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
                   // 获取用户输入的数字
                   if let text = alertController.textFields?.first?.text, let number = Float(text) {
                       self?.scrollSpeed=CGFloat(number)
                   } else {
                       print("输入无效的数字")
                   }
               }))
               // 显示提示框
               present(alertController, animated: true, completion: nil)
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
            timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
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
           // 计算下一步的偏移量
           let nextPageOffset = CGPoint(x: 0, y: pdfScrollView.contentOffset.y + scrollSpeed)
           pdfScrollView.setContentOffset(nextPageOffset, animated: false)
    }
       // MARK: - UIScrollViewDelegate
       func scrollViewWillBeginDragging(_ pdfScrollView: UIScrollView) {
           // 用户开始拖动时停止自动滚动
           timer?.invalidate()
           timer = nil
       }
       func scrollViewDidEndDragging(_ pdfScrollView: UIScrollView, willDecelerate decelerate: Bool) {
           // 用户结束拖动时重新启动自动滚动
           timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
       }
}
