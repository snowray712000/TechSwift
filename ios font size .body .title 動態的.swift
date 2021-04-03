//: A UIKit based Playground for presenting user interface
  
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
        
        tv.adjustsFontForContentSizeCategory = true
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        
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
        
        let texts = NSMutableAttributedString()
        texts.append(generateAttributedString("摩西", .normal))
        texts.append(generateAttributedString("(T1253)", .sn))
        texts.append(generateAttributedString("心痛",  .key(0)))
        
        ptv.attributedText = texts
        
        tableView.rowHeight =  ptv.intrinsicContentSize.height
        return cell
    }
    func generateAttributedString(_ str: String,_ tp: TextType)->NSAttributedString{
        let iAG : IAttributesGetter = GetAttributes()
        return NSAttributedString(string: str, attributes: iAG.getFontAndColor(tp))
    }
}
public enum TextType{
    case sn
    case normal
    case key(Int)
}
public protocol IAttributesGetter {
    func getFontAndColor(_ tp: TextType) -> [NSAttributedString.Key : Any]?
}
class GetAttributes : IAttributesGetter{
    func getFontAndColor(_ tp: TextType) -> [NSAttributedString.Key : Any]? {
        
        return [
            NSAttributedString.Key.foregroundColor : getColor(tp),
            NSAttributedString.Key.font : getScaleFontd(.body)
        ]
    }
    func getColor(_ tp: TextType ) -> UIColor {
        switch tp {
        case .normal:
            return UIColor.darkText
        case .sn:
            return UIColor.systemBlue
        case .key(0):
            return UIColor.red
        case .key(1):
            return UIColor.orange
        default:
            return UIColor.lightText
        }
    }
    func getScaleFontd(_ style : UIFont.TextStyle) -> UIFont {
    
        let ft = UIFont.preferredFont(forTextStyle: style)
        return UIFont(descriptor: ft.fontDescriptor, size: ft.pointSize * CGFloat(fontScale))
    }
        
    
    var fontScale = 2.0
}
PlaygroundPage.current.liveView = MyViewController()
