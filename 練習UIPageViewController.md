# ios page view controllers


參考 Simon Ng Ch21 

![](https://i.imgur.com/wEn8LwH.gif)

try1
---
- style 是 readonly，只有初始才能設定。 (行52)
    - 動畫是 .pageCurl 、 常見的是 .scroll
    - spacing 是 scroll 才會有效
    - .SpineLocation 是 pageCurl 才有效。但我設 .min 會成功， .mid 會失敗。
- presentationCount presentationIndex 只有 .scroll 方式才會呼叫 (行44 47)
    - try1 是失敗的，因為看不到那3個點。(雖然最下面有多一個空間)，按了也有效。
    - 但 try2 的時候，會跑出來。
- 必要的。 UIPageViewControllerDataSource protocol (行4 42)
    - 傳入的 viewController 是目前的
    - 下例，是每個 View 不同，但也可以同一個 ViewController 實體(然後裡面的內容不同)
        - 明確說，Simon Ng 的例子中，是同一個 storyboard ID 作出不同的實體。
            - storyboard?.instantiateViewController ( withIdentifier: "WalkthroughContentViewController" )
- 必要的。 初始頁面 (行42)
    - setViewControllers 設定目前的
        - 第1個參數很奇特，明明是一個 Array，但你真的傳1個以上，就會執行失敗。 \[page1!, page2!\] 會失敗
```swift=
import UIKit
import PlaygroundSupport
import WebKit
class MyPageView : UIPageViewController, UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == page2 {
            return page1!
        } else if viewController == page3 {
            return page2!
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == page1 {
            return page2!
        } else if viewController == page2 {
            return page3!
        }
        
        return nil
    }
    var page1: UITableViewController?
    var page2: UIViewController?
    var page3: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        page1 = UITableViewController()
        page1?.view.backgroundColor = .yellow
        page2 = UIViewController()
        page2?.view.backgroundColor = .red
        page3 = UIViewController()
        let p3v = WKWebView()
        p3v.load(URLRequest(url: URL(string: "https://www.google.com/")!))
        page3!.view = p3v
        
        dataSource = self

        setViewControllers([page1!], direction: .forward, animated: true, completion: nil)
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

let pv = MyPageView(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.spineLocation : UIPageViewController.SpineLocation.min.rawValue, UIPageViewController.OptionsKey.interPageSpacing : 1.5 ])
PlaygroundPage.current.liveView = pv
```

try2
---
![](https://i.imgur.com/H33wSKk.gif)
- page view 設計在 程式一開始的時前，「教學」或「導覽」，所以主程式(下面用 MyAppView )、接著在 viewDidAppear 的時候，插入動畫 (行18)
- 關鍵 api
    - viewDidAppear .present
```swift=
import UIKit
import PlaygroundSupport
import WebKit
class MyPageView : UIPageViewController, UIPageViewControllerDataSource{
    // 略...
}



class MyAppView : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UITableView()
        view.backgroundColor = .purple
        title = "主程式畫面"
    }
    override func viewDidAppear(_ animated: Bool) {
        let pv = MyPageView(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.spineLocation : UIPageViewController.SpineLocation.min.rawValue, UIPageViewController.OptionsKey.interPageSpacing : 1.5 ])
        present(pv, animated: true, completion: nil)
    }
}

PlaygroundPage.current.liveView = MyAppView()
```

try3: UIPageControl (可跳過)
---
- 要把原本的 presentationCount presentationIndex 拿掉
- 每個 view controller 都要配一個 ui page control (不是3個共用)
- 加在 .view 並且 使用 constrains 對齊
    - UIViewController().view.addSubView
- 重要參數: .numberOfPages .currentPage
- 問題: UITableViewController 似乎 不能正確顯示
- 點擊事件: 使用 .addTarget
    - UIPageControl().addTarget( self, action: #selector(fn), for: UIControl.Event.valueChanged )
    - 在官網，它說會觸發 valueChanged 事件。
    - 但目前若啟用點擊事件，會壞掉。(還沒解決)
    - 承上，目前只能作顯示用，把點擊失效。 UIPageControl().isEnabled = false
```swift=
    override func viewDidLoad() {
        super.viewDidLoad()
        
        page1 = UITableViewController()
        page1?.view.backgroundColor = .yellow
        initPageControlOrSetCurrent(page1!, 0)
        page2 = UIViewController()
        initPageControlOrSetCurrent(page2!, 1)
        page2?.view.backgroundColor = .red
        page3 = UIViewController()
        initPageControlOrSetCurrent(page3!, 2)
        let p3v = WKWebView()
        p3v.load(URLRequest(url: URL(string: "https://www.google.com/")!))
        page3!.view = p3v
        
        dataSource = self
        setViewControllers([page1!], direction: .forward, animated: true, completion: nil)
    }
    
    func initPageControlOrSetCurrent(_ page: UIViewController,_ idx: Int){
        func initPC(){
            let re = UIPageControl()
            re.tag = 1
            re.numberOfPages = 3
            re.currentPage = idx
            re.isEnabled = false
            re.tintColor = .white
            re.tintAdjustmentMode = .dimmed
            re.backgroundColor = .black
            re.translatesAutoresizingMaskIntoConstraints = false
            re.addTarget(self, action: #selector(onClickPageControl), for: UIControl.Event.valueChanged)
            
            page.view.addSubview(re)
            re.bottomAnchor.constraint(equalTo: page.view.bottomAnchor).isActive = true
            re.centerXAnchor.constraint(equalTo: page.view.centerXAnchor).isActive = true
        }
        page.view.viewWithTag(1)
        if page.view.viewWithTag(1) == nil {
            print("as")
            initPC()
        }
        let pc = page.view.viewWithTag(1)! as! UIPageControl
        pc.currentPage = idx
    }
```
try4 導覽結束 dismiss
---
- 程式碼，回到 try2 開始。
- 新增 button 在 view3
    - .setTitle
    - 注意! 文字是白的，若剛好是白底，會看不到。
    - 事件。 .addTarget

```swift=
override func viewDidLoad() {
    super.viewDidLoad()

// 略...

    let btn = UIButton()
    btn.setTitle("Go", for: .normal)
    btn.backgroundColor = .black
    btn.addTarget(self, action: #selector(onClickBtn), for: UIControl.Event.touchDown)

    page3!.view.addSubview(btn)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.bottomAnchor.constraint(equalTo: page3!.view.bottomAnchor).isActive = true
    btn.rightAnchor.constraint(equalTo: page3!.view.rightAnchor).isActive = true

}
@objc func onClickBtn(_ sender: UIButton,_ ev: UIEvent){
    dismiss(animated: true, completion: nil)
}
```
try5 之前看過導覽了 UserDefaults.standard
---
- 行12 結束，不會再跑下面，不需再導覽。
- 設定值 行6

```swift=
    @objc func onClickBtn(_ sender: UIButton,_ ev: UIEvent){
        print(ev)
        print(sender)
        dismiss(animated: true, completion: nil)
        
        UserDefaults.standard.setValue(true, forKey: "ready")
    }
class MyAppView : UIViewController {
    // 略...
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "ready") {
            return
        }
        
        let pv = MyPageView(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.spineLocation : UIPageViewController.SpineLocation.min.rawValue, UIPageViewController.OptionsKey.interPageSpacing : 1.5 ])
        present(pv, animated: true, completion: nil)
    }
}
```

try6 改變顏色
---
- 預設，是白色，但會看不到(然後以為失敗)
- 設定，找不到屬性
    - 全部的 UIPageControl 是共用 的樣子
    - https://stackoverflow.com/questions/38148311/uipageviewcontroller-indicators-dont-change-color
```swift
// 於 page 的 viewDidLoad 呼叫
let proxy = UIPageControl.appearance()
proxy.pageIndicatorTintColor = UIColor.red.withAlphaComponent(0.2)
proxy.currentPageIndicatorTintColor = UIColor.red
proxy.backgroundColor = UIColor.yellow.withAlphaComponent(0.6)
proxy.backgroundStyle = .minimal
```

###### tags: `UIPageViewController` `UIPageViewControllerDataSource`
