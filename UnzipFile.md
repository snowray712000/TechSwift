# swift unzip

從 zip file format (wiki) 中，可見 binary 檔的長相
https://en.wikipedia.org/wiki/ZIP_(file_format)

官方 zip 
https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT

程式碼，參照:
https://github.com/nodekit-io/nodekit-darwin

過程會把 Data 中第幾 byte 轉 uint16 等等，所以要先看下面實驗
https://github.com/snowray712000/TechSwift/blob/main/DataAndUnsafePointer.md


實驗1: 首先，從 playgound 中 resources 中 add files to ... 然後讀取 binary
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
```

實驗2: Data 以 Hex Print 出來
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
// 下一行，會跑會超久，不要用
// r2.map({String(format: "%02X", $0)}).joined(separator: " ")

```
實驗3: Data 取前幾個，Print 出來 subdata
```swift=
func toStringHex(data: Data) -> String {
    return data.map({String(format: "%02X", $0)}).joined(separator: " ")
}
let r3a: Data = r2.subdata(in: 0..<20)
toStringHex(data: r3a) // "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87 7F C0 B3 7F"
String(bytes: r3a, encoding: .ascii) // "PKç~6B­À³"
```
在 wiki 中，關於File headers如下，
上面讀取的前4byte，50 4B 03 04，就是下面說的 local file header signature。
```wiki
Offset 	Bytes 	Description[31]
0 	4 	Local file header signature = 0x04034b50 (read as a little-endian number)
4 	2 	Version needed to extract (minimum)
6 	2 	General purpose bit flag
8 	2 	Compression method
10 	2 	File last modification time
12 	2 	File last modification date
14 	4 	CRC-32 of uncompressed data
18 	4 	Compressed size (or 0xffffffff for ZIP64)
22 	4 	Uncompressed size (or 0xffffffff for ZIP64)
26 	2 	File name length (n)
28 	2 	Extra field length (m)
30 	n 	File name
30+n 	m 	Extra field 
```

實驗4: 取得壓縮方法
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)

struct OneFile{
    var bys: UnsafeRawPointer
    init(bys: UnsafeRawPointer){
        self.bys = bys
    }
}
let oneFile = OneFile(data: r2)
oneFile.CompressionMethod // 8 DEFLATE 演算法

extension OneFile{
    var CompressionMethod: UInt16{
        return (self.bys + 8).assumingMemoryBound(to: UInt16.self).pointee
        // 8: DEFLATE 演算法
    }
}
```
實驗5: 取得 filename
```swift=
extension OneFile{
    var FileNameLength: UInt16{
        return (self.bys + 26).assumingMemoryBound(to: UInt16.self).pointee
    }
    var FileName: String{
        // RawPointer to bytes
        let r2 = Data(bytes: bys+30, count: Int(FileNameLength))
        return String(bytes: r2, encoding: .ascii)!
    }
}

let oneFile = OneFile(data: r2)
oneFile.CompressionMethod // 8 DEFLATE 演算法
oneFile.FileNameLength // 14
oneFile.FileName // "bible_hakka.db"
```
實驗6: 取得 檔案大小相關
```swift=
extension OneFile{
    var FileNameLength: UInt16{
        return (self.bys + 26).assumingMemoryBound(to: UInt16.self).pointee
    }
    var CompressedSize: UInt32{
        return (self.bys + 18).assumingMemoryBound(to: UInt32.self).pointee
    }
    var UncompressedSize: UInt32{
        return (self.bys + 22).assumingMemoryBound(to: UInt32.self).pointee
    }
    
    var ExtraFieldLength: UInt16{
        return (self.bys + 28).assumingMemoryBound(to: UInt16.self).pointee
    }
    var ThisFileHeaderLength: UInt16{
        return 30 + FileNameLength + ExtraFieldLength
    }
    var ThisFileLength: UInt32{
        return UInt32(ThisFileHeaderLength) + CompressedSize
    }
}

