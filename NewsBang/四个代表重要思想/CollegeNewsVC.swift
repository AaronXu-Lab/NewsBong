import UIKit
import Ji

class CollegeNewsVC: NewsPageController {
    override var categoryPath: String { "xyyw" }
    override var categoryTitle: String { "学院要闻" }
}

struct NewsListEntry {
    let name: String
    let date: String
    let url: String
}
struct ParsedNewsPage {
    let entries: [NewsListEntry]
    let pageCount: Int
    static func parse(_ data: Data, baseURL: URL) -> ParsedNewsPage {
        guard let document = Ji(htmlData: data) else { return ParsedNewsPage(entries: [], pageCount: 1) }
        let nodes = document.xPath("//*[starts-with(@id,'line_u8_')]") ?? []
        let entries = nodes.compactMap { node -> NewsListEntry? in
            guard let link = node.childrenWithName("a").first, let name = link.content,
                  let href = link.attributes["href"], let address = URL(string: href, relativeTo: baseURL)?.absoluteURL,
                  ["http", "https"].contains(address.scheme ?? "") else { return nil }
            return NewsListEntry(name: name, date: node.childrenWithName("span").first?.content ?? "", url: address.absoluteString)
        }
        let pagination = document.xPath("//*[@id='fanyeu8']")?.first?.content ?? ""
        let total = pagination.split(separator: "/").dropFirst().first.map { String($0.prefix(while: { $0.isNumber })) }.flatMap(Int.init) ?? 1
        return ParsedNewsPage(entries: entries, pageCount: max(1, total))
    }
}

class NewsPageController: UITableViewController {
    var categoryPath: String { "xyyw" }
    var categoryTitle: String { "新闻" }
    var footViewHeight: CGFloat?
    private var entries: [NewsListEntry] = []
    private var nextPage: Int?
    private var loading = false
    private var request: URLSessionDataTask?
    private var baseURL: URL { URL(string: "http://sjic.hust.edu.cn/xwzx/\(categoryPath).htm")! }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadNews), for: .valueChanged)
        loadPage(reset: true)
    }
    deinit { request?.cancel() }
    @objc private func reloadNews() { loadPage(reset: true) }
    private func footer(_ text: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: max(44, footViewHeight ?? 44)))
        label.text = text; label.textAlignment = .center; label.font = .systemFont(ofSize: 13); label.textColor = .secondaryLabel
        tableView.tableFooterView = label
    }
    private func loadPage(reset: Bool) {
        guard !loading else { return }
        guard reset || nextPage != nil else { return }
        let address = reset ? baseURL : baseURL.deletingPathExtension().appendingPathComponent("\(nextPage!).htm")
        loading = true; footer("正在加载…")
        request = URLSession.shared.dataTask(with: URLRequest(url: address, timeoutInterval: 20)) { [weak self] data, response, error in
            let valid = error == nil && (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } == true
            let parsed = valid ? data.map { ParsedNewsPage.parse($0, baseURL: address) } : nil
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loading = false; self.refreshControl?.endRefreshing()
                guard let parsed = parsed, !parsed.entries.isEmpty else {
                    self.footer("数据源暂不可用，下拉可重试"); return
                }
                if reset { self.entries = []; self.nextPage = parsed.pageCount > 1 ? parsed.pageCount - 1 : nil }
                else { self.nextPage = self.nextPage.flatMap { $0 > 1 ? $0 - 1 : nil } }
                let existing = Set(self.entries.map { $0.url })
                self.entries.append(contentsOf: parsed.entries.filter { !existing.contains($0.url) })
                self.tableView.reloadData(); self.footer(self.nextPage == nil ? "没有更多内容" : "上拉加载更多")
            }
        }
        request?.resume()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { entries.count }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 71 }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CollegeNewsCell
        let entry = entries[indexPath.row]; cell.name.text = entry.name; cell.date.text = entry.date
        cell.isAccessibilityElement = true; cell.accessibilityLabel = entry.name; cell.accessibilityTraits = .button
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let page = storyboard?.instantiateViewController(withIdentifier: "ArticlePage") as? ArticlePageVC else { return }
        let entry = entries[indexPath.row]; page.url = entry.url; page.name = entry.name; page.date = entry.date; page.from = categoryTitle
        page.hidesBottomBarWhenPushed = true; navigationController?.pushViewController(page, animated: true)
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !entries.isEmpty, scrollView.contentOffset.y > max(0, scrollView.contentSize.height - scrollView.bounds.height) else { return }
        loadPage(reset: false)
    }
}
