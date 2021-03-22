# ios sqlite

當有一個檔案 .sqlite3，要怎麼作為專案的資料庫呢？

參考: https://github.com/kean/SwiftSQL

使用的資料庫: ftp://ftp.fhl.net/pub/FHL/COBS/data/bible_gb_asv.zip

sqlite 工具: https://sqlitebrowser.org/

好像有這些 api
```swift=
import SQLite3

sqlite3_open_v2
sqlite3_close_v2
sqlite3_exec
sqlite3_prepare_v3
sqlite3_interrupt
sqlite3_last_insert_rowid
sqlite3_bind_parameter_index
sqlite3_set_last_insert_rowid
sqlite3_errmsg
sqlite3_step
sqlite3_bind_null
sqlite3_reset
```

實驗1: connect sqlite 、 close 
```swift=
// sqlite3_open_v2 所需的參數與型態
var filename: UnsafePointer<Int8>? = nil
var ppDb: UnsafeMutablePointer<OpaquePointer?>? = nil
var flag: Int32 = 0
var zVfs: UnsafePointer<Int8>? = nil

// 參數1: string 轉為 Int8* 是關鍵
let path = Bundle.main.url(forResource: "bible_asv", withExtension: ".db")
let r1 = path?.absoluteString.data(using: .utf8)
filename = (r1! as NSData).bytes.assumingMemoryBound(to: Int8.self)

// 參數2: connect 關鍵 output, 產生的資料就會存在這指標
var pDb: OpaquePointer? = nil
// ppDb = &pDb // 概念是這樣，但在這寫會 compile error，只有傳參數的時候才能傳

// 參數3: 現在用2個，其它列出來，作參考
flag |= SQLITE_OPEN_READONLY
//flag |= SQLITE_OPEN_READWRITE
//flag |= SQLITE_OPEN_CREATE
//flag |= SQLITE_OPEN_MEMORY
flag |= SQLITE_OPEN_SHAREDCACHE
//flag |= SQLITE_OPEN_PRIVATECACHE
//flag |= SQLITE_OPEN_NOMUTEX // multithreaded
//flag |= SQLITE_OPEN_FULLMUTEX

// 參數4: 很多人都傳 nil。
zVfs = nil
assert ( SQLITE_OK == sqlite3_open_v2(filename!, &pDb, flag, zVfs))
// pDb 此值，呼叫前nil, 呼叫後 0x00007fbe0a609260
defer {
    sqlite3_close_v2(pDb)
}
```

實驗2: 使用 select 指令
實驗2a: sqlite select
```sql=
SELECT * from asv LIMIT 10
```
實驗2b: 在 程式中使用 
```swift=
// 使用 sqlite3_prepare_v2 與 sqlite3_finalize 初始化與釋放 statement
let strSQL = "SELECT * from asv LIMIT 10"
let strSQLp = stringToInt8Pointer(str: strSQL) // 按上面寫了一個小函式
var stmt: OpaquePointer? = nil
var pzTail: UnsafePointer<Int8>? = nil
var reSQLite3 = sqlite3_prepare_v2(pDb!, strSQLp.ptr, Int32(strSQLp.len), &stmt, nil)
assert(reSQLite3 == SQLITE_OK)
defer{
    sqlite3_finalize(stmt) // 釋放 stmt
}

// 使用 sqlite3_step 查詢每一行，再用 sqlite3_column_text 取得資料
let cnt = sqlite3_column_count(stmt)
while true {
    if ( SQLITE_ROW != sqlite3_step(stmt) ){
        break // 若不是，表示已經結束了，每列資料取完了
    }
    let id = sqlite3_column_int64(stmt, 0)
    let engs = sqlite3_column_text(stmt, 1)
    let engs2 = engs != nil ? String(cString: engs!) : ""
    let chap = sqlite3_column_int(stmt, 2)
    let sec = sqlite3_column_int(stmt, 3)
    let txt = sqlite3_column_text(stmt, 4)
    let txt2 = txt != nil ? String(cString: txt!) : ""
}
```
實驗3c: column 其它相關 (取得 col 的 name 與 type )
- sqlite3_column_name sqlite3_column_type 
- type 官網 https://www.sqlite.org/c3ref/c_blob.html
- 注意! 當某 col 可允許 null 時， string type 會變為 null type。
- 注意! 官網說，版本3，不論是 int 或是 float 都是用 64 bit，雖然有提供32 bit 的函式。
```swift=
let cnt = sqlite3_column_count(stmt)
for a1 in 0..<cnt {
    let r1 = sqlite3_column_type(stmt, a1)
    let r2 = String(cString: sqlite3_column_name(stmt, a1)!) // id    engs    chap    sec    txt
    r1 == SQLITE_INTEGER // 對應 sqlite3_column_int64
    r1 == SQLITE_TEXT // 對應 sqlite3_column_text 用 String( cString: ) 轉換
    r1 == SQLITE_FLOAT // 對應 sqlite3_column_double
    r1 == SQLITE_BLOB // sqlite3_column_blob or sqlite3_column_bytes
    r1 == SQLITE_NULL
}
```

