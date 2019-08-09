//
//  FirstViewController.swift
//  SummerCampNews
//
//  Created by 原田悠嗣 on 2019/07/08.
//  Copyright © 2019 原田悠嗣. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit

class FirstViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, XMLParserDelegate {

    // tableviewのインスタンス取得
    var tableView: UITableView = UITableView()
    // 引っ張って更新
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var webView: WKWebView!

    // urlを受け取る変数
    var url: String = ""
    // タブの名前を受け取る変数
    var itemInfo: IndicatorInfo = ""

    // XMLParserのインスタンス化
    var parser = XMLParser()
    // XMLファイルの情報をここに格納
    var totalBox: [Any] = []
    // XMLファイルに解析をかけた情報
    var elements = NSMutableDictionary()
    // XMLファイルのタグ情報
    var element: String = ""
    // XMLファイルのタイトル情報
    var titleString: String = ""
    // XMLファイルのリンク情報
    var linkString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        // 引っ張って更新
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        // tableviewを作成
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50.0)
        // refreshControlをテーブルビューにつける
        tableView.addSubview(refreshControl)
        // viewcontrollerのviewにtableviewをつける
        self.view.addSubview(tableView)
        webView.isHidden = true
        toolBar.isHidden = true
        parseURL()
    }

    func setUpTableView() {


    }

    func parseURL() {

        // XMLを解析する(パース)
        let urlToSend: URL = URL(string: url)!
        parser = XMLParser(contentsOf: urlToSend)!
        totalBox = []
        parser.delegate = self

        // 解析開始
        parser.parse()
        tableView.reloadData()

    }

    @objc func refresh() {
        perform(#selector(delay), with: nil, afterDelay: 2.0)
    }


    @objc func delay() {
        parseURL()
        // インジケータ終了
        refreshControl.endRefreshing()
    }

    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // セクション数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalBox.count
    }

    // セル内の設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

        cell.backgroundColor = #colorLiteral(red: 0.7944196499, green: 0.9987200224, blue: 1, alpha: 1)

        // タイトル
        cell.textLabel?.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "title") as? String
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        cell.textLabel?.textColor = UIColor.black

        // URL
        cell.detailTextLabel?.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
        cell.detailTextLabel?.textColor = UIColor.gray

        return cell
    }

    // タップ時のアクション
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // webviewを表示する
        let linkURL = ((totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlStr = (linkURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        guard let url = URL(string: urlStr) else {
            return
        }

        let urlRequest = NSURLRequest(url: url)
        webView.load(urlRequest as URLRequest)
    }


    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("遷移開始")
    }

    // webview遷移後に呼ばれる処理
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        tableView.isHidden = true
        toolBar.isHidden = false
        webView.isHidden = false
    }

    // 次のページへ
    @IBAction func nextPage(_ sender: Any) {
        webView.goForward()
    }

    // 前のページへ
    @IBAction func backPage(_ sender: Any) {
        webView.goBack()
    }

    // ページの更新
    @IBAction func refreshPage(_ sender: Any) {
        webView.reload()
    }

    // キャンセル
    @IBAction func cancel(_ sender: Any) {
        tableView.isHidden = false
        webView.isHidden = true
        toolBar.isHidden = true
    }

    // パースについて（大きく分けて３つ）
    // タグを見つけた時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        element = elementName

        // タグの中にitemがあるとき
        if element == "item" {

            // 初期化
            elements = [:]
            titleString = ""
            linkString = ""
        }
    }

    // タグの間にデータがあった時(開始タグを終了タグでくくられた箇所にデータが存在したときに実行されるメソッド)

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element == "title" {
            // ストリングにタイトルが入っているのでappend
            titleString.append(string)
        } else if element == "link" {

            linkString.append(string)

        }
    }

    // 終了タグを見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // アイテムという要素の中にあるなら、
        if elementName == "item" {
            // titleString,linkStringの中身が空でないなら
            if titleString != "" {
                // elementsにキー値を付与しながらtitleString,linkStringをセット
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            if linkString != "" {
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }

            // totalBoxの中にelementsを入れる
            totalBox.append(elements)
        }
    }

    // 必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
