//
//  MimeType.swift
//  ProtonMail
//
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
enum MIMEType {
    case jpg
    case png
    case zip
    case pdf
    case txt
    case doc
    case xls
    case ppt
    case unknowFile

    init(rawValue: String) {
        let msWordMIME = ["application/doc",
                          "application/ms-doc",
                          "application/msword",
                          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
        let msExcelMIME = ["application/excel",
                           "application/vnd.ms-excel",
                           "application/x-excel",
                           "application/x-msexcel",
                           "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]
        let msPptMIME = ["application/mspowerpoint",
                         "application/powerpoint",
                         "application/vnd.ms-powerpoint",
                         "application/x-mspowerpoint",
                         "application/vnd.openxmlformats-officedocument.presentationml.presentation"]
        if rawValue == "image/jpeg" || rawValue == "image/jpg" {
            self = .jpg
        } else if rawValue == "image/png" {
            self = .png
        } else if rawValue == "application/zip" {
            self = .zip
        } else if rawValue == "application/pdf" {
            self = .pdf
        } else if rawValue == "text/plain" {
            self = .txt
        } else if msWordMIME.contains(rawValue) {
            self = .doc
        } else if msExcelMIME.contains(rawValue) {
            self = .xls
        } else if msPptMIME.contains(rawValue) {
            self = .ppt
        } else {
            self = .unknowFile
        }
    }

    // FIXME: use asset
    var icon: UIImage? {
        switch self {
        case .jpg:
            return UIImage(named: "mail_attachment-jpeg")
        case .png:
            return UIImage(named: "mail_attachment-png")
        case .zip:
            return UIImage(named: "mail_attachment-zip")
        case .pdf:
            return UIImage(named: "mail_attachment-pdf")
        case .txt:
            return UIImage(named: "mail_attachment-txt")
        case .doc:
            return UIImage(named: "mail_attachment-doc")
        case .xls:
            return UIImage(named: "mail_attachment-xls")
        case .ppt:
            return UIImage(named: "mail_attachment-ppt")
        default:
            return UIImage(named: "mail_attachment_unknow")
        }
    }
}
