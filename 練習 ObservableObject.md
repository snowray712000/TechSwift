---
title: swift ObservableObject
tags: ios, 
---
# try1 基本用法
- ObservableObject
    - class MyOb : ObservableObject \{\}
    - 繼承，就得到一個 .objectWillChange : ObservableObjectPublisher
- @Published
    - @Published var val = 5
    - 會自動再加一個 $val 變數，型態是 Published<Int>.Publisher
    - 當這個變數「值改變」時，會觸發事件
- Combine
    - import Combine
    - 下程式 行5 Subscribers 在 Combine 中定義
- .sink
    - 注意，行5 的 sink 的結果。直覺是 ob.val 會是 10，但其實是 5。因為它是改變前觸發。
- 非同步問題 async
    - 如果用 async 去測試，你會以為自己是不是程式寫錯。 在 try2 討論吧。


參考官網 https://developer.apple.com/documentation/combine/observableobject/
```swift=
class Ob : ObservableObject{
    @Published var val = 5
}
var ob = Ob()
ob.objectWillChange.sink { (a1: Subscribers.Completion<Never>) in
    print("complete")
} receiveValue: { () in
    print("receiveValue")
}
ob.val = 10
ob.val = 20
ob.val = 30
```

# try2 配合 async 問題 與 解決方案
## 現象描述
下程式，不會觸發 callback 函式 
```swift=
DispatchQueue.global().async {
    sleep(1)
    ob.val = 20
}
```
改成 main 也不會
```swift=
DispatchQueue.global().async {
    sleep(3)
    DispatchQueue.main.async {
        ob.val = 20
    }
}
```
全是 main ，就沒啥用了(但也不會觸發)
```swift=
DispatchQueue.main.async {
    sleep(5)
    ob.val = 20
}
```
核心概念大概是這樣, 注意 val2 (有 didSet 可用)
```swift=
class Ob : ObservableObject{
    @Published var val = 5
    var val2 = 5 {
        willSet {
            objectWillChange.send()
        }
    }
}
```
## 解決方案
若有個 callback 容器 (或一個 callback 也可)
在設定值的時候，去呼叫此 callback 即可 (可行)

```swift=
var fnCallbacks: [(_ new:Int,_ old:Int)->Void] = []
    var val = 5 {
        didSet{
            for a1 in fnCallbacks {
                a1(val,oldValue) // oldValue 是關鍵字
            }
        }
    }
```
訂閱
```swift=
let ob1 = MyOb()
ob1.fnCallbacks.append({ (a1,a2) in
    print(a1)
    print(a2)
})
```
測試 (可行，雖然是 async也可以)
```swift=
DispatchQueue.global().async {
    sleep(1)
    ob1.val = 10
}
```

## 寫成工具

泛型 template
```swift=
class MyOb<T> {
    init(){}
    var fnCallbacks: [(_ new:T?,_ old:T?)->Void] = []
    var val : T? = nil {
        didSet{
            // oldValue 是關鍵字
            for a1 in fnCallbacks {
                a1(val,oldValue)
            }
        }
    }
}
```

add 函式
```swift=
public func addValueDidSetCallback(
    _ fn: @escaping (_ new:T?, _ old:T?) -> Void )
{
    fnCallbacks.append(fn)
    // 加上 @escaping。因為會出現 Converting non-escaping parameter
    // 'fn' to generic parameter 'Element' may allow it to escape
}

// 用法
let ob1 = MyOb<Int>()
ob1.addValueDidSetCallback({(a1,a2) in
    print(a1)
    print(a2)
})
```

簡化函式型態 typealias
```swift=
typealias FnCallback = (_ new: T?, _ old: T?) -> Void
```

clear 與 set 
```swift=
public func setValueDidSetCallback(_ fn: @escaping FnCallback){
    cleanValueDidSetCallbacks()
    fnCallbacks.append(fn)
}
public func cleanValueDidSetCallbacks(){
    fnCallbacks.removeAll()
}
```
完整 code
```swift=
public class IJNObservableObject<T> {
    public init(_ initialValue: T?){self.value = initialValue}
    public typealias FnCallback = (_ new: T?, _ old: T?) -> Void
    internal var fnCallbacks: [FnCallback] = []
    public func addValueDidSetCallback(_ fn: @escaping FnCallback ){
        fnCallbacks.append(fn)
        // 加上 @escaping。因為會出現 Converting non-escaping parameter 'fn' to generic parameter 'Element' may allow it to escape
    }
    public func setValueDidSetCallback(_ fn: @escaping FnCallback){
        cleanValueDidSetCallbacks()
        fnCallbacks.append(fn)
    }
    public func cleanValueDidSetCallbacks(){
        fnCallbacks.removeAll()
    }
    public var value : T? = nil {
        didSet{
            for a1 in fnCallbacks {
                a1(value,oldValue) // oldValue 是關鍵字
            }
        }
    }
}
```

測試1 原本 case
```swift=
let ob1 = MyOb<Int>()
ob1.setValueDidSetCallback({(a1,a2) in
    print(a1)
    print(a2)
})
DispatchQueue.global().async {
    sleep(1)
    ob1.val = 10
}
```

測試2 別的資料型態 (用在進度列case tuple)
```swift=
let ob1 = MyOb<(Int,Int)>()
ob1.val = (0,100)
ob1.setValueDidSetCallback({(a1,a2) in
    print(a1)
    print(a2)
})
DispatchQueue.global().async {
    sleep(1)
    ob1.val = (25,100)
}
```

## 實際 Case 模擬

當初是在處理，下載時的進度，在找這份資料的。

用 async 來模擬下載 (job 變數後面會說到)
```swift=
DispatchQueue.global().async {
    var total = 1_000
    var cur = 0
    while cur < total{
        sleep(1)
        cur += 230
        job.setValue(cur, total)
    }
}
```
設定 callback function (及結果)
```swift=
var job = MyJob()

job.obProgress.addValueDidSetCallback(
    { (a1,a2) in
    if let a1 = a1 {
      print ("進度列更新，寫在這 \(a1.0) \(a1.1)")
    }
})

job.obIsComplete.addValueDidSetCallback(
    { (a1,a2) in
    if a1 == true {
        print("完成下載了")
    }
})

output--
進度列更新，寫在這 230 1000
進度列更新，寫在這 460 1000
進度列更新，寫在這 690 1000
進度列更新，寫在這 920 1000
進度列更新，寫在這 1150 1000
完成下載了
```

一個下載需要，進度、完成
```swift=
class MyJob {
    init() {}
    var obProgress = IJNObservableObject((0,100))
    var obIsComplete = IJNObservableObject(false)
    func setValue(_ a1:Int, _ a2:Int){
        obProgress.value = ( a1 , a2 )
        if a1 >= a2 {
            obIsComplete.value = true
        }
    }
}
```

## 若以 protocol 的方式進行呢？
類似下面方式
```swift=
protocol ObGetter {
    func getObProgress() -> IJNObservableObject<(Int,Int)>
    func getObIsComplete() -> IJNObservableObject<Bool>
}
class MyJob : ObGetter {
    func getObProgress() -> IJNObservableObject<(Int, Int)> {
        return obProgress
    }
    
    func getObIsComplete() -> IJNObservableObject<Bool> {
        return obIsComplete
    }
    // ... 略
}
```
