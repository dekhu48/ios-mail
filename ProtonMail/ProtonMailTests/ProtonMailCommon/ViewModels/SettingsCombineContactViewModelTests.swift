//
//  SettingsCombineContactViewModelTests.swift
//  Proton MailTests
//
//
//  Copyright (c) 2021 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
@testable import ProtonMail

class SettingsCombineContactViewModelTests: XCTestCase {

    var sut: SettingsCombineContactViewModel!
    var combimeContactSettingStub: CombimeContactSettingStub!

    override func setUp() {
        super.setUp()

        combimeContactSettingStub = CombimeContactSettingStub()
        sut = SettingsCombineContactViewModel(combineContactCache: self.combimeContactSettingStub)
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        combimeContactSettingStub = nil
    }

    func testSections() {
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first, .combineContact)
    }

    func testSetContactCombined() {
        combimeContactSettingStub.isCombineContactOn = false

        sut.isContactCombined = true

        XCTAssertTrue(combimeContactSettingStub.isCombineContactOn)
        XCTAssertTrue(sut.isContactCombined)
    }

    func testCombineContactsSettingsSection() {
        let combineContact = SettingsCombineContactViewModel.SettingSection.combineContact
        XCTAssertEqual(combineContact.foot, LocalString._settings_footer_of_combined_contact)
        XCTAssertEqual(combineContact.title, LocalString._settings_title_of_combined_contact)
    }

}
