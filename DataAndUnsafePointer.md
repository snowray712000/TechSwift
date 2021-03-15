讀檔後，會得到 Data
若要依檔案的 dataformat (多少 offset 是什麼意義)。
那如何作到呢？

以一個 playgound 測試
```swift=1
import UIKit

var str = "Hello, playground"
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
```

沒標記型態，是不行的
```swift=1
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
// let r1 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
// let r1: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
```

Data .withUnsafeBytes 函式
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
r2.withUnsafeBytes { (a1:UnsafeRawBufferPointer) in
    print(a1[0]) // 1
    print(a1[1]) // 2
    print(a1[2]) // 3
}
```

實驗4 little endian 與 big endian
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
r2.withUnsafeBytes { (a1:UnsafeRawBufferPointer) in
    
    // 01 02 03 04 05 06 07 08 09 0A ...
    // 若前2個bytes型成的 UInt16 為某資訊
    // little endian 就是 2x256 + 1 = 513
    // big endian 就是 1x256 + 2 = 258
    print( UInt16(a1[0]) << 8 | UInt16(a1[1]) ) // big endian 258
    print( a1[0] << 8 | a1[1] ) // 若沒先轉型態， a1[0] << 8 會是 0, 所以結果是 2
    print( UInt16(a1[1]) << 8 | UInt16(a1[0]) ) // little endian 513
}
```

實驗5 指標強制轉換
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
r2.withUnsafeBytes { (a1:UnsafeRawBufferPointer) in
    // 01 02 03 04 05 06 07 08 09 0A ...
    a1.bindMemory(to: UInt16.self)[0] // 513 直接轉，實驗結果，是 little endian
    a1.bindMemory(to: UInt16.self)[1] // 1027 取下1個UInt16，實驗結果，是得到 原本的 a1[2] a1[3] 元素組成的，而非 a1[1] a1[2] 組成的
    UInt16(a1[2]) << 8 | UInt16(a1[1])// little endian 770
    UInt16(a1[3]) << 8 | UInt16(a1[2])// little endian 1027
}
```

情境: 第1byte一組；第2、3byte是一組(這樣，實驗5方法就無法作到了)
實驗6: 錯誤，使用 Load 與 offset
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
r2.withUnsafeBytes { (a1:UnsafeRawBufferPointer) in
    // 01 02 03 04 05 06 07 08 09 0A ...
    // error: Execution was interrupted, reason: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0).
    // a1.load(fromByteOffset: 1, as: UInt16.self)
    // a1.load(fromByteOffset: 1, as: [UInt16].self)
}
```
實驗7: 取得Raw指標(剛剛是RawBuffer指標，很像，但不同)。
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2 = Data(r1)
let r2a = r2 as NSData
r2a.bytes // UnsafeRawPointer
r2a.bytes+1
r2a.bytes+2
r2a.bytes+3
// 600002B102C0 600002B102C1 600002B102C2 600002B102C3 記憶體是連續的
// 記憶體+1，就移動1個，與c++的指標很像
```
實驗8: 達成需求，使用 assumingMemoryBound 結合 bytes NSData
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2a = Data(r1) as NSData
r2a.bytes.assumingMemoryBound(to: UInt8.self).pointee // 1
r2a.bytes.assumingMemoryBound(to: UInt16.self).pointee // 513
(r2a.bytes+1).assumingMemoryBound(to: UInt16.self).pointee // 770
```
實驗9: 達成需求，使用 bindMemory 取代 assumingMemoryBound 也可以，但哪個較好，效率較好，我還不知道
```
let r1 : [UInt8] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
let r2a = Data(r1) as NSData
r2a.bytes.bindMemory(to: UInt16.self, capacity: r1.count).pointee
(r2a.bytes+1).bindMemory(to: UInt16.self, capacity: r1.count).pointee
```
