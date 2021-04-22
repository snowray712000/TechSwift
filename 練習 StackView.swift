/// 210422
/// 聖經多版本，平行時，要將 TableViewCell 平分 column
/// 先以 View 試 StackView ， 這個成功了 ， 再用 TableViewCell 切看看可行嗎

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIStackView()
        view.axis = .horizontal
        
        // 動態的變更
        view.addArrangedSubview
        view.insertArrangedSubview
        view.removeArrangedSubview
        
        view.addArrangedSubview( testTextView( "1234agijv\nasdijf" ) )
        view.addArrangedSubview( testTextView( "afweg\nasgacdijf\nafeg\nafije" ) )
        
        // 是2個容器，但 addArranged 後， subviews 中也會有
        view.arrangedSubviews
        view.subviews
        
        // subviews 的順序，決定繪圖順序
        // arrangedSubvies 順序，決定最後排的結果
        
        view.distribution = .fillEqually
        
        self.view = view
    }
    func testTextView(_ str:String) -> UITextView {
        let re = UITextView()
        re.text = str
        re.layer.borderColor = CGColor(gray: 0, alpha: 1.0)
        re.layer.borderWidth = 1.0
        re.layer.cornerRadius = 5.0
        return re
    }
}
PlaygroundPage.current.liveView = MyViewController()
