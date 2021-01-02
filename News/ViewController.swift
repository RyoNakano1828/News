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
    //Jsonのarticle内のデータ構造
    struct ArticleJson: Codable {
        //ニュースのタイトル
        let title: String?
        let url: URL?
        let urlToImage: URL?
    }
    //Jsonデータ構造
    struct ResultJson: Codable {
        //複数の記事を配列で管理
        let articles: [ArticleJson]?
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            print(searchWord)
            searchNews(keyword: searchWord)
        }
    }
    
    //ニュース検索
    func searchNews(keyword: String) {
        //ニュースの検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        //リクエストURLの組み立て
        guard let req_url = URL(string: "https://newsapi.org/v2/everything?q=\(keyword_encode)&apikey=f01eb6db3bcd45dca95ed6b97e8e11b2") else {
            return
        }
        print(req_url)
        
        //リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        //データ転送を管理するためのセッションを開始
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            //セッションを終了
            session.finishTasksAndInvalidate()
            //do try catch処理
            do {
                //JsonDecoderのインスタンス取得
                let decoder = JSONDecoder()
                //受け取ったJsonデータをパース（解析）して格納
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                print(json)
            } catch {
                //エラー処理
                print("error occured")
            }
            
        })
        //ダウンロード開始
        task.resume()
    }
}

