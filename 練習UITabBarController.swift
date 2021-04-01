//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
func addConstrainsToCenter(_ v:UIView,_ pv:UIView){
    v.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        v.centerYAnchor.constraint(equalTo: pv.centerYAnchor),
        v.centerXAnchor.constraint(equalTo: pv.centerXAnchor)
    ])
}
 
class MyView1 : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = UIButton(primaryAction: UIAction(handler: {_ in
            let rnew = UIViewController()
            rnew.view = UITableView()

            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(rnew, animated: true)
            
        }))
        btn1.setTitle("push", for: .normal)
        view.addSubview(btn1)
        addConstrainsToCenter(btn1, view)
    }
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
}
class MyView2 : UITableViewController{}

class MyTab1 : UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view1Item = UITabBarItem(title: "First", image: .checkmark, selectedImage: .checkmark)
        view1Item.tag = 0
        let view1 = MyView1()
        view1.tabBarItem = view1Item
     
        let view2 = MyView2()
        let item2 = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.history, tag: 1)
        view2.tabBarItem = item2
        
        let iList = [view1,view2]
        let iList2 = iList.map({UINavigationController(rootViewController: $0)})
        viewControllers = iList2
    }
}
PlaygroundPage.current.liveView = MyTab1()
