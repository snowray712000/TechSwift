import Foundation

// find magic numbers
public struct FindMagicNumbersPosition{
    var data: Data
    var magicNumber: [[UInt8]]
    public init(magicNumbers:[[UInt8]] , data: Data){
        self.data = data
        self.magicNumber = magicNumbers
    }
    public init(magicNumber:[UInt8], data: Data){
        self.magicNumber = [magicNumber]
        self.data = data
    }
    var p0bytes : UnsafePointer<UInt8>{
        return (data as NSData).bytes.assumingMemoryBound(to: UInt8.self)
    }
    public func main(cntIgnore: Int = 0) -> Int {
        // magic number 04 14 00
        // "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87" ... count:16 answer:3 即 [3] 是 14
        //   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16  ... 略過2個，表示從 [3] 開始測
        //   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 ... 略過2個，表示從[13]開始測
        
        var idx = cntIgnore
        var p = p0bytes + idx
        let pEnd = p0bytes + data.count
        
        guard p < pEnd else {
            return -1
        }
        
        while ( p < pEnd ){
            if isFits(p,pEnd) {
                return idx
            }
            p = p.successor()
            idx+=1
        }
        
        return -1
    }
    public func mainReverse(cntIgnore: Int=0) -> Int{
        // magic number  4 14  0
        // "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87" ... count:16 answer:3 即 [3] 是 14
        //  16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ... 略過2個，表示從42開始測
        //   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 ... 略過2個，表示從[13]開始測
        // 若設ignore 假設略過 4 個, 開始測的值是 7E, 也就是 [11] 即 16 - 4 - 1
        // magic number 為 3 個情境 (同等於ignore:2), ignore 一定要 >= 2
        // 此例若略過 13，就會找不到
        var idx = data.count - cntIgnore - 1
        var p = p0bytes + idx
        let pEnd = p0bytes - 1
        
        // p 會逆向走，所以一定會大於 pEnd
        guard p > pEnd else {
            return -1
        }
        
        while ( p > pEnd ){
            if isFits(p,pEnd) {
                return idx
            }
            p = p.predecessor()
            idx-=1
        }
        
        return -1
    }
    private func isFits(_ p: UnsafePointer<UInt8>,_ pEnd: UnsafePointer<UInt8>)->Bool {
        return magicNumber.ijnAny({isFit(p,pEnd,$0)}) // 只需1個成立即可
//        for a1 in magicNumber {
//            if isFit(p,pEnd,a1) {
//                return true  // 只需1個成立即可
//            }
//        }
//        return false
    }
    private func isFit(_ p: UnsafePointer<UInt8>,_ pEnd: UnsafePointer<UInt8>,_ magicNumber: [UInt8])->Bool {
        let isReverse = p > pEnd
        var p2 = p
        let fnIsValidAddressP2 = { () -> Bool in
            if ( isReverse && p2 <= pEnd ) { return false }
            if ( isReverse == false && p2 >= pEnd) { return false }
            return true
        }
        
        return magicNumber.ijnAll({ a1 in
            guard fnIsValidAddressP2() else {
                return false
            }
            guard p2.pointee == a1 else {
                return false
            }
            p2 = p2.successor()
            return true
        })
    }
}
