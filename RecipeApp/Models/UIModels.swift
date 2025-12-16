import Foundation

struct MenuOption: Identifiable {
    let id: String
    let title: String
    let icon: String
    let count: Int?

    init(id: String, title: String, icon: String, count: Int? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.count = count
    }
}
