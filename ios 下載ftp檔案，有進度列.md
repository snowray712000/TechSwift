---
title: ios 下載ftp檔案，有進度列
tags: ios, progress, urlsession
---
ios 下載ftp檔案，有進度列
---

# 1 URLSessionDownloadDelegate
- URLSession.shared 無進度列
    - 用 URLSession.shared 無法有進度(但可行)
- URLSessionDownloadDelegate 
    - Code 1a
    - 必要的。XCode會要你加。完成時，作事
        - location 若 print 出來
        - file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F06D7984-E968-4AA2-941F-E115EFA1FF92/tmp/CFNetworkDownload_JVPwpK.tmp
    - 手動加。完成局部時
        - 類似這樣 let percent = 100 * totalBytesWritten / totalBytesExpectedToWrite
- URLSession 並指定 delegate
    - 有嘗試將 URLSession.shared.delegate 指定，但不行，此為唯獨屬性。
    - 要自己 new 一個。 Code 1b
- 完整小範例 Code 1c

Code 1a URLSessionDownloadDelegate
```swift=
class MyProgress : NSObject, URLSessionDownloadDelegate{
// 必要的，XCode會加。完成後，要作什麼。
    func urlSession(_ session: URLSession,
 downloadTask: URLSessionDownloadTask,
 didFinishDownloadingTo location: URL){}
    // 手動加。進度列用
func urlSession(_ session: URLSession,
 downloadTask: URLSessionDownloadTask,
 didWriteData bytesWritten: Int64,
 totalBytesWritten: Int64,
 totalBytesExpectedToWrite: Int64){}
}

```
Code 1b URLSession 的 delegate
```swift=
let rrr1 = URLSession(
configuration: .default, 
delegate: MyProgress(), 
delegateQueue: nil)
rrr1.resume()
```
Code 1c
```swift=
class MyProgress : NSObject, URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print ( location )
        if let data = try? Data(contentsOf: location){
            DispatchQueue.main.async(execute: {
                let r1 = FileManager.default.temporaryDirectory.appendingPathComponent("kjv.zip")
                try! data.write(to: r1)
            })
        }
        print("finish")
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percent = 100 * totalBytesWritten / totalBytesExpectedToWrite
        print( "\(percent) \(totalBytesWritten) \(totalBytesExpectedToWrite)" )
    }
}
let rrr1 = URLSession(configuration: .default, delegate: MyProgress(), delegateQueue: nil)
let rrr2 = rrr1.downloadTask(with: URL(string: "ftp://ftp.fhl.net/pub/FHL/COBS/data/bible_kjv.zip")!)
rrr2.resume()
```
Code 1c result
```swift=
// 這次實驗，網速不是很快，被切割了 2020 次。
0 1360 5041032
0 4080 5041032
0 6800 5041032
0 8160 5041032
0 10880 5041032
.
.
.
99 5037440 5041032
99 5038800 5041032
99 5040160 5041032
100 5041032 5041032

file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F06D7984-E968-4AA2-941F-E115EFA1FF92/tmp/CFNetworkDownload_JVPwpK.tmp

finish
```
