import UIKit
import PlaygroundSupport

class MyCell : UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        if isInitTextview == false {
            initTextView()
        }
    }
    func initTextView(){
        self.textView = UITextView()
        guard let tv = self.textView else {
            return
        }
        tv.backgroundColor = .yellow
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textAlignment = .justified
        
        let pv = contentView // parent view
        tv.tag = 1
        pv.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tv.centerYAnchor.constraint(equalTo: pv.centerYAnchor),
            tv.leftAnchor.constraint(equalTo: pv.leftAnchor),
            tv.rightAnchor.constraint(equalTo: pv.rightAnchor)
        ])
        
    }
    var textView: UITextView?
    var isInitTextview : Bool {
        return textView != nil
    }
    var pTextView : UITextView {
        assert ( isInitTextview )
        return contentView.viewWithTag(1)! as! UITextView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
class MyViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as! UITableView).register(MyCell.self, forCellReuseIdentifier: "MyCell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell
        
        let ptv = cell.pTextView
        ptv.attributedText = NSAttributedString(string: "hi", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        tableView.rowHeight = ptv.intrinsicContentSize.height
        return cell
    }
}
PlaygroundPage.current.liveView = MyViewController()
