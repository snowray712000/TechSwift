/// 可以成功將 TableViewCell 以 StackView 平均分割寬
/// 但，速度初始化的時候，很慢。約有 2-3 sec
  
import UIKit
import PlaygroundSupport

class MyViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MyCell.self, forCellReuseIdentifier: "cell")
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell
        cell.cellFRA(tableView, indexPath)

        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
}
class MyCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func cellFRA(_ tv: UITableView, _ indexPath: IndexPath ) {
        makeSureAddFirstStackView()
        
        // tv rowheight (不再是用 intrinsicContentSize.height 改用 frame.height
        let sv = getStackView()
        tv.rowHeight = sv.frame.height
    }
    func getStackView() -> UIStackView {
        if contentView.viewWithTag(1) == nil {
            makeSureAddFirstStackView()
        }
        return contentView.viewWithTag(1) as! UIStackView
    }
    func makeSureAddFirstStackView(){
        if ( contentView.viewWithTag(1) == nil ) {
            let re = UIStackView()
            re.axis = .horizontal

            re.backgroundColor = .blue
            re.tag = 1
            contentView.addSubview(re)
            addConstraintInCell(re)
            
//
            re.addArrangedSubview(gTestTextView("asgeg\naweowej"))
            re.addArrangedSubview(gTestTextView("asgeg\naweogawegawe\naweoifj\niwoewej"))
//
//            re.alignment = .fill
//            re.distribution = .fillEqually
            re.distribution = .fill
        }
    }
    func gTestTextView(_ str: String) -> UITextView{
        let re = UITextView()
        re.text = str
        setApperance(re)
        re.backgroundColor = .yellow
        
        re.layer.cornerRadius = 5.0
        re.layer.borderWidth = 1.0
        return re
        
    }
    private func setApperance(_ v:UITextView){
        v.isScrollEnabled = false // 必需要這個
        v.isEditable = false
        v.isSelectable = false
        v.textAlignment = .justified
    }
    private func addConstraintInCell(_ v: UIView){
        // 必須在 被 addSubView 之後
        let vP = contentView
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.leftAnchor.constraint(equalTo: vP.leftAnchor),
            v.rightAnchor.constraint(equalTo: vP.rightAnchor),
            v.centerYAnchor.constraint(equalTo: vP.centerYAnchor)
        ])
        // conterY 比 top 好看
    }
}
PlaygroundPage.current.liveView = MyViewController()
