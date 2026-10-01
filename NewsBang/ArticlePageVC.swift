import UIKit
import WebKit
import RealmSwift

class ArticlePageVC: UIViewController, WKNavigationDelegate {
    var url = ""
    var name = ""
    var date = ""
    var from = ""
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionBtnLeft: NSLayoutConstraint!
    @IBOutlet weak var shareBtnRight: NSLayoutConstraint!
    @IBOutlet weak var collectionBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    private let browser = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad(); title = from
        nameLb.text = name; dateLb.text = date
        browser.navigationDelegate = self; browser.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(browser)
        NSLayoutConstraint.activate([browser.topAnchor.constraint(equalTo: webView.topAnchor), browser.bottomAnchor.constraint(equalTo: webView.bottomAnchor), browser.leadingAnchor.constraint(equalTo: webView.leadingAnchor), browser.trailingAnchor.constraint(equalTo: webView.trailingAnchor)])
        commentBtn.setTitle("笔记", for: .normal)
        commentBtn.accessibilityLabel = "本地笔记"
        collectionBtn.accessibilityLabel = "收藏"
        shareBtn.accessibilityLabel = "分享链接"
        guard let address = URL(string: url), ["https", "http"].contains(address.scheme ?? "") else { return }
        browser.load(URLRequest(url: address))
        do {
            let article = try LocalArticleStore.save(url: url, name: name, date: date)
            collectionBtn.isSelected = article.isFavorite
        } catch { showLocalError(error) }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webViewHeight.constant = max(240, view.safeAreaLayoutGuide.layoutFrame.height - 170)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if name.isEmpty { name = webView.title ?? url; nameLb.text = name }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        nameLb.text = "网页暂时无法打开，收藏和本地笔记仍可使用"
    }
    @IBAction func collectionBtnAction(_ sender: UIButton) {
        do {
            let article = try LocalArticleStore.save(url: url, name: name, date: date, toggleFavorite: true)
            sender.isSelected = article.isFavorite
        } catch { showLocalError(error) }
    }
    @IBAction func commentBtnAction(_ sender: UIButton) {
        guard let notes = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as? CommentVC else { return }
        notes.url = url; navigationController?.pushViewController(notes, animated: true)
    }
    @IBAction func shareBtnAction(_ sender: UIButton) {
        guard let address = URL(string: url) else { return }
        let share = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        share.popoverPresentationController?.sourceView = sender; share.popoverPresentationController?.sourceRect = sender.bounds
        present(share, animated: true)
    }
}
