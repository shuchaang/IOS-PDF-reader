//
//  ViewController.swift
//  PDF-Demo
//
//  Created by 畅束 on 2023/4/23.
//  Copyright © 2023 com.tzshlyt.demo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var selectPDF: UIButton!
    private var scrollView: UIScrollView!
    var pdfFiles: [URL] = [] // 存储所有 PDF 文件 URL 的数组

    override func viewDidLoad() {
        super.viewDidLoad()
        // 创建 UIScrollView
                scrollView = UIScrollView()
                scrollView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(scrollView)
                
            // 获取 Documents 目录的 URL
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                do {
                    // 获取 Documents 目录下的所有文件 URL
                    let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])

                    // 筛选出扩展名为 "pdf" 的文件 URL
                    pdfFiles = fileURLs.filter { $0.pathExtension.lowercased() == "pdf" }
                } catch {
                    let alertController = UIAlertController(title: "failed", message: "Error getting PDF files: \(error.localizedDescription)", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                }

                setupUI()
        
    }
    func setupUI() {
            // 在视图上创建按钮，并为每个文件创建一个按钮
            for fileURL in pdfFiles {
                let button = UIButton(type: .system)
                button.setTitle(fileURL.lastPathComponent, for: .normal)
                button.setTitleColor(.blue, for: .normal)
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                view.addSubview(button)

                // 设置按钮约束
                button.translatesAutoresizingMaskIntoConstraints = false
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
                button.heightAnchor.constraint(equalToConstant: 40).isActive = true

                if let lastButton = view.subviews[view.subviews.count - 2] as? UIButton {
                    button.topAnchor.constraint(equalTo: lastButton.bottomAnchor, constant: 10).isActive = true
                } else {
                    button.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
                }
            }
        }

        @objc func buttonTapped(_ sender: UIButton) {
            guard let title = sender.titleLabel?.text else {
                return
            }

            // 在按钮点击时处理文件的打开操作
            if let fileURL = pdfFiles.first(where: { $0.lastPathComponent == title }) {
                openPDF(fileURL: fileURL)
            }
        }

        func openPDF(fileURL: URL) {
            // 在此处处理打开 PDF 文件的逻辑，例如通过 UIDocumentInteractionController 进行文件的预览和打开操作
            let separatedStrings = fileURL.path.components(separatedBy: ".")
            if separatedStrings.count == 2 && separatedStrings[1]=="pdf"{
                self.present(PDFViewController(param: fileURL),animated: true,completion: nil)
            } else {
                let alertController = UIAlertController(title: "failed", message: "打开文件失败", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
            }
        }
    
}
