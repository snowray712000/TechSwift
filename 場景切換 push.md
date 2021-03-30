# ios 場景切換

- 參考資料，很易懂 https://www.hackingwithswift.com/example-code/uikit/how-to-create-live-playgrounds-in-xcode

![](https://i.imgur.com/E2ZYKwJ.png)


實驗1: 使用 UINavigationController 作最底層 (像個 Controller 的容器)
- 注意! MyTable 是繼承 TableView Controller 不是 TableView
```swift=
import UIKit
import PlaygroundSupport

class MyTable : UITableViewController {}
let view1 = MyTable()
let nav = UINavigationController(rootViewController: view1)
PlaygroundPage.current.liveView = nav
```
實驗2: table view 資料
- 注意! table view controller 不是 table view, 不必再 UITableViewDelegate, 已經存在了
    - number rows ...
    - cell for row ...
- 注意! 在 viewDidLoad() 而非 loadView()。否則執行起來會跑很久，還跑不出結果。
    - register cell 在此作
- MyCell! 初始 accessoryType，就是右邊會出現可以按的東西。

```swift=
class MyCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

```swift=
class MyTable : UITableViewController {
    override func viewDidLoad() {
        tableView.register(MyCell.self, forCellReuseIdentifier: "Cell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let data = ["1=1","2-2","3-3","4-4"]
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}
```

實驗3: 按下後，切換 pushViewController
- 宣告另一個 View Controller 
- 在事件 didSelectRowAt 時
    - 建一個，傳資料，push。
- ViewController 的 navigationController 可取得此 view 在哪個 controller 容器中
```swift=
class MyTable2 : UITableViewController {
    public var msg = ""
}

// Table1 的事件
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let data = ["1=1","2-2","3-3","4-4"]
    let text = data  [indexPath.row]

    let view2 = MyTable2()
    view2.msg = text
    navigationController?.pushViewController(view2, animated: true)
}
```
