import Foundation

extension Data {
    // print 前幾 byte
    public func ijnToStringHex(separator:String = " ") -> String {
        return self.map({String(format: "%02X", $0)}).joined(separator: separator)
    }
    // 53 61 a7 78 轉為 byte array
    public static func ijnFromByteArrayString(str:String) -> Data {
        return Data(str.split(separator: " ").map({UInt8($0, radix: 16)!}))
    }
}