實驗4: 在查詢指令加入變數
實驗4a: bind int
- 將實驗2 中的 10，換為變數； SELECT * from asv LIMIT 10
```swift=
let strSQL = "SELECT * from asv LIMIT :cnt"
let strSQLp = stringToInt8Pointer(str: strSQL)
var stmt: OpaquePointer? = nil
var pzTail: UnsafePointer<Int8>? = nil
var reSQLite3 = sqlite3_prepare_v2(pDb!, strSQLp.ptr, Int32(strSQLp.len), &stmt, nil)
assert(reSQLite3 == SQLITE_OK)
defer{
    sqlite3_finalize(stmt) // 釋放 stmt
}

// bind 變數
var idx : Int32?
idx = sqlite3_bind_parameter_index(stmt, ":cnt")
sqlite3_bind_int64(stmt, idx!, 5)

// 下面執行結果，成功從10次變為5次。
```
實驗4b: bind text 成功
- 先在 sql 工具中測試 okay
- 用法在 行16-19
- text 使用難在 行19 的第5個變數，它是表示，完成後要一個 callback 函式，但是傳 nil 似乎不行，而有的範例用 SQLITE_TRANSIENT 或 SQLITE_STATIC 但也不行，因為沒有定義。它們官網定義在這  https://www.sqlite.org/c3ref/c_static.html
- 使用 bind text 有好處！就是若出現單引號，會作一些處理。
```sql=
SELECT * from asv WHERE engs='Gen' LIMIT 10
```
```swift=
let strSQL = "SELECT * from asv WHERE engs=:book LIMIT :cnt"
let strSQLp = stringToInt8Pointer(str: strSQL)
var stmt: OpaquePointer? = nil
var pzTail: UnsafePointer<Int8>? = nil
var reSQLite3 = sqlite3_prepare_v2(pDb!, strSQLp.ptr, Int32(strSQLp.len), &stmt, nil)
assert(reSQLite3 == SQLITE_OK)
defer{
    sqlite3_finalize(stmt) // 釋放 stmt
}

// bind 變數
var idx : Int32?
idx = sqlite3_bind_parameter_index(stmt, ":cnt")
sqlite3_bind_int64(stmt, idx!, 5)

idx = sqlite3_bind_parameter_index(stmt, stringToInt8Pointer(str: ":book").ptr)
var strTmp = stringToInt8Pointer(str: "John")
func fnSqliteStatic(ptr: UnsafeMutableRawPointer?) -> Void {}
sqlite3_bind_text (stmt, idx!, strTmp.ptr, Int32(strTmp.len), fnSqliteStatic)
```

實驗5: 優化效率 - reset statement
- statement 用完一次，若 sql 指定沒變，可再重新使用

```swift=
// 上面已經用完，或是 step 到一半也行。

sqlite3_reset(stmt)

idx = sqlite3_bind_parameter_index(stmt, ":cnt")
sqlite3_bind_int64(stmt, idx!, 7)

idx = sqlite3_bind_parameter_index(stmt, stringToInt8Pointer(str: ":book").ptr)
strTmp = stringToInt8Pointer(str: "Luke")
sqlite3_bind_text (stmt, idx!, strTmp.ptr, Int32(strTmp.len), fnSqliteStatic)
while true {
    if ( SQLITE_ROW != sqlite3_step(stmt) ){
        break // 若不是，表示已經結束了，每列資料取完了
    }
    
    let id = sqlite3_column_int64(stmt, 0)
}

```

