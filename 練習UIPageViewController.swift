import UIKit
import PlaygroundSupport
import WebKit

class MyAppView : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UITableView()
        view.backgroundColor = .purple
        title = "主程式畫面"
    }
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "ready") {
            return
        }
        
        let pv = MyPageView(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.spineLocation : UIPageViewController.SpineLocation.min.rawValue, UIPageViewController.OptionsKey.interPageSpacing : 1.5 ])
        present(pv, animated: true, completion: nil)
    }
}


class MyPageView : UIPageViewController, UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == page2 {
            return page1!
        } else if viewController == page3 {
            return page2!
        }
        
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == page1 {
            return page2!
        } else if viewController == page2 {
            return page3!
        }
        
        return nil
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    var page1: UITableViewController?
    var page2: UIViewController?
    var page3: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        page1 = UITableViewController()
        page1?.view.backgroundColor = .yellow
        page2 = UIViewController()
        page2?.view.backgroundColor = .red
        page3 = UIViewController()
        let p3v = WKWebView()
        p3v.load(URLRequest(url: URL(string: "https://www.google.com/")!))
        page3!.view = p3v
        
        dataSource = self
        setViewControllers([page1!], direction: .forward, animated: true, completion: nil)
        
        let btn = UIButton()
        btn.setTitle("Go", for: .normal)
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(onClickBtn), for: UIControl.Event.touchDown)
        
        page3!.view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.bottomAnchor.constraint(equalTo: page3!.view.bottomAnchor).isActive = true
        btn.rightAnchor.constraint(equalTo: page3!.view.rightAnchor).isActive = true
        
    }
    @objc func onClickBtn(_ sender: UIButton,_ ev: UIEvent){
        print(ev)
        print(sender)
        dismiss(animated: true, completion: nil)
        
        UserDefaults.standard.setValue(true, forKey: "ready")
    }
   
}
PlaygroundPage.current.liveView = MyAppView()

