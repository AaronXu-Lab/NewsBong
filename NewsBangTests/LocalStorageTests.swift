import XCTest
import RealmSwift
@testable import NewsBang

final class LocalStorageTests: XCTestCase {
    private var previous: Realm.Configuration!
    private var directory: URL!
    override func setUpWithError() throws {
        previous = Realm.Configuration.defaultConfiguration
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: directory.appendingPathComponent("test.realm"))
    }
    override func tearDownWithError() throws {
        Realm.Configuration.defaultConfiguration = previous
        try FileManager.default.removeItem(at: directory)
    }
    func testFavoritesAndNotesSurviveReopen() throws {
        try autoreleasepool {
            let realm = try Realm(); let article = LocalArticle(); article.url = "https://example.com/news"; article.name = "测试新闻"; article.isFavorite = true
            let note = LocalNote(); note.url = article.url; note.content = "本地笔记"
            try realm.write { realm.add(article); realm.add(note) }
        }
        let realm = try Realm()
        XCTAssertEqual(realm.objects(LocalArticle.self).filter("isFavorite == true").first?.name, "测试新闻")
        XCTAssertEqual(realm.objects(LocalNote.self).first?.content, "本地笔记")
    }
    func testCourseDocumentPreservesNumbersArraysAndFilters() throws {
        let course = LocalDocument(className: "CourseItem")
        course["name"] = "测试课程"; course["weeks"] = [1, 3, 5]; course["gradeInNumber"] = 2026; course["isConfirm"] = true
        var saveError: Error?
        course.saveInBackground { success, error in XCTAssertTrue(success); saveError = error }
        XCTAssertNil(saveError)
        let query = LocalQuery(className: "CourseItem"); query.whereKey("gradeInNumber", equalTo: 2026); query.whereKey("isConfirm", equalTo: true)
        query.findObjectsInBackground { values, error in
            XCTAssertNil(error); XCTAssertEqual(values?.count, 1)
            let stored = values?.first as? LocalDocument
            XCTAssertEqual(stored?["weeks"] as? [Int], [1, 3, 5]); XCTAssertEqual(stored?["name"] as? String, "测试课程")
        }
        let other = LocalQuery(className: "TeacherTitleContact")
        other.findObjectsInBackground { values, error in XCTAssertNil(error); XCTAssertEqual(values?.count, 0) }
    }
    func testNewsParserHandlesMissingDatesPaginationAndRelativeLinks() {
        let html = "<html><body><div id='line_u8_0'><a href='../info/42.htm'>标题</a></div><div id='fanyeu8'>1/12</div></body></html>"
        let parsed = ParsedNewsPage.parse(Data(html.utf8), baseURL: URL(string: "https://example.com/xwzx/index.htm")!)
        XCTAssertEqual(parsed.entries.count, 1)
        XCTAssertEqual(parsed.entries.first?.url, "https://example.com/info/42.htm")
        XCTAssertEqual(parsed.entries.first?.date, "")
        XCTAssertEqual(parsed.pageCount, 12)
        XCTAssertTrue(ParsedNewsPage.parse(Data("<html>服务维护</html>".utf8), baseURL: URL(string: "https://example.com/")!).entries.isEmpty)
    }
    func testRevisitingExistingFavoriteDoesNotMutatePrimaryKey() throws {
        let first = try LocalArticleStore.save(url: "https://example.com/", name: "原标题", date: "今天", toggleFavorite: true)
        XCTAssertTrue(first.isFavorite)
        let revisit = try LocalArticleStore.save(url: first.url, name: "", date: "明天")
        XCTAssertTrue(revisit.isFavorite); XCTAssertEqual(revisit.name, "原标题")
        let removed = try LocalArticleStore.save(url: first.url, name: "", date: "明天", toggleFavorite: true)
        XCTAssertFalse(removed.isFavorite)
        XCTAssertEqual(try Realm().objects(LocalArticle.self).count, 1)
    }
}