let oneFile = OneFile(data: r2)
oneFile.CompressionMethod // 8 DEFLATE 演算法
oneFile.FileNameLength // 14
oneFile.FileName // "bible_hakka.db"
oneFile.ThisFileHeaderLength // 72
oneFile.ThisFileLength // 491515
oneFile.CompressedSize // 491443 這個檔案 491621
oneFile.UncompressedSize // 1634304
```

實驗7: 把剩下的 bytes print 出來
- 就是 wiki 中，下面 Central directory file header
- 注意 Central directory file header signature = 0x02014b50 ，就是前4bytes 50 4b 01 02
- 裡面有許多資訊，上面也描述過了，但比上面的資訊更多一些。(有點像增強版的感覺)
- 請看圖，它是從尾巴往前
https://en.wikipedia.org/wiki/ZIP_(file_format)#/media/File:ZIP-64_Internal_Layout.svg 
- 承上, 所以 [git nodekit-io/nodekit-darwin](https://github.com/nodekit-io/nodekit-darwin) 讀完 bytes，第二步就是從檔尾開始，分析後面的 central directory file header
```swift=
toStringHex(data: r2.subdata(in: 491515..<491621))
//"50 4B 01 02 1E 03 14 00 02 00 08 00 E7 7E 36 42 AD 87 7F C0 B3 7F 07 00 00 F0 18 00 0E 00 18 00 00 00 00 00 00 00 00 00 A4 81 00 00 00 00 62 69 62 6C 65 5F 68 61 6B 6B 61 2E 64 62 55 54 05 00 03 E2 45 FE 50 75 78 0B 00 01 04 00 00 00 00 04 00 00 00 00 50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00"

```

實驗8: 來看看，多的資訊有哪些
- https://en.wikipedia.org/wiki/ZIP_(file_format)
- 下列表，較特別只有 offset
- 剩下的 22 bytes，就是 End of central directory record (EOCD)，請對照維基百科

```swift=
let oneCDFH = OneCentralDirectoryFileHeader(bytes: (r2 as NSData).bytes + oneFile.ThisFileLength)
oneCDFH.CompressionMethod // 8
oneCDFH.FileName // "bible_hakka.db"
oneCDFH.UncompressedSize // 1634304
oneCDFH.CompressedSize // 491443
oneCDFH.FileNameLength // 14
oneCDFH.ExtraFieldLength // 24
toStringHex(data: oneCDFH.ExtraField ?? Data()) // "55 54 05 00 03 E2 45 FE 50 75 78 0B 00 01 04 00 00 00 00 04 00 00 00 00"
oneCDFH.FileCommentLength // 0
toStringHex(data: oneCDFH.FileComment ?? Data())
oneCDFH.OffsetOfLocalFileHeader // 0
oneCDFH.ThisFileHeaderLength // 84
// 491515 + 84 = 491599 這個檔案 491621，還沒到尾，還有 22 bytes
 
// 剩下的 bytes
// "50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00"
```

細讀 EOCD
- 
```swift=
// "50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00"

// 50 4B 05 06 EOCD 的 Magic Number
// 00 00 Number of this disk
// 00 00 Disk where central directory starts
// 01 00 重要 Number of central directory records on this disk
// 01 00 Total number of central directory records
// 54 00 00 00 Size of Central directory (bytes)
// FB 7F 07 00 重要 Offset of start of central directory, relative to start of archive
print( 0x00077FFB ) // 491515
// 00 00 Comment length (n)
// Comment
```

實驗9a: zip 中有 中文 檔名
- 先手動將中文檔名的檔案，製成一個 zip 檔
- 第11行，要用 utf8，才會成功，而非錯結果 (行4)
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka許功蓋", withExtension: ".zip")
//let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")

oneFile.FileName // 當是 .ascii時，結果 bible_hakkaè 
oneFile.FileName // 當是 .utf8時，結果 "bible_hakka許功蓋.db"

// 其中的 FileName Getter
    var FileName: String{
        // RawPointer to bytes
        let r2 = Data(bytes: bys+30, count: Int(FileNameLength))
        return String(bytes: r2, encoding: .utf8) ?? ""
        // return String(bytes: r2, encoding: .ascii) ?? ""
    }
```

