import UIKit
import RealmSwift

final class LocalProfile: Object {
    @Persisted(primaryKey: true) var id = "local"
    @Persisted var name = "本地用户"
    @Persisted var avatar = Data()
}
final class LocalArticle: Object {
    @Persisted(primaryKey: true) var url = ""
    @Persisted var name = ""
    @Persisted var date = ""
    @Persisted var isFavorite = false
    @Persisted var visitedAt = Date()
}
final class LocalNote: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var url = ""
    @Persisted var content = ""
    @Persisted var createdAt = Date()
}
final class StoredDocument: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var kind = ""
    @Persisted var json = Data()
}
// Detached field dictionaries preserve the existing course/teacher schema while Realm owns persistence.
final class LocalDocument: NSObject {
    let kind: String
    var id = UUID().uuidString
    var fields: [String: Any] = [:]
    init(className: String) { kind = className; super.init() }
    @objc subscript(key: String) -> Any? {
        get { fields[key] }
        set { fields[key] = newValue }
    }
    override func value(forKey key: String) -> Any? { fields[key] }
    func saveInBackground(_ completion: (Bool, Error?) -> Void) {
        do {
            let realm = try Realm(); let record = StoredDocument()
            record.id = id; record.kind = kind; record.json = try JSONSerialization.data(withJSONObject: fields)
            try realm.write { realm.add(record, update: .modified) }; completion(true, nil)
        } catch { completion(false, error) }
    }
}
final class LocalQuery {
    let kind: String
    var filters: [String: Any] = [:]
    init(className: String) { kind = className }
    func whereKey(_ key: String, equalTo value: Any?) { filters[key] = value }
    func findObjectsInBackground(_ completion: ([Any]?, Error?) -> Void) {
        do {
            let realm = try Realm()
            let documents = try realm.objects(StoredDocument.self).filter("kind == %@", kind).compactMap { record -> LocalDocument? in
                let fields = try JSONSerialization.jsonObject(with: record.json) as? [String: Any] ?? [:]
                guard filters.allSatisfy({ key, value in (fields[key] as? NSObject)?.isEqual(value) == true }) else { return nil }
                let document = LocalDocument(className: kind); document.id = record.id; document.fields = fields; return document
            }
            completion(Array(documents), nil)
        } catch { completion(nil, error) }
    }
}
extension UIViewController {
    func showLocalError(_ error: Error) {
        let alert = UIAlertController(title: "操作失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel)); present(alert, animated: true)
    }
}

struct LocalArticleStore {
    static func save(url: String, name: String, date: String, toggleFavorite: Bool = false) throws -> LocalArticle {
        let realm = try Realm()
        let article = realm.object(ofType: LocalArticle.self, forPrimaryKey: url) ?? LocalArticle()
        // Realm primary keys are immutable once the object is managed, even when the value is unchanged.
        if article.realm == nil { article.url = url }
        try realm.write {
            if !name.isEmpty { article.name = name }
            article.date = date; article.visitedAt = Date()
            if toggleFavorite { article.isFavorite.toggle() }
            realm.add(article, update: .modified)
        }
        return article
    }
}
