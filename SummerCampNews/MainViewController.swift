//
//  MainViewController.swift
//  SummerCampNews
//
//  Created by 原田悠嗣 on 2019/07/08.
//  Copyright © 2019 原田悠嗣. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainViewController: ButtonBarPagerTabStripViewController {

    let urlList: [String] = ["https://news.yahoo.co.jp/pickup/domestic/rss.xml",
                             "https://www.nhk.or.jp/rss/news/cat0.xml",
                             "http://shukan.bunshun.jp/list/feed/rss"]

    // [やってみよう]東洋経済"https://toyokeizai.net/list/feed/rss"

    var itemInfo: [IndicatorInfo] = ["Yahoo!", "NHK", "週間文春"]

    override func viewDidLoad() {
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0.7450980544, green: 0.3918237196, blue: 0.347306622, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = #colorLiteral(red: 1, green: 0.8812249041, blue: 0.9343033258, alpha: 1)
        settings.style.buttonBarItemTitleColor = UIColor.black
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0.9
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)

        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // 管理されるViewControllerを返す処理
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {


        // 返すviewcontrollerの配列を作成
        var childViewControllers:[UIViewController] = []


        for i in 0..<urlList.count {
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "News") as! FirstViewController
            // urlListのURLを一つづつVCにあるurlに入れる
            VC.url = urlList[i]
            VC.itemInfo = itemInfo[i]
            childViewControllers.append(VC)
        }
        // VCを返す
        return childViewControllers
    }

}