實驗9b: zip 中有 中文 檔名
- 注意 CompressedSize 是 0
- 承上，Compressed size (or 0xffffffff for ZIP64) 
- 承上，不對呀，若是 zip64 是 0xfffffff 不是 0, 而且 uncompressdSize 不該是這個值
- 繼續下實驗...
```swift=
let oneFile = OneFile(data: r2)
oneFile.CompressionMethod // 8 DEFLATE 演算法
oneFile.FileNameLength // 23 (英文檔名時是14)
oneFile.FileName // "bible_hakka許功蓋.db"
oneFile.ExtraFieldLength // 32
toStringHex(data: oneFile.ExtraField ?? Data() ) // "55 54 0D 00 07 E2 45 FE 50 E2 45 FE 50 5A 67 50 60 75 78 0B 00 01 04 F5 01 00 00 04 14 00 00 00"
oneFile.CompressedSize // 0, (英文檔名時是 491443 這個檔案 491621)
oneFile.UncompressedSize // 1634304 (同英文檔名時結果)
oneFile.ThisFileHeaderLength // 85 (英文檔名時是72)
oneFile.ThisFileLength // 85 (英文檔名時是491515)
```

實驗10: 把 compressed size = 0 的列出來 (但沒有發現什麼
- 第3bit 是 1 的時候
> If the bit at offset 3 (0x08) of the general-purpose flags field is set, then the CRC-32 and file sizes are not known when the header is written. 
```swift=
// "50 4B 03 04 14 00 08 00 08 00 E7 7E 36 42 00 00 00 00 00 00 00 00 00 F0 18 00 17 00 20 00 62 69 62 6C 65 5F 68 61 6B 6B 61 E8 A8 B1 E5 8A 9F E8 93 8B 2E 64 62 55 54 0D 00 07 E2 45 FE 50 E2 45 FE 50 5A 67 50 60 75 78 0B 00 01 04 F5 01 00 00 04 14 00 00 00"
// 0 offset, 50 4B 03 04 magic number
// 4, 14 00,
// 6, 08 00, 轉為 bit 0000 0100
// 8, 08 00, method
//10, E7 7E, last time
//12, 36 42, last date
//14, 00 00 00 00, crc-32
//18, 00 00 00 00, compressed size
//22, 00 F0 18 00, uncompressed size
//26, 17 00, filename 長度, 0x17=23
//28, 20 00, extra field 長度
//30, 62 69 62 6C 65 5F 68 61 6B 6B 61 E8 A8 B1 E5 8A 9F E8 93 8B 2E 64 62, 檔名 utf8 編碼, 23 長度
//30+23, 55 54 0D 00 07 E2 45 FE 50 E2 45 FE 50 5A 67 50 60 75 78 0B 00 01 04 F5 01 00 00 04 14 00 00 00, extra field, 長度32
```

實驗11: 預備從尾巴開始讀，嘗試用這種方式略過 size = 0 的狀況
實驗11a: 像 c++ 指標移動 successor predecessor
```swift=
let r2 = try! Data(contentsOf: r1!)
var r2a:UnsafePointer<UInt8> = (r2 as NSData).bytes.assumingMemoryBound(to: UInt8.self)
toStringHex(data: r2.subdata(in: 0..<16)) // "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87"
r2a.pointee // 80
r2a = r2a.successor()
r2a.pointee // 75
r2a = r2a.predecessor()
r2a.pointee // 80
```
實驗11b: 像 c++ 使用 iterator 的 loop
- loop 在 行 269-271
- 接著要加入判斷式即可
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
var r2a:UnsafePointer<UInt8> = (r2 as NSData).bytes.assumingMemoryBound(to: UInt8.self)
toStringHex(data: r2.subdata(in: 0..<16)) 
//"50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87"

let magicNumber: [UInt8] = [0x4,0x14,0x0]
let data = r2.subdata(in: 0..<16)

var p = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self)
var pEnd = p + data.count - magicNumber.count + 1 // 0xAD 那個位置
assert (p <= pEnd)
while ( p != pEnd ){
    p = p.successor()
}
print(p.pointee) // 0xAD
print(pEnd.pointee) // 0xAD
```

實驗11c: 完成 11。測試部分
- FindMagicNumberPosition https://github.com/snowray712000/TechSwift/blob/main/FindMagicNumberPosition.swift
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
var r2a:UnsafePointer<UInt8> = (r2 as NSData).bytes.assumingMemoryBound(to: UInt8.self)
toStringHex(data: r2.subdata(in: 0..<16))
// "50 4B 03 04 14 00 02 00 08 00 E7 7E 36 42 AD 87"
let magicNumber: [UInt8] = [0x4,0x14,0x0]
let data = r2.subdata(in: 0..<16)

FindMagicNumberPosition(magicNumber: magicNumber, data: data).main(cntIgnore: 0) // 3
FindMagicNumberPosition(magicNumber: magicNumber, data: data).main(cntIgnore: 3) // 3
FindMagicNumberPosition(magicNumber: magicNumber, data: data).main(cntIgnore: 4) // -1
FindMagicNumberPosition(magicNumber: magicNumber, data: data).mainReverse() // 3
FindMagicNumberPosition(magicNumber: magicNumber, data: data).mainReverse(cntIgnore: 12) // 3
FindMagicNumberPosition(magicNumber: magicNumber, data: data).mainReverse(cntIgnore: 13) // -1
```

