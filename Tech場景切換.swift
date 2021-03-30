import UIKit
import PlaygroundSupport

class MyCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class MyTable : UITableViewController {
    override func viewDidLoad() {
        tableView.register(MyCell.self, forCellReuseIdentifier: "Cell")
        title = "這是第一頁"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let data = ["1=1","2-2","3-3","4-4"]
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = ["1=1","2-2","3-3","4-4"]
        let text = data  [indexPath.row]
        
        let view2 = MyTable2()
        view2.msg = text
        navigationController?.pushViewController(view2, animated: true)
    }
}
class MyTable2 : UITableViewController {
    public var msg = ""
}
let view1 = MyTable()
let nav = UINavigationController(rootViewController: view1)

PlaygroundPage.current.liveView = nav
