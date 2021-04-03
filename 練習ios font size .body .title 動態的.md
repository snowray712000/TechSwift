---
title: ios font size .body .title 動態的
tags: ios, font,
---
ios font size .body .title 動態的
---
# 情境描述
當使用 TextView 在 Cell 中時，字是小很多(比起 Label 在 Cell 中)。


# 目標
- 系統設定的字大小，會影響 app
- app 內部也有一個 scale 值
- app 內部有再分 經文 scale 值、所有 sacle 值

# survey
- apple 規畫 title1 title2 body ... 等等，而非直接設定 20pt 之類的。請參閱
    - https://segmentfault.com/a/1190000011176461
- 承上，此稱為 Dynamic Type
    - 關鍵函式 adjustsFontForContentSizeCategory UIFontMetrics UIContentSizeCategory
- 事件 (若系統改了，要跟著變，我們還不打算作那麼高級)
    - https://stackoverflow.com/questions/18951332/how-to-detect-dynamic-font-size-changes-from-ios-settings

# 實驗結果
- .attributedText 不受影響
    - 經實驗，若是 attributedText 是無效的；若你只是設定 .font = UIFont. prefer.... 。但若你的文字是來自 .text 而非 .attributedText 則有效。
- 使 .attributedText 也可用 Dynamic Type
    - 關鍵在 NSAttributedString.Key.font
```swift
let ft = UIFont.preferredFont(forTextStyle: .title1)
ptv.attributedText = NSAttributedString(string: "hi", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red, NSAttributedString.Key.font : ft])
```
- 使用 .body 的字大小，再縮放
    - 假設，目前系統取得 .body 字大小是 17、我要用此字型，產生 1.5 倍大的字型供 attributedText 使用
```swift=
let ft = UIFont.preferredFont(forTextStyle: .body)
ft.pointSize // 17
let ft2 = UIFont.init(descriptor: ft.fontDescriptor, size: ft.pointSize * 1.5)
ptv.attributedText = NSAttributedString(string: "hi", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red, NSAttributedString.Key.font : ft2 ])
```

# 規畫
- 全域 字型大小 管理的
    - 可透過 protocol 、 「經文 font」之類的、「scale」值。
