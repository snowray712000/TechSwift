//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  tableView.tableHeaderView == nil {
            
            let r1 = UILabel()
            r1.text  = "table header view"
            
            // 必需在 addSubView 之前
            r1.bounds.size.height = 20
            tableView.addSubview(r1)
            tableView.tableHeaderView = r1
            // r1.isHidden = false 預設就是
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "section title \(section)"
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "section foot \(section)"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ( section == 0 ){
            return 3
        } else {
            return 2
        }
    }
    func makeSureCellRegisted(){
        if tableView.dequeueReusableCell(withIdentifier: "cell") == nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        makeSureCellRegisted()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.section) \(indexPath.row)"
        
        return cell
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
