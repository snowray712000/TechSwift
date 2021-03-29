# ios Label 文字相關討論

參考 Programming iOS 14 "Ch11 Text" 這章節

- 需求
    1. 一串文字，可以色彩不同。例如，顯為公義 \<G1344\> (G5686) ，SN是不同色，搜尋結果關鍵字也會用不同色。
    2. 一串文字，可以對不同字 click。
    3. 許多文字，不要效率低。(tableview 的 reuse 概念)

- 找資料、小測試結果
    - WebView 方式可以作到，但要同時能處理訊息，並且 WebView 若要能夠存在 tableview 的 cell 中顯示，就是每個 cell 有很多的 webview。
        - webview 的 hello world。(可)
        - tableview cell 的 child view 可以放很多 webview 嗎？效率好嗎？ (可，效率不好，顯示字很小、權限問題也較麻煩)
        - 網頁的 DOM 事件能順利傳出來用嗎? (沒試)
    - 非 WebView 方式可以作到嗎？
        - 文字上色。(可-實驗1)
        - 文字點擊。(可)
        - 文字在TableViewCell中，重複使用機制。(可)

實驗1: 文字上色 AttributedString
- 設定 label.AttributedString 就會使 label.text 與 color 是無效的。
- 除了顏色，還可以設定很多東西，參考書中 Attributed String Attributes

```swift=
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)

        
        let re = NSMutableAttributedString()
        
        typealias ASKey = NSAttributedString.Key

        let r1 = NSAttributedString(string: "我是誰", attributes: [ASKey.foregroundColor : UIColor.red])
        re.append(r1)
        
        let r2 = NSAttributedString(string: "告訴我",attributes: [ASKey.foregroundColor : UIColor.blue])
        re.append(r2)
        
        label.attributedText = re
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
```

實驗2: 文字事件 delegate
結果2: TextView 的事件不能用，因為選得到的值不準確。(實驗3方法也會失敗，請用實驗4)
- 使用 UITextView 原因
    - label 沒有對應的 delegate 可取得事件，不像另外兩個文字相關的、UITextFieldDelegate、UITextViewDelegate
    - UITextField、UITextView 也都可用 AttributedString
    - UITextField文字很長時，不能換行。
- 事件

實驗2b: textViewShouldBeginEditing 事件
```swift=
class MyViewController : UIViewController, UITextViewDelegate {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UITextView()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.delegate = self
        
        label.attributedText = getTestAttributeString()
        
        view.addSubview(label)
        self.view = view
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.selectedRange // {3,0} 表示選到3位置，包含0個
        return false
    }
}
```
實驗2c: selectedRange 得到 string
- https://suragch.medium.com/getting-and-setting-the-cursor-position-in-swift-68da99bcef39
- 沒辦法點擊到很準確位置，甚至是歪很多。(暫不能用)
```swift=

```

