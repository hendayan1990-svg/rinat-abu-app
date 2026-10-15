import Foundation
import SwiftUI

struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let url: URL
    let image: URL?
    let price: Double
    let old: Double
    let sale: Bool
    let stock: Bool
    let range: Bool
    let category: String
    var money: String { price.formatted(.currency(code: "ILS")) }
}
struct Snapshot: Codable { let products: [Product]; let updated: Date }
enum CatalogError: Error { case invalid }

@MainActor final class Catalog: ObservableObject {
    @Published var products: [Product] = []
    @Published var favorites: Set<Int> = Set(UserDefaults.standard.array(forKey: "favorites") as? [Int] ?? [])
    @Published var loading = false
    @Published var message = "קטלוג שמור"
    var updated = Date.distantPast
    private var cache: URL { FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("rinat-catalog.json") }
    init() {
        if let data = try? Data(contentsOf: cache), let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            products = snapshot.products; updated = snapshot.updated; message = "מציגים את העדכון האחרון שנשמר"
        } else if let url = Bundle.main.url(forResource: "products", withExtension: "json"), let data = try? Data(contentsOf: url), let list = try? JSONDecoder().decode([Product].self, from: data) { products = list }
    }
    func toggle(_ product: Product) {
        if favorites.contains(product.id) { favorites.remove(product.id) } else { favorites.insert(product.id) }
        UserDefaults.standard.set(Array(favorites), forKey: "favorites")
    }
    static func officialURL(_ string: String) throws -> URL {
        guard let url = URL(string: string), url.scheme == "https", url.host == "rinatabu.com" else { throw CatalogError.invalid }; return url
    }
    func refresh() async {
        guard !loading else { return }; loading = true
        defer { loading = false }
        do {
            var result: [Product] = []; var seen = Set<Int>(); var pages = 1; var total = -1; var page = 1
            repeat {
                try Task.checkCancellation()
                message = "מתעדכן מהבוטיק · \(page)/\(pages)"
                let url = URL(string: "https://rinatabu.com/wp-json/wc/store/v1/products?per_page=100&orderby=id&order=asc&page=\(page)")!
                var request = URLRequest(url: url); request.timeoutInterval = 25; request.cachePolicy = .reloadIgnoringLocalCacheData
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                      let count = Int(http.value(forHTTPHeaderField: "X-WP-Total") ?? ""),
                      let countPages = Int(http.value(forHTTPHeaderField: "X-WP-TotalPages") ?? ""),
                      data.count < 15_000_000, let items = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { throw CatalogError.invalid }
                if page == 1 { pages = countPages; total = count; guard pages > 0, pages <= 50, total > 0, total <= 5000 else { throw CatalogError.invalid } }
                guard count == total, countPages == pages else { throw CatalogError.invalid }
                for item in items {
                    guard let id = item["id"] as? Int, seen.insert(id).inserted,
                          let name = item["name"] as? String, let permalink = item["permalink"] as? String,
                          let prices = item["prices"] as? [String: Any], prices["currency_code"] as? String == "ILS",
                          let minor = prices["currency_minor_unit"] as? Int, (0...4).contains(minor),
                          let amount = Double(prices["price"] as? String ?? ""), amount.isFinite, amount >= 0 else { throw CatalogError.invalid }
                    let old = Double(prices["regular_price"] as? String ?? "") ?? amount
                    guard old.isFinite, old >= 0 else { throw CatalogError.invalid }
                    let photos = item["images"] as? [[String: Any]] ?? []
                    let photo = photos.first?["src"] as? String ?? photos.first?["thumbnail"] as? String
                    let image: URL? = try photo.map { try Self.officialURL($0) }
                    let cats = item["categories"] as? [[String: Any]] ?? []
                    result.append(Product(id: id, name: name.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&#8211;", with: "–").replacingOccurrences(of: "&quot;", with: "\""), url: try Self.officialURL(permalink), image: image, price: amount / pow(10, Double(minor)), old: old / pow(10, Double(minor)), sale: item["on_sale"] as? Bool ?? false, stock: item["is_in_stock"] as? Bool ?? false, range: prices["price_range"] is [String: Any], category: cats.compactMap { $0["name"] as? String }.joined(separator: " · ")))
                }
                page += 1
            } while page <= pages
            guard result.count == total else { throw CatalogError.invalid }
            let now = Date(); let snapshot = Snapshot(products: result, updated: now)
            try JSONEncoder().encode(snapshot).write(to: cache, options: .atomic)
            products = result; updated = now; message = "עודכן מהאתר · \(now.formatted(date: .omitted, time: .shortened))"
        } catch { message = "הרענון לא הצליח · מציגים קטלוג שמור" }
    }
}
