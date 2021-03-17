struct FindMagicNumberPosition{
    var data: Data
    var magicNumber: [UInt8]
    init(magicNumber:[UInt8] , data: Data){
        self.data = data
        self.magicNumber = magicNumber
    }
    var p0bytes : UnsafePointer<UInt8>{
        return (data as NSData).bytes.assumingMemoryBound(to: UInt8.self)
    }
    func main(cntIgnore: Int = 0) -> Int {
        // magic number 04 14 00
        // "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87" ... count:16 answer:3 即 [3] 是 14
        //   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16  ... 略過2個，表示從 [3] 開始測
        //   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 ... 略過2個，表示從[13]開始測
        
        var idx = cntIgnore
        var p = p0bytes + idx
        let pEnd = p0bytes + data.count - magicNumber.count + 1 // 0xAD 那個位置
        
        guard p <= pEnd else {
            return -1
        }
        
        while ( p != pEnd ){
            if isFit(p) {
                return idx
            }
            p = p.successor()
            idx+=1
        }
        
        return -1
    }
    func mainReverse(cntIgnore: Int=0) -> Int{
        // magic number  4 14  0
        // "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87" ... count:16 answer:3 即 [3] 是 14
        //  16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 ... 略過2個，表示從42開始測
        //   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 ... 略過2個，表示從[13]開始測
        // 若設ignore 假設略過 4 個, 開始測的值是 7E, 也就是 [11] 即 16 - 4 - 1
        // magic number 為 3 個情境 (同等於ignore:2), ignore 一定要 >= 2
        // 此例若略過 13，就會找不到。
        let cntIgnore2 = cntIgnore < magicNumber.count ? magicNumber.count - 1 : cntIgnore
        var idx = data.count - cntIgnore2 - 1
        var p = p0bytes + idx
        let pEnd = p0bytes - 1
        
        guard p >= pEnd else {
            return -1
        }
        
        while ( p != pEnd ){
            if isFit(p) {
                return idx
            }
            p = p.predecessor()
            idx-=1
        }
        
        return -1
    }
    private func isFit(_ p: UnsafePointer<UInt8>)->Bool {
        var p2 = p
        for v in magicNumber {
            if p2.pointee != v {
                return false
            }
            p2 = p2.successor()
        }
        return true
    }
}
