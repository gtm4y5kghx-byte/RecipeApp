import XCTest

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }

    func clearTextView() {
        self.tap()
        self.press(forDuration: 1.0)

        let selectAllMenuItem = XCUIApplication().menuItems["Select All"]
        if selectAllMenuItem.waitForExistence(timeout: 1) {
            selectAllMenuItem.tap()
            self.typeText("")
        }
    }
}
