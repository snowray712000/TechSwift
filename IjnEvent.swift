import UIKit
import PlaygroundSupport
import Combine

public class IjnEvent {
    public typealias FnCallback = (_ sender: Any?,_ pData: Any?)-> Void
    internal var fnCallbacks: [FnCallback] = []
    
    public func trigger(_ sender: Any?, _ pData: Any?){
        for a1 in fnCallbacks {
            a1(sender,pData)
        }
    }
    public func addCallback(_ fn: @escaping FnCallback){
        fnCallbacks.append(fn)
    }
    public func clearCallback(){
        fnCallbacks.removeAll()
    }
}

public class IObservableObject<T> {
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
