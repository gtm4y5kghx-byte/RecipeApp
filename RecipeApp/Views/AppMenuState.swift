import SwiftUI

@Observable
class AppMenuState {
    var filterOptions: [MenuOption] = []
    var tagOptions: [MenuOption] = []

    var showingMenu = false
    var showingNewRecipe = false
    var showingSettings = false

    var onSelectOption: ((String) -> Void)?

    func selectOption(_ optionId: String) {
        showingMenu = false
        onSelectOption?(optionId)
    }

    func newRecipe() {
        showingMenu = false
        showingNewRecipe = true
    }

    func settings() {
        showingMenu = false
        showingSettings = true
    }
}
