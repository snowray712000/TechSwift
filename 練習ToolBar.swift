//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
class ViewApp : UIViewController {
    override func loadView() {
        let ratio = 750.0 / 1334.0
        let cy = 480.0
        view = UIView(frame:  CGRect(x: 0,y: 0,width: ratio * cy, height: cy))
    }
    override func viewDidAppear(_ animated: Bool) {
        let nav = UINavigationController(rootViewController: MyView1())
        present(nav, animated: true, completion:nil)
    }
}

class MyView1 : UIViewController {
    override func loadView() {
        super.loadView()
        let view = UITableView()
        view.backgroundColor = .yellow
        self.view = view
    }
    @objc func onClickBtn1(_ s : UIBarButtonItem){
        
    }
    @objc func onClickBtn2(_ s : UIBarButtonItem){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let r1 = [ UIBarButtonItem(title: "Left1", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left2", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left3", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left4", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left5", style: .plain, target: nil, action: nil),
                     UIBarButtonItem(title: "Left6", style: .plain, target: nil, action: nil),
        ]
        setToolbarItems(r1, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        
        title = "設定"
    }
    func setTopToolbar(){
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Right1", style: .plain, target: self, action: #selector(onClickBtn1)),
            UIBarButtonItem(title: "Right2", style: .plain, target: nil, action: nil)
        ]
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Left1", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Left2", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Left3", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "Left4", style: .plain, target: nil, action: nil)
        ]
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

PlaygroundPage.current.liveView = ViewApp()