實驗11d: 逆向取得 EOCD 成功
- 行4 的 21，是因為最小是 22 bytes。
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
var r2a:UnsafePointer<UInt8> = (r2 as NSData).bytes.assumingMemoryBound(to: UInt8.self)
FindMagicNumberPosition(magicNumber: [0x50,0x4B,0x05,0x06], data: r2).mainReverse(cntIgnore: 21)
toStringHex(data: r2.subdata(in: 491599..<r2.count))
// "50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00"
```
實驗11e: 試試中文檔 EOCD ，成功
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka許功蓋", withExtension: ".zip")
//let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
var r2a:UnsafePointer<UInt8> = (r2 as NSData).bytes.assumingMemoryBound(to: UInt8.self)
let pos = FindMagicNumberPosition(magicNumber: [0x50,0x4B,0x05,0x06], data: r2).mainReverse(cntIgnore: 21)
toStringHex(data: r2.subdata(in: pos..<r2.count))
// "50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00" … 原檔
// "50 4B 05 06 00 00 00 00 02 00 02 00 D5 00 00 00 ED 97 07 00 00 00" … 許功蓋 檔
```

實驗12: EOCD 有新格式，要調整
> Zip64: End of central directory signature = 0x06064b50 
- magic number 是 這個 或 那個 都行。 行1
- 因 magic number 可能不一樣長，只要確保不超過 pEnd 即可, 看 6-8
- 多個 magic number，其中一個成立就可以了, 行18-22
```swift=
var magicNumber: [[UInt8]] // 從 [UInt8] 變 多個

    private func isFit(_ p: UnsafePointer<UInt8>,_ pEnd: UnsafePointer<UInt8>,_ magicNumber: [UInt8])->Bool {
        var p2 = p
        for v in magicNumber {
            guard p2 != pEnd else {
                return false
            }
            guard p2.pointee == v else {
                return false
            }
            p2 = p2.successor()
        }
        return true
    }
    
    private func isFits(_ p: UnsafePointer<UInt8>,_ pEnd: UnsafePointer<UInt8>)->Bool {
        for a1 in self.magicNumber {
            guard isFit(p, pEnd, a1) else {
                return true // 只需1個成立即可
            }
        }
        return false
    }
```

實驗13: 其中一組 magic number 符合即可
- 過程 用了 C# linq 概念 (any、all)，https://github.com/snowray712000/TechSwift/blob/main/ArrayExtensionLinq.swift 
- FindMagicNumbersPosition 完整程式 https://github.com/snowray712000/TechSwift/blob/main/FindMagicNumbersPosition.swift
- zip、zip64 用 [[0x50,0x4B,0x05,0x06],[0x50,0x4B,0x06,0x06]] 這組參數吧
```swift=
let r1 = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let r2 = try! Data(contentsOf: r1!)
// 原本的，只有1個 magic number
let pos = FindMagicNumbersPosition(magicNumbers: [[0x50,0x4B,0x05,0x06]], data: r2).mainReverse(cntIgnore: 0) // 491599
toStringHex(data: r2.subdata(in: pos..<r2.count))
// "50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00" 491599

// 2 個 magic number
let pos = FindMagicNumbersPosition(magicNumbers: [[0x50,0x4B,0x05,0x06],[0xFB,0x7F]], data: r2).mainReverse(cntIgnore: 0) 
// "FB 7F 07 00 00 00" 491615
```

