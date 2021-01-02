//
//  ViewController.swift
//  News
//
//  Created by NeppsStaff on 2021/01/02.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //SearchBarのdelegate通知先を設定
        searchBar.delegate = self
        //入力のヒントになるう、プレースホルダーを設定
        searchBar.placeholder = "知りたいニュースを検索"
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            print(searchWord)
        }
    }
}

