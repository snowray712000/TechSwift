import Foundation
import Compression

extension Data {
    public func ijnCompress(fnProgressing: ((Int)->Void)? = nil, using: Algorithm = .zlib, pageSize: Int = 1024)->Data {
        let data = self
        var re = Data()
        
        
        var idx = 0
        let r1 = try! OutputFilter(.compress, using: using, bufferCapacity: pageSize, writingTo: { (a1) in
            if let a1a = a1 {
                re.append(a1a) // 此處可作進度列
            }
        })
        while ( true ){
            let r2 =  Swift.min(pageSize, data.count - idx)

            let r3 = data.subdata(in: idx ..< (idx + r2))
            idx += r2
            try! r1.write(r3)
            
            if fnProgressing != nil {
                fnProgressing!(idx)
            }
            
            if ( r2 == 0 ){ // 這個要放在這，不然放在 min 下面時， return 值，會是 0 bytes，(很奇怪，但試出來是這樣)
                 break
            }
        }
        return re
    }
    public func ijnDecompress(fnProgressing: ((Int)->Void)? = nil, using: Algorithm = .zlib, pageSize: Int = 1024) -> Data{
        let data = self
        var idx = 0
        let lenSrc = data.count
        var re = Data()
        if (data[0]==0x78&&data[1]==0x9C){
            idx += 2 // zlib 的 magic number 若包含進去，會解壓失敗。 pdf 的 stream 是包含這2個 byte 的
        }
        
        let r1 = try! InputFilter(.decompress, using: .zlib, readingFrom: { (a1: Int) -> Data in
            let len = Swift.min(a1, lenSrc - idx)
            let da2 = data.subdata(in: idx ..< idx + len)
            idx += len
            if ( fnProgressing != nil ){ fnProgressing!(idx) }
            return da2
        })
        
        while let page = try! r1.readData(ofLength: pageSize){
            re.append(page)
        }
        
        return re
    }
}
//compressTest(data: da1)
