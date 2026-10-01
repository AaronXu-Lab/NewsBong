import UIKit
import RealmSwift

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var url = ""
    private var notes: [LocalNote] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentInput: UITextField!
    @IBOutlet weak var commentSendBtn: UIButton!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad(); title = "本地笔记"
        commentInput.placeholder = "笔记仅自己可见"; commentSendBtn.setTitle("保存", for: .normal)
        tableView.delegate = self; tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        loadNotes()
    }
    @objc private func keyboard(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = max(0, view.bounds.maxY - view.convert(frame, from: nil).minY - view.safeAreaInsets.bottom)
        tableViewBottom.constant = overlap; inputViewBottom.constant = overlap
    }
    func loadNotes() {
        do { let realm = try Realm(); notes = Array(realm.objects(LocalNote.self).filter("url == %@", url).sorted(byKeyPath: "createdAt")); tableView.reloadData() } catch { showLocalError(error) }
    }
    @IBAction func commentSendAction(_ sender: UIButton) {
        guard let text = commentInput.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        do {
            let realm = try Realm(); let note = LocalNote(); note.url = url; note.content = text
            try realm.write { realm.add(note) }; commentInput.text = ""; view.endEditing(true); loadNotes()
        } catch { showLocalError(error) }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { notes.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = notes[indexPath.row].content; cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = notes[indexPath.row].createdAt.formatted(); return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        do { let realm = try Realm(); try realm.write { realm.delete(notes[indexPath.row]) }; loadNotes() } catch { showLocalError(error) }
    }
}
