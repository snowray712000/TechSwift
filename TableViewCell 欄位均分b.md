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

