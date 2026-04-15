//
//  whiskTests.swift
//  whiskTests
//
//  Created by Brianna Shen on 2024-08-11.
//

import XCTest
@testable import whisk

final class whiskTests: XCTestCase {
    private let chatEngine = WhiskChatEngine()

    func testEmergencyMessagePrioritizesCallingForHelp() {
        let response = chatEngine.response(for: "I think I'm in danger and need emergency help")

        XCTAssertTrue(response.contains("911"))
        XCTAssertTrue(response.localizedCaseInsensitiveContains("immediate danger"))
    }

    func testScaredMessageGetsReassurance() {
        let response = chatEngine.response(for: "I'm scared walking home alone")

        XCTAssertTrue(response.localizedCaseInsensitiveContains("okay"))
        XCTAssertTrue(response.localizedCaseInsensitiveContains("public area"))
    }

    func testQuestionAboutCheckInPointsToTrustedContactFeature() {
        let response = chatEngine.response(for: "How do I text a friend to check in?")

        XCTAssertTrue(response.localizedCaseInsensitiveContains("contact button"))
        XCTAssertTrue(response.localizedCaseInsensitiveContains("someone you trust"))
    }
}
