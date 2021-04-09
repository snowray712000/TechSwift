---
title: ios TableView Section Header Footer
tags: ios, tableview
---
# 1 ios TableView Section Header Footer
![](https://i.imgur.com/acEGKtu.png)

1. cell 分類
    - 當 cell 有分類時，就是切割 section 的概念。
2. 產生數量
    - 之前都過載 numberOfRowsInSection，相似的，過載 numberOfSections 得到 section 數量。
        - section = 0，很好用，表示目前 table 沒有資料。
    - 之前過載 cellForRowAt indexPath: IndexPath。其中的 indexPath 除了 .row 之外，還有 .section 可以用。
3. section header 、 footer
    - 每個 section 都可以有 header footer view。
    - 注意，tableview 也有 header 與 footer，但不要搞混了。
    - 除了像範例，先簡單設定 title，也可以在裡面放 button 之類的。

Code 1a Section 1 個以上。
```swift=
override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
}
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if ( section == 0 ){
        return 3
    } else {
        return 2
    }
}
```
Code 1b Cell 內容。使用 indexPath.section
```swift=
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    makeSureCellRegisted()

    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    cell.textLabel?.text = "\(indexPath.section) \(indexPath.row)"

    return cell
}
```
Code 1c 。 Section 的 header 與 footer 。
```swift=
override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "section title \(section)"
}
override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return "section foot \(section)"
}
```
Code 1d。 Tableview 的 header
```swift=
override func viewDidLoad() {
    super.viewDidLoad()

    if  tableView.tableHeaderView == nil {

        let r1 = UILabel()
        r1.text  = "table header view"

        // 必需在 addSubView 之前
        r1.bounds.size.height = 20
        tableView.addSubview(r1)
        tableView.tableHeaderView = r1
        // r1.isHidden = false 預設就是
    }
}
```
