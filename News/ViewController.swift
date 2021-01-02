//
//  ViewController.swift
//  News
//
//  Created by NeppsStaff on 2021/01/02.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //SearchBarのdelegate通知先を設定
        searchBar.delegate = self
        //入力のヒントになるう、プレースホルダーを設定
        searchBar.placeholder = "知りたいニュースを検索"
        
        //TableViewのdataSource設定
        tableView.dataSource = self
        
        //TableViewのdelegateを設定
        tableView.delegate = self
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
    
    //ニュースのリスト(タプル型：追加削除ができない)
    var newsList: [(title: String, url: URL, urlToImage: URL)] = []
    
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
                
                //ニュース情報が取得できているか
                if let articles = json.articles {
                    //ニュース配列を初期化
                    self.newsList.removeAll()
                    //取得しているニュースの数だけ処理
                    for article in articles {
                        //ニュースのタイトル、詳細、掲載URL、画像URLをアンラップ
                        if let title = article.title, let url = article.url, let urlToImage = article.urlToImage {
                            //一つのニュースをタプルでまとめて管理
                            let news = (title,url,urlToImage)
                            //ニュース配列へ追加
                            self.newsList.append(news)
                        }
                    }
                    //TableViewを更新する
                    self.tableView.reloadData()
                }
                //print(json)
            } catch {
                //エラー処理
                print("error occured")
            }
            
        })
        //ダウンロード開始
        task.resume()
    }
    
    //Cellの総数を返すdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    //cellに値を設定するdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行うCellオブジェクトを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        //ニュースタイトルの設定
        cell.textLabel?.text = newsList[indexPath.row].title
        //テキストの折り返し
        cell.textLabel?.numberOfLines = 0
        //ニュースの画像を取得
        if let imageData = try? Data(contentsOf: newsList[indexPath.row].urlToImage) {
            //正常に取得できた場合はUIImageで画像オブジェクトを生成して、Cellにニュース画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        //設定済みのcellオブジェクトを画面に反映
        return cell
    }
    
    //セルの高さ上限
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //Cellが選択された時に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        //SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: newsList[indexPath.row].url)
        //delegateの通知先を自分自身
        safariViewController.delegate = self
        //SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    //SafariVIewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //SafariVIewを閉じる
        dismiss(animated: true, completion: nil)
    }
}