實驗3: 使 label 能點擊(然後若多 label 效率 okay, 就使用多label代替attributedString。
結果3: 不行，行不通，考慮下 case，若有個字特別長，超過換行，則失敗(除非一個字一個label)
![](https://i.imgur.com/8nSYgT5.png)

實驗3a: 手勢、點擊
```swift=
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
     
        self.view = view
        let t = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        view.addGestureRecognizer(t)
    }
    @objc func singleTap(_ p:UITapGestureRecognizer){
        print("asdf")
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
```
實驗3b: UILabel 能點擊 ( isUserInteractionEnabled )
```swift=
import UIKit
import PlaygroundSupport
class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        self.view = view
     
        let lbl = UILabel()
        lbl.frame = CGRect(x: 10, y: 20, width: 80, height: 70)
        lbl.text = "點擊測試"
        view.addSubview(lbl)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        lbl.addGestureRecognizer(t)
        lbl.isUserInteractionEnabled = true // 沒加這不行
    }
    @objc func singleTap(_ p:UITapGestureRecognizer){
        print("asdf")
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
```

實驗3c: 多個 Label、同個 Callback 函式，但能分辨是哪個 Label 被點擊
```swift=
@objc func singleTap(_ p:UITapGestureRecognizer){
    (p.view as! UILabel).text
}
```
實驗3d: 夾帶額外參數
```swift=
class MyLabel : UILabel {
    public var isKeyword: Bool

    public override init(frame: CGRect) {
        isKeyword = false
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 事件處
@objc func singleTap(_ p:UITapGestureRecognizer){
    let v = (p.view as! MyLabel)
    v.isKeyword = !v.isKeyword
}
```
實驗4: UITextView 用手勢，判斷按到哪個字
- 參考資料 https://stackoverflow.com/questions/19332283/detecting-taps-on-attributed-text-in-a-uitextview-in-ios
實驗4a: TextView Tap
- 加入之後，edit功能會自動消失，不用特別去關閉它 (的樣子)。
```swift=
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let v = UITextView()
        v.text =  "這是什麼\n這是第二行字\n若是位置正確就很好"
        
        var ge = UITapGestureRecognizer(target: self, action: #selector(vClick))
        v.addGestureRecognizer(ge)
        self.view = v
    }
    @objc func vClick(_ ge: UITapGestureRecognizer){
        let v = ge.view as! UITextView
    }
}
PlaygroundPage.current.liveView = MyViewController()
```
實驗4b: 取得tap座標
```swift=
@objc func vClick(_ ge: UITapGestureRecognizer){
    let v = ge.view as! UITextView
    v.textContainerInset // left 0 top 8 right 0 bottom 8
    var location = ge.location(in: v) // 左上角 0,0
    location.x -= v.textContainerInset.left
    location.y -= v.textContainerInset.top
}
```
實驗4c: 從 tap 座標，得到文字 (先得到 char index) ... 結果很準確，但是...(請看4d)
```swift=10
        var layoutM = v.layoutManager
        var charIdx = layoutM.characterIndex(for: location, in: v.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // charIdx // 20
        // v.textStorage.length // 21 最後一個字是 [20]
        if charIdx < v.textStorage.length {
            print(charIdx)
            let rng = NSRange(location: charIdx, length: 1)
            (v.text as NSString).substring(with: rng)
        }
        
```
實驗4d: 範圍外去掉
- 實驗4c 的結果測試如下
    - ![](https://i.imgur.com/Js6fYHm.png)
    - 藍色，都是 0 
        - 可用下圖說明，用 layoutM.boundingRect 取得第1字元座標判斷 top left
    - 紫色，換行符號。「麼」後面是4。
        - layoutM.characterIndex 最後一個回傳值，紫色地方都是 1.0 綠色也是 1.0
    - 紅色，「這」與前面是5。
        - 
    - 綠色，都是20
- apple 官網資料
    - https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextUILayer/Tasks/SetTextMargins.html
    - 
![](https://i.imgur.com/dDM5KkM.png)
```swift=
var aa = CGFloat() ;
var charIdx = layoutM.characterIndex(for: location, in: v.textContainer, fractionOfDistanceBetweenInsertionPoints: &aa)

layoutM.boundingRect(forGlyphRange: NSRange(location: 0, length: 1), in: v.textContainer)
layoutM.boundingRect(forGlyphRange: NSRange(location: 20, length: 1), in: v.textContainer)
```

其它: 反白相關的 offset selectedTextRange beginningOfDocument endOfDocument
- 反白。view.selectedTextRange 用來表示開始、結束。
    - 它的 .start .end 兩個 uitextposition 是表示選取的前後
- offset 函式。
    - 目標: 是選到第a-b個字，a, b 是 Int 就可以用 substring 來取得字了
```swift=
var v : UIViewText = self.view

v.offset(from: v.beginningOfDocument, to: (v.selectedTextRange != nil) ? v.selectedTextRange!.start : v.beginningOfDocument) // int

```

實驗5: 嘗試整合上面的
實驗5a: 新專案，並一個 tableview
```swift=
// loadView() 
let tableView = UITableView()
tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
self.view = tableView
```
實驗5b: 有四筆資料。加入 DataSource 相關
```swift=
class MyViewController : UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "aaa"
        return cell
    }
    
    override func loadView() {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        self.view = tableView
    }
}
```
實驗5c: (又發現問題)，文字長，多行時，Table的線與內容對不起來
- 試過 textview 加入 constrains 對 cell.contentview
- 承上，試過 constrains 對應 cell。(不能顯示多行)
- 試過 cellcontentview 加入 constrains 對應 cell 
- intrinsicContentSize 好像是計算時要用到的
    - textview 462.5 x 57.5 
    - cell.contentview 10 x 57.5
    - cell -1 x -1
    - tableview -1 x -1
    - 這個值是 readonly, 無法設定
    - http://tutuge.me/2017/03/12/autolayout-example-with-masonry5/
        - 網頁中，preferredMaxLayoutWidth 只有 Label 才有。


實驗6: 
6a: 一個新 playground
```swift=
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UITableView()
        self.view = view
    }

}
PlaygroundPage.current.liveView = MyViewController()
```
6b: 使 tableview 有資料
- 不用 textview 用 label 仍然會遇到一樣的問題
- 設定 label.attributedText 後， label.intrinsicContentSize 馬上會變
    - 會計算出所需的 size，它的 height 等等會用到
    - 算之前是 0,0 算之後是 375 x 86.5
- 就算 label.numberOfLines = 0 應該可以多行，但你會發現，2行結尾就出現 ... 了(應該要3行才對)，此時要設 .preferredMaxLayoutWidth 就不會發生
- 設定 tableView.rowHeight是關鍵，原本會重疊的問題就解決了。
    - 當然， tableView 只需一個 rowHeight，要設為最大的。
    - 只設 estimatedRowHeight 是不夠的。
    - 設 rowHeight 最大的，不要擔心所有都這麼大，沒有需要那麼高的，會自動縮短。
        - 直覺如上，但卻不是{，會有問題}。每次都要設{rowHeight}。

```swift=
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController,UITableViewDataSource {
    override func loadView() {
        let view = UITableView()
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view = view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func generateColorText(_ str:String,_ color:UIColor) -> NSAttributedString {
        return NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor:color])
    }

    var rowMax: CGFloat = 24
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let label = cell.textLabel else { return cell }
        
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = tableView.frame.width

        if indexPath.row == 1 {
            label.text = "這是短的"
        } else {
            label.attributedText = self.generateColorText("這是什麼\n這是多行，然後還有很長的資料，必須長到換行aaaaaaa aaaaaa aaaaaa aawaefawe aafwefawefawefaaaaaaa", .red)
        }

        tableView.rowHeight = label.intrinsicContentSize.height
        if rowMax < tableView.rowHeight {
            rowMax = tableView.rowHeight
            tableView.estimatedRowHeight = rowMax
        }
        return cell
    }
}
PlaygroundPage.current.liveView = MyViewController()
```
6c: 整理成 MyCell。
- register class 要變
- data source 時, as! MyCell
```swift=
// loadView registry
view.register(MyCell.self, forCellReuseIdentifier: "cell")

// data source 部分
let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell

tableView.rowHeight = cell.heightLabel
```
MyCell部分如下，初始，還有一些常用的。
```swift=
class MyCell : UITableViewCell {
    var label: UILabel {return textLabel!}
    var heightLabel : CGFloat {
        return label.intrinsicContentSize.height
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = frame.width // 320
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

6d: 加入點擊事件 (6e，利用點擊事件，得到點擊 index 與 文字)
- isUserInteractionEnabled
- addGestureRecognizer UITapGestureRecognizer
```swift=
// 點擊事件，在 MyCell 中
    // init 時...
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOneTap)))
        
@objc func onOneTap(_ ge: UITapGestureRecognizer){
    print(ge)
}
```
## 成功達到需求
實驗7: 試作 TabelView Cell 用 UITextView 完成，並且可以 Click 到第幾個字。
https://github.com/snowray712000/TechSwift/blob/main/Tech試作Cell實驗7.swift

- constrains 不要限制高度
    - 我按直覺限制了 top left right bottom, 就錯了
- tableView rowHeight
    - rowHeight = uitextview \{設定文字之後\}算出來的 intrinsic context size
    - 但 inset 也要加入，其實應該 top + bottom 都要，但 只加一個較好看。
    - 承上，有沒有加，不會影響 點擊判斷


## UITextView
### 1.顯示 boarder
用途: 測東西的時候通以用
```swift=
//let tv = UITextView
tv.bounds = CGRect (x: 30,y: 30,width: 612,height: 44)
let layer: CALayer = tv.layer
layer.borderColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
layer.borderWidth = 2.0
layer.cornerRadius = 10
```
