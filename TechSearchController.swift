import UIKit
import PlaygroundSupport

class MyTable : UITableViewController, UISearchResultsUpdating {
    override func viewDidLoad() {
        title = "加入搜尋工具"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchBar = UISearchController(searchResultsController: nil)
//        searchBar?.searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar?.searchBar
        definesPresentationContext = true // 此功能說明 https://www.jianshu.com/p/b065413cbf57
        
        searchBar?.searchResultsUpdater = self
        
        searchBar?.searchBar.placeholder = "沒有文字時，顯示的內容"
        searchBar?.searchBar.prompt = "欄位上方，再一行文字"
        searchBar?.searchBar.backgroundColor = .blue
        searchBar?.searchBar.tintColor = .red
    }
    var searchBar: UISearchController?
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "123"
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text) // 輸入一個字母，就會執行一次
        
        tableView.reloadData() //一般會 重刷資料
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return searchBar?.isActive == false
    }
}

PlaygroundPage.current.liveView = MyTable()
