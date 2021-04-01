---
title: tab control 標籤控制項 (完成)
tags: ios
---

- 缺點: 暫空間
- 限制: 最多5個

try1: 初始化，顯示兩個。
---
![](https://i.imgur.com/mbC33qd.gif)
- 當使用 Playground 來作 UITabBarController 或 UINavigationController 都會這麼大
    - 不知道怎麼改善
- Embed in > Tab Bar Controller 就是指設定 Tab Bar 的 viewControllers
    - 我試過直接 = iList 也可以，似乎不一定要在 UINavigationController 中。
```swift=
import UIKit
import PlaygroundSupport

class MyView1 : UIViewController{}
class MyView2 : UITableViewController{}
class MyTab1 : UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view1Item = UITabBarItem(title: "First", image: .checkmark, selectedImage: .checkmark)
        view1Item.tag = 0
        let view1 = MyView1()
        view1.tabBarItem = view1Item
        
        let view2 = MyView2()
        let item2 = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.history, tag: 1)
        view2.tabBarItem = item2
        
        let iList = [view1,view2]
        let iList2 = iList.map({UINavigationController(rootViewController: $0)})
        viewControllers = iList2
    }
}
PlaygroundPage.current.liveView = MyTab1()
```

try2: push 後隱藏
---
- self.hidesBottomBarWhenPushed = true
    - push 完，pop 後，不會自動顯示。(下面會永久隱藏)
    - 可以用 self.tabBarController?.tabBar.isHidden 來控制 (強制顯示)
        - 在 viewDidAppear 時呼叫
    - .hidesBottomBarWhenPushed 不是 TabBar 去呼叫，是 view
- 關鍵行: 16 24-26
```swift=
func addConstrainsToCenter(_ v:UIView,_ pv:UIView){
    v.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        v.centerYAnchor.constraint(equalTo: pv.centerYAnchor),
        v.centerXAnchor.constraint(equalTo: pv.centerXAnchor)
    ])
}
class MyView1 : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = UIButton(primaryAction: UIAction(handler: {_ in
            let rnew = UIViewController()
            rnew.view = UITableView()

            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(rnew, animated: true)
            
        }))
        btn1.setTitle("push", for: .normal)
        view.addSubview(btn1)
        addConstrainsToCenter(btn1, view)
    }
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
}
```
