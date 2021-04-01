---
title: 練習 TableView 上面有控制項 (完成)
tags: ios, navigationItem, setToolbarItems, UIBarButtonItem
---
try1: 新增上面按鈕 navigationItem .navigationBar.isHidden
---
- 太長、太擠時，會壓縮最「左」或最「右的」，中間的 title 是第一個不見的
- 注意! (卡了2天)
    - navigationItem 必需用 ViewController 的，而非下面的
    - self.navigationController!.navigationItem.rightBarButtonItems 的
        - navigationController 雖可以取得 navigationItem ToolbarItem 等等，但從 navigation 取得的去設定，都是無效的。
    - 承上，navigation 不一定完全無用，設定 Hide Visiable 是有用的
        - navigationController?.setNavigationBarHidden(true, animated: false)
        - 承上，不要使用下面這個 (雖然目前結果會一樣，但 toolbar 時，一個就會失效)
        - navigationController?.navigationBar.isHidden = true
        - toolbar 
            - 有效 navigationController?.setToolbarHidden(false, animated: true)
            - 無效 navigationController?.toolbar.isHidden = false

![](https://i.imgur.com/XHqJhpg.png)

```swift=
import UIKit
import PlaygroundSupport
class ViewApp : UIViewController {
    override func loadView() {
        let ratio = 750.0 / 1334.0
        view = UIView(frame:  CGRect(x: 0,y: 0,width: ratio * 480, height: 480))
    }
    override func viewDidAppear(_ animated: Bool) {
        let nav = UINavigationController(rootViewController: MyView1())
        present(nav, animated: true, completion:nil)
    }
}

class MyView1 : UIViewController {
    override func loadView() {
        super.loadView()
        let view = UITableView()
        view.backgroundColor = .yellow
        self.view = view
    }
    @objc func onClickBtn1(_ s : UIBarButtonItem){
        print(s.title)
    }
    @objc func onClickBtn2(_ s : UIBarButtonItem){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Right1", style: .plain, target: self, action: #selector(onClickBtn1)),
            UIBarButtonItem(title: "Right2", style: .plain, target: nil, action: nil)
        ]
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Left1", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Left2", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Left3", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Left4", style: .plain, target: nil, action: nil)
        ]
        
        title = "設定"
    }

}

PlaygroundPage.current.liveView = ViewApp()
```


---

try2: 
---
![](https://i.imgur.com/Sn5yssc.png)
- 不需要再用 view.addSubView ( UIToolbar() )
    - 直接使用 setToolbarItems 即可

```swift=
class MyView1 : UIViewController {
    override func loadView() {
        super.loadView()
        let view = UITableView()
        view.backgroundColor = .yellow
        self.view = view
    }
    @objc func onClickBtn1(_ s : UIBarButtonItem){
        
    }
    @objc func onClickBtn2(_ s : UIBarButtonItem){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let r1 = [ UIBarButtonItem(title: "Left1", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left2", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left3", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left4", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left5", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left6", style: .plain, target: nil, action: nil),
        ]
        setToolbarItems(r1, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        
        title = "設定"
    }
}
```
