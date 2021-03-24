import Foundation

// linq
extension Array {
    public func ijnAny(_ fn: (Element) -> Bool) -> Bool {
        for a1 in self {
            if ( fn(a1) ) { return true }
        }
        return false
    }
    public func ijnAll(_ fn: (Element) -> Bool) -> Bool {
        for a1 in self {
            if ( !fn(a1) ) { return false }
        }
        return true
    }
    public func ijnIndexOf<T : Equatable>(_ x:T) -> Int? {
        for i in 0..<self.count {
            if self[i] as! T == x {
                return i
            }
        }
        return nil
    }
}
