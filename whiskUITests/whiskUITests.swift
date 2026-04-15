//
//  whiskUITests.swift
//  whiskUITests
//
//  Created by Brianna Shen on 2024-08-11.
//

import XCTest

final class whiskUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testChatScreenLoadsAndCanSendMessage() throws {
        let app = XCUIApplication()
        app.launch()

        let chatTextView = app.textViews["chatTextView"]
        let messageField = app.textFields["messageTextField"]
        let sendButton = app.buttons["sendButton"]

        XCTAssertTrue(chatTextView.waitForExistence(timeout: 5))
        XCTAssertTrue(messageField.exists)
        XCTAssertTrue(sendButton.exists)

        messageField.tap()
        messageField.typeText("I feel nervous walking home")
        sendButton.tap()

        let transcript = (chatTextView.value as? String) ?? ""
        XCTAssertTrue(transcript.contains("You: I feel nervous walking home"))
    }

    func testEmergencyButtonExists() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["emergencyButton"].waitForExistence(timeout: 5))
    }
}
