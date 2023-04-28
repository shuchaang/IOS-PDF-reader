//
//  ViewController.swift
//  PDF-Demo
//
//  Created by 畅束 on 2023/4/23.
//  Copyright © 2023 com.tzshlyt.demo. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    private var selectPDF: UIButton!
    private var tableView: UITableView!
    var pdfFiles: [URL] = [] // 存储所有 PDF 文件 URL 的数组
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景颜色
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.backgroundColor = .white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // 创建目录视图
        view.addSubview(tableView)
        self.pdfFiles = self.loadData()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshData(){
        // 模拟异步加载数据
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // 更新数据源
                    self.pdfFiles = self.loadData()
                    // 刷新表格视图
                    self.tableView.reloadData()
                    // 结束刷新
                    self.tableView.refreshControl?.endRefreshing()
                }
    }
    func loadData()->[URL]{
        // 获取 Documents 目录的 URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // 获取 Documents 目录下的所有文件 URL
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
            
            // 筛选出扩展名为 "pdf" 的文件 URL
            pdfFiles = fileURLs.filter { $0.pathExtension.lowercased() == "pdf" }
            return pdfFiles
        } catch {
            let alertController = UIAlertController(title: "failed", message: "Error getting PDF files: \(error.localizedDescription)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        return []
    }
    
    func openPDF(fileURL: URL) {
        // 在此处处理打开 PDF 文件的逻辑，例如通过 UIDocumentInteractionController 进行文件的预览和打开操作
        let separatedStrings = fileURL.path.components(separatedBy: ".")
        if separatedStrings.count == 2 && separatedStrings[1]=="pdf"{
            let pdfvc = PDFViewController(param: fileURL)
            pdfvc.modalPresentationStyle = .fullScreen
            self.present(pdfvc,animated: true,completion: nil)
        } else {
            let alertController = UIAlertController(title: "failed", message: "打开文件失败", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
        }
    }
}
   

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pdfFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let url = pdfFiles[indexPath.row]
        cell.textLabel?.text = url.lastPathComponent
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
            swipeGesture.direction = .left
            cell.addGestureRecognizer(swipeGesture)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    @objc func handleSwipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if let cell = gestureRecognizer.view as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                tableView(tableView, commit: .delete, forRowAt: indexPath)
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let url = pdfFiles[indexPath.row]
            if FileManager.default.fileExists(atPath: url.path){
                do{
                    try FileManager.default.removeItem(at: url)
                }catch{
                    let alertController = UIAlertController(title: "Failed", message: "delete file failed", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                }
            }
            refreshData()
        }
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 处理点击事件，例如打开文件
        let url = pdfFiles[indexPath.row]
        openPDF(fileURL: url)
    }
}
    

