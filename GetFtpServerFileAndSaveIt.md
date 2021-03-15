# 從信望愛站的ftp，取得資料庫檔
keywords #FTP #File #Save #Path #URLSession
[ftp://ftp.fhl.net/pub/FHL/COBS/data/](ftp://ftp.fhl.net/pub/FHL/COBS/data/)

打開一個 playground 檔案測試

實驗1: 透過 URLSession 下載 Ftp 檔案
```swift=
import UIKit

URLSession.shared.dataTask(with: URLRequest(url: URL(string: "ftp://ftp.fhl.net/pub/FHL/COBS/data/bible_hakka.zip")!), completionHandler: { (data,resp,error) in
    guard data != nil else {
        print(error!)
        return
    }
    print(data) // Optional(491621 bytes)
}).resume()
```
實驗2: 取得路徑 (等等 Data write 要用到)
```
let r1 = FileManager.default.temporaryDirectory
//file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/tmp/
let r2 = r1.appendingPathComponent("bible_hakka.zip")
//file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/tmp/bible_hakka.zip
```

實驗3: 達成需求，下載，存檔，並以讀檔驗證
```
let r1 = FileManager.default.temporaryDirectory
let r2 = r1.appendingPathComponent("bible_hakka.zip")
let url: String = "ftp://ftp.fhl.net/pub/FHL/COBS/data/bible_hakka.zip"
URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: { (data,resp,error) in
    guard let data:Data = data else {
        print(error!)
        return
    }
 
    try! data.write(to: r2)
    print("save okay")
    let fileRead = try! Data(contentsOf: r2)
    print(fileRead) // 491621 bytes
    
}).resume()
```

實驗4: 其它路錄 FileManager urls .documentDirectory 我的文件，下載，我的圖片 等常用路線徑
```
FileManager.default.temporaryDirectory
//file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/tmp/

FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//[file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/Documents/]
FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
// [file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/Downloads/]
FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
// [file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/Applications/]
FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)
//[file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F9F9F2F0-D514-487F-BF51-75788910393F/Pictures/]
```

實驗5: 其它路徑 Bundle.main.url，但會沒權限儲存
```
let r1 :URL? = Bundle.main.url(forResource: "bible_hakka", withExtension: ".zip")
//file:///var/folders/n5/glcqmrv14v32frcdrg9pknbm0000gn/T/com.apple.dt.Xcode.pg/resources/035F13D1-0C39-4965-849C-1914C76F0D19/bible_hakka.zip
//"You don’t have permission to save the file “bible_hakka.zip” in the folder
```
