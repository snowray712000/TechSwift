---
title: ios path Bundle.main 、 FileManager.default.urls
tags: ios, path
---
ios path Bundle.main 、 FileManager.default.urls
---
# 1. playground 的 resources 
![](https://i.imgur.com/lnvTiF0.png)
- 手動加檔進去，再用 Bundle.main.paths 可以取得
- 權限
    - 當你要寫檔案進去時，不行。沒有權限。(所以無用)
- 這路徑根目錄
    - 透過 Bundle.main.paths(forResourcesOfType: "", inDirectory: nil) 可取得, 目前所有檔案 (因為沒有指定型別)
    - 承上，可發現 Info.plist，而且有2個。
        - 這個是 /var/folders/n5/glcqmrv14v32frcdrg9pknbm0000gn/T/com.apple.dt.Xcode.pg\/resources/93B46321-D984-486D-B12A-26C5323E63A0/Info.plist"
        - 這個不是 /Users/snowray712000gmail.com\/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Bundle/Application/8A1A5100-36A0-4B9F-9E8F-E9B7BE065238/試作_主界面-1317-4.app\/Info.plist

```swift=
Bundle.main.paths(forResourcesOfType: "", inDirectory: nil)
```

# 2 實際可用路徑
- 暫存、下載、我的文件、我的圖片
```swift=
FileManager.default.temporaryDirectory
//file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F06D7984-E968-4AA2-941F-E115EFA1FF92/tmp/
FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
//[file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F06D7984-E968-4AA2-941F-E115EFA1FF92/Downloads/]
FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//[file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F06D7984-E968-4AA2-941F-E115EFA1FF92/Documents/]
FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)
//[file:///Users/snowray712000gmail.com/Library/Developer/XCPGDevices/17784844-9F66-4C26-901A-A525C8E581A3/data/Containers/Data/Application/F06D7984-E968-4AA2-941F-E115EFA1FF92/Pictures/]
```