實驗14: 從 EOCD 取得 compressed size (中文，原本是0那個)
實驗14a: EOCD 回到 第一組 CD ... ，驗證，正確，因為它 Magic Number 正確 0x02014B50
```swift=
let isZip64 = r2[pos+2] == 0x06
func getOffset(data:Data,pos: Int,isZip64:Bool = false) -> UInt32 {
    let offset =  isZip64 ? 48 : 16
    let bys = (data as NSData).bytes + pos + offset
    return bys.assumingMemoryBound(to: UInt32.self).pointee
    //return bys.load(as: UInt32.self) // Fatal error: load from misaligned raw pointer
}
let pos2 = getOffset(data: r2, pos: pos,isZip64: isZip64)
toStringHex(data: r2.subdata(in: Data.Index(pos2)..<r2.count))
// "50 4B 01 02 1E 03 14 00 02 00 08 00 E7 7E 36 42 AD 87 7F C0 B3 7F 07 00 00 F0 18 00 0E 00 18 00 00 00 00 00 00 00 00 00 A4 81 00 00 00 00 62 69 62 6C 65 5F 68 61 6B 6B 61 2E 64 62 55 54 05 00 03 E2 45 FE 50 75 78 0B 00 01 04 00 00 00 00 04 00 00 00 00 50 4B 05 06 00 00 00 00 01 00 01 00 54 00 00 00 FB 7F 07 00 00 00"
```
實驗14b: 用中文那組試試, 正確, 不再是 0
```swift=
let cd1 = OneCentralDirectoryFileHeader(bytes: (r2 as NSData).bytes + Int(pos2))
cd1.CompressedSize // 497296
```

實驗15: 解壓縮，處理一個檔案 (請用 實驗16-因為當不知道dst size時)
實驗15a: 整理一下，必要數字
- 使用 EOCD 得到 CD，得到 data offset 與 length
- 注意，我用 od 的 filename length 與 extra field length 去得到 data 的開始是不對的，應該要用 file header 的 filename length 與 extra field length ，雖然理論上一樣，但不一定一樣。 (我用的 case, extra field 就不一樣長，一個24 一個28)
```swift=
let path = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let file = try! Data(contentsOf: path!)

// data is offset 72 解壓前 471443, 解壓後 1634304
```

實驗15b: 準備 目標 buffer
- defer 就是 c# 的 using 一樣, 這個 block 結束時, 會自動呼叫, 超好用的唷.
```swift=
// data is offset 72 解壓前 471443, 解壓後 1634304
let dstbys = UnsafeMutablePointer<UInt8>.allocate(capacity: 1634304)
defer {
    dstbys.deallocate()
}
```
實驗15c: 成功解壓
- compression_stream_process 核心動作，但要準備好 UnsafeMutablePointer<compression_stream> 物件
- 用 工具開啟 .sqlite3 檔案成功
```swift=
import Compression

let path = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
let file = try! Data(contentsOf: path!)
// data is offset 72 解壓前 471443, 解壓後 1634304

// 準備解壓縮前資料
let srcbys: UnsafePointer<UInt8> = ((file as NSData).bytes + 72).assumingMemoryBound(to: UInt8.self)
// 準備解壓縮後資料( 記憶體，供 compression_stream_process 寫入 )
let dstbys = UnsafeMutablePointer<UInt8>.allocate(capacity: 1634304)
dstbys.initialize(repeating: 0, count: 1634304)
defer {
    dstbys.deallocate()
}

// 準備 stream 物件 (配1個記憶體,設定op algorithm src_ptr src_size dst_ptr dst_size)
let streamPtr = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
defer {
    streamPtr.deallocate()
}
let op: compression_stream_operation = COMPRESSION_STREAM_DECODE
let algorithm: compression_algorithm = Compression.COMPRESSION_ZLIB
var status: compression_status = compression_stream_init(streamPtr, op, algorithm)
assert(status != COMPRESSION_STATUS_ERROR)
streamPtr.pointee.dst_ptr = dstbys
streamPtr.pointee.dst_size = 1634304
streamPtr.pointee.src_size = 471443
streamPtr.pointee.src_ptr = srcbys
defer {
    compression_stream_destroy(streamPtr)
}
status = compression_stream_process(streamPtr, 0)
assert( status == COMPRESSION_STATUS_OK || status == COMPRESSION_STATUS_END) // 測的時候是ok

// 完成了，現在，將 dstbys 寫成檔案
let r3 = Data(bytes: dstbys, count: 1634304)
let r3a = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let r3b = r3a[0].appendingPathComponent("testunzip.sqlite3")
try! r3.write(to: r3b)
```

