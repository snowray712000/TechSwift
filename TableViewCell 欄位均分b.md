---
title: ios, TableViewCell 平均欄寬
tags: ios, TableViewCell
---
# ios, TableViewCell 平均欄寬

手動平均欄寬 ( 不是用 StackView 的 Distrubute Equal Fill )

加上 constrain width 、 left 。(可行)

![](https://i.imgur.com/9QpHdfB.png)
```swift=
// v: view, pv: parent view
v.widthAnchor.constraint(
    equalTo: pv.widthAnchor, 
    multiplier: 0.5).isActive = true
```

但下面會是錯的

![](https://i.imgur.com/LPpp4ff.png)
```swift=
// v: TextView pv:contentView 
v.leftAnchor.constraint(
    equalTo: pv.leftAnchor, 
    constant: frame.width / 2.0).isActive = true
```
- cell.frame cell.bounds cell.contentView.frame cell.contentView.bounds 一樣大, 都 320 x 44
    - 所以不是這些理解錯誤
- tableview.frame 、.bounds 都是 375 x 668
    - 用這個就可以正確 tableview!.frame.width / 2.0

試試 1/3 吧，也行。

![](https://i.imgur.com/0HQPAyU.png)


```swift=
// tv: tableview
v.leftAnchor.constraint(
    equalTo: pv.leftAnchor, 
    constant: tv!.frame.width / 3.0).isActive = true
```

## dynamic constrains
更新 constrains
若原本是 平分2個，現在變成3個。

實驗: 位置設定1/3，再設2/3，會變後2/3嗎？(答: 不會)
現象: v.constrains 其實 count 仍然是 0，但這變數容易讓人誤會
(實際上，它存在 parent view 的 constrains 裡!!!)

你可以用 pv.removeConstraints(pv.constraints) 移除所有的 constrain
當然，也可以將當時的 constrain 存起來，再用 pv.removeConstraint 只移除那個
```swift=
let r1 =
v.leftAnchor.constraint(
    equalTo: pv.leftAnchor, 
    constant: tv!.frame.width / 3.0)
r1.isActive = true

pv.removeConstraint(r1)

v.leftAnchor.constraint(
    equalTo: pv.leftAnchor,
    constant: tv!.frame.width * 2.0 / 3.0
).isActive = true
```

更好的方法
```swift=
r1.constant = tv!.frame.width * 2.0 / 3.0
```
## stackview 方法
使用 StackView、有點像 C# 的 FlowLayoutPanel
它的實作如下
```swift=
// 方法1 自動
let re = UIStackView()
re.axis = .horizontal
re.addArrangedSubview(UITextView())
re.addArrangedSubview(UITextView())
re.addArrangedSubview(UITextView())
re.addArrangedSubview(UITextView())
re.distribution = .fillEqually
re.alignment = .fill
for a1 in re.arrangedSubviews {
    let v =
    (a1 as! UITextView)
    v.isScrollEnabled = false
    v.isEditable = false
    v.isSelectable = false
    v.textAlignment = .justified
    v.text = "耶穌基督的僕人保羅，\n奉召為使徒，特派傳　神的福音。"
}

contentView.addSubview(re)
let v = re ; let pv = contentView ;
v.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    v.leftAnchor.constraint(equalTo: pv.leftAnchor),
    v.rightAnchor.constraint(equalTo: pv.rightAnchor),
    v.centerYAnchor.constraint(equalTo: pv.centerYAnchor),
])
```
## 效率比較, 手動(配合constrain) 、 StackView

手動方法, 當欄數變多, 秒數變多如下
277, 178, 104, 15 ms

StackView方法, 
41 38 34 26

所以還是以 StackView 方式進行吧
