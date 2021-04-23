---
title: ios test time 時間 效率 測試
tags: ios, 效率, 時間測試
---
# ios test time 時間 效率 測試

TimeInterval 其是是 alias Double, 是秒
```swift=
let r1a = Date()
sleep(1)
let r1b = Date()
// 不是用 r1b - r1a
let r1c = r1a.distance(to: r1b) // TimeInterval
```

包成一個工具，用法如下 
完整如連結: https://github.com/snowray712000/TechSwift/blob/main/IjnTestTime.swift
```swift=
public class TestTime {
    init () { start() } 
    deinit () { end () } 
    func start () {/*略*/} // 可呼叫，可不呼叫
    func end() {/*略*/} // 可呼叫，可不呼叫
}

func Test111(){
    TestTime()
    sleep(1)
}
func Test112(){
    let t = TestTime()
    // 這段時間不計
    for a1 in 0..<1000 {
        print(a1)
    }
    t.start()
    // 計這段
    for a1 in 0..<1000 {
        print(a1)
    }
    t.end() // 不加此行，表示下面執行的也會計
    for a1 in 0..<1000 {
        print(a1)
    }
}
```
配合 Playground 還挺有樣子的

![](https://i.imgur.com/PcNN81G.png)


去除極大極小值的平均
利用 四分位 數的概念
排序，從中間的部分來平均

![](https://i.imgur.com/Snoun6k.png)

```swift=
/// 測時間，有時候第1個會特別久，因此開發這個作參考。
public static func getAvgQ1toQ3() -> Double {

    if dts.count == 0 { return Double.nan }
    else if dts.count == 1 { return dts.first! }
    else if dts.count == 2 { return (dts[0]+dts[1]) / 2.0}
    else if dts.count == 3 { return dts.sorted()[1] }

    let di = 4.0 / Double(dts.count)
    let i1 = Int ( di + 0.5 )
    let i3 = Int ( di * 3 + 0.5 )


    let v2 = dts.sorted()
    var sum = 0.0
    for i in i1..<i3 + 1 {
        sum += v2[i]
    }
    sum /= Double((i3-i1+1))
    return sum
}
```
