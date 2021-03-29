//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


class MyViewController : UIViewController, UITableViewDataSource {
    override func loadView() {
        let view = UITableView()
        view.register(MyCell.self, forCellReuseIdentifier: "cell")
        view.dataSource = self
        self.view = view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCell
        
        cell.makeSureTextViewExist(tableView)
        
        guard let tv = cell.pTextView else { return cell }
        
        testTexts(indexPath.row, tv)
        
        tableView.rowHeight = tv.intrinsicContentSize.height + tv.textContainerInset.top
 
        return cell
    }
    func testTexts(_ rowIdx: Int,_ tv: UITextView){
        func createAttributedString(_ str:String,_ color: UIColor)  -> NSAttributedString {
            
            return NSAttributedString(string: str, attributes: [ NSAttributedString.Key.foregroundColor : color ])
        }
        
        // 當設定完後， text view 的 intrinsicContentSize 會自動重算
        if rowIdx == 1 {
            tv.attributedText = createAttributedString("這是一個", .red)
        } else {
            tv.attributedText = createAttributedString("這是一很長的，很長的。\n多行的資料  soijfiojaio iowjefo iaw gjio ioajweoigj aiooigjaowij g joawijego awegoijaw gjoiwje giawje oaiwjg ", .blue)
        }
    }
}


class MyCell : UITableViewCell {
    var pTextView : UITextView? {
        return contentView.viewWithTag(1) as! UITextView?
    }
    var pTableView : UITableView?
    var isNotInitTextViewYet : Bool {
        return pTextView == nil
    }
    func makeSureTextViewExist(_ tableview : UITableView){
        if ( isNotInitTextViewYet ){
            self.pTableView = tableview
            initTextView()
        }
    }
    func initTextView(){
        let v = UITextView()
        v.tag = 1
        contentView.addSubview(v)
        
        self.addConstraintInCell(v)

        self.setApperance(v)
        
        self.setClick(v)
    }
    private func setApperance(_ v:UITextView){
        v.isScrollEnabled = false
        v.isEditable = false
        v.isSelectable = false
        v.textAlignment = .justified
    }
    private func addConstraintInCell(_ v: UITextView){
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
    private func setClick(_ v:UITextView){
        v.addGestureRecognizer( UITapGestureRecognizer( target: self, action: #selector(tapOnce) ) )
    }
    
    @objc func tapOnce(_ gs: UITapGestureRecognizer){
        let v = pTextView!
        
        let idxChar = DetermineWhichCharClicked().MainForTextview(gs.location(in: v), v)
    }
}
public class DetermineWhichCharClicked {
    public func MainForTextview(_ xyTap: CGPoint,_ v: UITextView) -> Int {
        
        var xy = xyTap
        xy.x -= v.textContainerInset.left
        xy.y -= v.textContainerInset.top
        
        xy
        
        if isNotInFirstAndEndCharacter(xy, v) {
            return -1
        }
        
        let m = v.layoutManager
        return m.characterIndex(for: xy, in: v.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }
    private func isNotInFirstAndEndCharacter(_ p: CGPoint,_ v: UITextView) -> Bool {
        let m = v.layoutManager
        let texts = m.textStorage!.length
        let rr1 = m.boundingRect(forGlyphRange: NSRange(location: 0, length: 1), in: m.textContainers[0]) // {5,0}
        let rr2 = m.boundingRect(forGlyphRange: NSRange(location: texts-1, length: 1), in: m.textContainers[0]) // {231,46}
 
        
        if p.x < rr1.minX || p.y < rr1.minY {
            return true // not in
        }
        if p.y > rr2.maxY {
            return true // not in
        }

        if  rr2.minY <= p.y && p.y <= rr2.maxY  {
            if p.x > rr2.maxX {
                return true
            }
        }
        
        return false
    }
}

PlaygroundPage.current.liveView = MyViewController()