實驗15d: 優化 dstbys 寫入
```swift=
//let r3 = Data(bytes: dstbys, count: 1634304)
let r3 = Data(bytesNoCopy: dstbys, count: 1634304, deallocator: .none)
```

實驗16: 壓縮、解壓 (有進度列的)
- https://developer.apple.com/documentation/accelerate/compressing_and_decompressing_data_with_input_and_output_filters

實驗16a: 壓縮
```swift=
func compressTest(data: Data)->Data {
    var re = Data()
    
    var idx = 0
    let pageSize = 1024 // 愈小，進度列愈密。
    
    let r1 = try! OutputFilter(.compress, using: .zlib, bufferCapacity: pageSize, writingTo: { (a1) in
        if let a1a = a1 {
            re.append(a1a) // 此處可作進度列
        }
    })
    while ( true ){
        let r2 = min(pageSize, data.count - idx)

        let r3 = data.subdata(in: idx ..< (idx + r2))
        idx += r2
        try! r1.write(r3)
        
        if ( r2 == 0 ){ // 這個要放在這，不然放在 min 下面時， return 值，會是 0 bytes，(很奇怪，但試出來是這樣)
             break
        }
    }
    return re
}
compressTest(data: "這是中文".data(using: .utf8))
```

實驗16b: 解壓縮
```swift=
func decompressTest(data: Data) -> Data{
    var idx = 0
    let lenSrc = data.count
    let pageSize = 1024
    var re = Data()
    
    let r1 = try! InputFilter(.decompress, using: .zlib, readingFrom: { (a1: Int) -> Data in
        print(a1)
        let len = min(a1, lenSrc - idx)
        let da2 = data.subdata(in: idx ..< idx + len)
        idx += len
        return da2
    })
    
    while let page = try! r1.readData(ofLength: pageSize){
        re.append(page)
    }
    
    return re
}
```

實驗16c: 解壓縮 失敗
- 處理 pdf 中的 /FlateDecode 表示是 zlib
- 測試資料如下，但會失敗。
- 原因是 0x78 0x9C 兩個字元不能算在內，它們算是 zlib 算法的 magic number。拿掉這2個就可以成功了。
```swift=
// 78 9C 4D 8E 31 0B C2 40 0C 85 F7 FC 8A 37 0B 5E 93 5C DB EB ED 42 E7 76 A9 BB 68 27 15 DB FF 0F 26 77 15 4C 08 BC 90 BC 2F 09 1A 73 09 B0 E5 39 FC B5 29 2B 6E 4F FA 50 64 86 97 E4 8E A1 C9 D4 76 A7 E5 84 97 CF 82 68 57 BC 55 FD 76 CD 28 F0 9C 47 54 B1 AD D4 8C 11 EB 4E BE DD 6B 0B 19 62 EF A8 07 4D 46 92 81 B9 3E E1 27 02 33 2B 62 2A C4 A3 33 E6 41 68 AE 2D 2E 6F B3 4D F4 05 8A 6A 26 A6

func decompressTest(data: Data) -> Data{
    var idx = 0
    let lenSrc = data.count
    let pageSize = 1024
    var re = Data()
    if (data[0]==0x78&&data[1]==0x9C){
        idx += 2 // zlib 的 magic number 若包含進去，會解壓失敗。 pdf 的 stream 是包含這2個 byte 的
    }
    // 以下省略
}
```
