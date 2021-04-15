import UIKit
import PlaygroundSupport
import Combine

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
    
    init() {}
    private var obProgress = IJNObservableObject((0,100))
    private var obIsComplete = IJNObservableObject(false)
    func setValue(_ a1:Int, _ a2:Int){
        obProgress.value = ( a1 , a2 )
        if a1 >= a2 {
            obIsComplete.value = true
        }
    }
}




var job = MyJob()
job.getObProgress().addValueDidSetCallback(
{(a1,a2) in
if let a1 = a1 {
  print ("進度列更新，寫在這 \(a1.0) \(a1.1)")
}
})
job.getObIsComplete().addValueDidSetCallback(
    { (a1,a2) in
    if a1 == true {
        print("完成下載了")
    }
})

DispatchQueue.global().async {
    var total = 1_000
    var cur = 0
    while cur < total{
        sleep(1)
        cur += 230
        job.setValue(cur, total)
    }
}

pause()
