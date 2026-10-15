import SwiftUI

@main struct RinatAbuApp: App {
    @StateObject private var catalog = Catalog()
    var body: some Scene {
        WindowGroup { BoutiqueView().environmentObject(catalog).environment(\.layoutDirection, .rightToLeft).preferredColorScheme(.light) }
    }
}

enum Brand {
    static let wine = Color(red: 0.44, green: 0.16, blue: 0.26)
    static let paper = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let gold = Color(red: 0.67, green: 0.53, blue: 0.34)
}
struct BoutiqueView: View {
    @EnvironmentObject var catalog: Catalog
    @Environment(\.scenePhase) private var scene
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tab = 0
    @State private var search = ""
    @State private var sort = 0
    @State private var selected: Product?
    @State private var appeared = false
    private let refreshTimer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    var filtered: [Product] {
        let result = catalog.products.filter { p in
            (tab != 1 || p.sale) && (tab != 2 || catalog.favorites.contains(p.id)) && (search.isEmpty || (p.name + " " + p.category).localizedCaseInsensitiveContains(search))
        }
        if sort == 1 { return result.sorted { $0.price < $1.price } }
        if sort == 2 { return result.sorted { ($0.old - $0.price) > ($1.old - $1.price) } }
        return result
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Brand").resizable().scaledToFit().frame(width: 138, height: 48).accessibilityLabel("רינת אבו")
                Spacer()
                Menu {
                    Button("רענון מוצרים", systemImage: "arrow.clockwise") { Task { await catalog.refresh() } }
                    Link("שירות בוואטסאפ", destination: URL(string: "https://wa.me/972549808826")!)
                    Link("הקוד והגרסאות", destination: URL(string: "https://github.com/hendayan1990-svg/rinat-abu-app")!)
                } label: { Image(systemName: "line.3.horizontal").font(.title3).frame(width: 46, height: 46).background(.white, in: Circle()) }.accessibilityLabel("תפריט")
            }.padding(.horizontal, 22)
            HStack(spacing: 6) { if catalog.loading { ProgressView().scaleEffect(0.7) }; Text(catalog.message).font(.caption2).foregroundStyle(.secondary); Spacer() }.padding(.horizontal, 22).padding(.bottom, 8)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if tab < 3 { catalogue } else if tab == 3 { gifts } else { account }
                }.padding(18).opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
            }.refreshable { await catalog.refresh() }
            HStack(spacing: 3) {
                navItem("בית", icon: "house", index: 0)
                navItem("דילים", icon: "sparkles", index: 1)
                navItem("אהבתי", icon: "heart", index: 2)
                navItem("מתנות", icon: "gift", index: 3)
                navItem("שלי", icon: "person", index: 4)
            }.padding(8).background(.white, in: RoundedRectangle(cornerRadius: 26)).shadow(color: .black.opacity(0.06), radius: 16, y: 5).padding(.horizontal, 12).padding(.bottom, 6)
        }
        .background(Brand.paper).tint(Brand.wine)
        .sheet(item: $selected) { ProductDetail(product: $0).presentationDetents([.large]).presentationDragIndicator(.visible) }
        .task { withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) { appeared = true }; await catalog.refresh() }
        .onReceive(refreshTimer) { _ in if scene == .active { Task { await catalog.refresh() } } }
        .onChange(of: scene) { _, phase in if phase == .active && Date().timeIntervalSince(catalog.updated) > 300 { Task { await catalog.refresh() } } }
    }
    func navItem(_ title: String, icon: String, index: Int) -> some View {
        Button { withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { tab = index; search = "" } } label: {
            VStack(spacing: 5) { Image(systemName: icon).font(.system(size: 21, weight: tab == index ? .semibold : .regular)); Text(title).font(.caption2.weight(.semibold)) }.frame(maxWidth: .infinity).frame(height: 54).background(tab == index ? Brand.wine.opacity(0.09) : .clear, in: RoundedRectangle(cornerRadius: 19))
        }.buttonStyle(.plain).foregroundStyle(tab == index ? Brand.wine : .secondary).accessibilityAddTraits(tab == index ? .isSelected : [])
    }
    @ViewBuilder var catalogue: some View {
        if tab == 0 {
            VStack(alignment: .leading, spacing: 7) { Text("רגעים קטנים. מתנות גדולות.").font(.subheadline).foregroundStyle(.secondary); Text("משהו יפה מחכה לך").font(.title.bold()) }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 28).fill(Brand.wine.gradient)
                HStack { Spacer(); Image(systemName: "gift.fill").font(.system(size: 125, weight: .ultraLight)).foregroundStyle(Brand.gold.opacity(0.32)).rotationEffect(.degrees(-12)).padding(.leading, -18) }.environment(\.layoutDirection, .leftToRight)
                VStack(alignment: .leading, spacing: 14) { Text("THE ART OF GIVING").font(.caption2.weight(.semibold)).tracking(2).foregroundStyle(Brand.gold); Text("נבחר באהבה.\nניתן מכל הלב.").font(.largeTitle.bold()).foregroundStyle(.white); Text("מתנות עם משמעות").foregroundStyle(.white.opacity(0.8)); Button("לגלות את המבצעים") { withAnimation { tab = 1 } }.buttonStyle(.borderedProminent).tint(Brand.paper).foregroundStyle(Brand.wine) }.padding(24)
            }.frame(minHeight: 255)
        }
        Text(tab == 2 ? "האהובים שלך" : tab == 1 ? "דילים שעושים טוב בלב" : "נבחרו בשבילך").font(.title2.bold())
        HStack { Image(systemName: "magnifyingglass"); TextField("חיפוש פריט או קולקציה", text: $search).submitLabel(.search); if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("ניקוי חיפוש") } }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
        HStack { Text("\(filtered.count) פריטים").font(.caption).foregroundStyle(.secondary); Spacer(); Picker("מיון", selection: $sort) { Text("הקולקציה").tag(0); Text("מחיר עולה").tag(1); Text("הנחות").tag(2) }.pickerStyle(.menu) }
        if filtered.isEmpty { ContentUnavailableView(tab == 2 ? "כאן יופיעו הפריטים שאהבת" : "לא נמצאו מוצרים", systemImage: "heart", description: Text("אפשר לשנות חיפוש או לשמור פריט עם הלב")) }
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 16) {
            ForEach(filtered) { product in card(product) }
        }
    }
    func card(_ p: Product) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Button { selected = p } label: { ProductImage(url: p.image).frame(height: 180).padding(8) }.buttonStyle(.plain).accessibilityLabel(p.name)
                Button { withAnimation(reduceMotion ? nil : .spring(response: 0.3)) { catalog.toggle(p) } } label: {
                    Image(systemName: catalog.favorites.contains(p.id) ? "heart.fill" : "heart").font(.title3).symbolEffect(.bounce, options: .nonRepeating, value: reduceMotion ? false : catalog.favorites.contains(p.id)).frame(width: 44, height: 44).background(.white, in: Circle())
                }.padding(8).accessibilityLabel(catalog.favorites.contains(p.id) ? "הסרה מהמועדפים" : "שמירה למועדפים")
            }.background(Color.black.opacity(0.025))
            Button { selected = p } label: {
                VStack(alignment: .leading, spacing: 7) {
                    Text(p.sale ? "במחיר מיוחד" : "RINAT ABU").font(.caption2).foregroundStyle(Brand.gold)
                    Text(p.name).font(.subheadline.weight(.semibold)).lineLimit(2).frame(height: 42, alignment: .topLeading).foregroundStyle(.primary)
                    HStack { Text(p.money).font(.title3.bold()).foregroundStyle(Brand.wine); if p.old > p.price { Text(p.old.formatted(.currency(code: "ILS"))).font(.caption2).strikethrough().foregroundStyle(.secondary) } }
                    if !p.stock { Text("אזל מהמלאי").font(.caption).foregroundStyle(Brand.wine) }
                    if p.range { Text("המחיר לפי האפשרויות").font(.caption2).foregroundStyle(.secondary) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
            }.buttonStyle(.plain)
        }.background(.white, in: RoundedRectangle(cornerRadius: 22)).clipShape(RoundedRectangle(cornerRadius: 22))
    }
    var gifts: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("לתת אהבה.\nלהשאיר את הבחירה.").font(.largeTitle.bold())
            VStack(alignment: .leading, spacing: 22) { Text("RINAT ABU").tracking(3).font(.caption); Image(systemName: "gift").font(.system(size: 48, weight: .ultraLight)); Text("Gift Card").font(.largeTitle); Text("מתנה מלאה באפשרויות") }.padding(30).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(Brand.paper).background(Brand.wine.gradient, in: RoundedRectangle(cornerRadius: 26))
            Link("לגיפטכארד באתר רינת", destination: URL(string: "https://rinatabu.com/gift-card/")!).buttonStyle(.borderedProminent)
            Text("כרטיסים שהונפקו בניהול האפליקציה ממומשים מול רינת. הם עדיין אינם מחוברים לקופה באתר.").font(.subheadline).foregroundStyle(.secondary)
        }
    }
    var account: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("הבוטיק שלך").font(.largeTitle.bold())
            Text("RINAT ABU · iPhone 0.3.0").font(.headline)
            Link("שירות אישי בוואטסאפ", destination: URL(string: "https://wa.me/972549808826")!).buttonStyle(.borderedProminent)
            Link("מרכז ההטבות והניהול", destination: URL(string: "https://rinat-abu-boutique.soundheron64.chatgpt.site")!)
            Text("מרכז הניהול דורש כניסה לחשבון הבעלים. התראות Push וקופה בתוך האפליקציה עדיין אינן פעילות. עדכוני iPhone יופצו דרך TestFlight או App Store לאחר חיבור חשבון מפתח.").foregroundStyle(.secondary)
        }
    }
}
struct ProductImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image { image.resizable().scaledToFit() }
            else if phase.error != nil { Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity) }
            else { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity) }
        }
    }
}
struct ProductDetail: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ProductImage(url: product.image).frame(height: 300)
                    Text(product.name).font(.title.bold())
                    Text(product.money).font(.largeTitle.bold()).foregroundStyle(Brand.wine)
                    if product.range { Text("המחיר משתנה לפי האפשרויות") }
                    if !product.stock { Text("אזל מהמלאי באתר") }
                    Text("לבחירת צבעים, התאמה אישית ובדיקת זמינות, ממשיכים לעמוד המוצר באתר רינת.").foregroundStyle(.secondary)
                    Link("לבחירה ורכישה באתר רינת", destination: product.url).buttonStyle(.borderedProminent).controlSize(.large)
                    ShareLink(item: product.url) { Label("שיתוף המוצר", systemImage: "square.and.arrow.up") }
                }.padding(24)
            }.background(Brand.paper).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("סגירה") { dismiss() } } }
        }.tint(Brand.wine).environment(\.layoutDirection, .rightToLeft)
    }
}
