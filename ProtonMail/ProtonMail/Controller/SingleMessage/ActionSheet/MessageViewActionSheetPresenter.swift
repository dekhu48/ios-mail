//
//  MessageViewActionSheetPresenter.swift
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

import PMUIFoundations

class MessageViewActionSheetPresenter {

    func present(
        on viewController: UIViewController,
        viewModel: MessageViewActionSheetViewModel,
        action: @escaping (MessageViewActionSheetAction) -> Void) {
        let cancelItem = PMActionSheetPlainItem(title: nil, icon: Asset.actionSheetClose.image) { _ in
            action(.dismiss)
        }

        let headerView = PMActionSheetHeaderView(
            title: viewModel.title,
            subtitle: nil,
            leftItem: cancelItem,
            rightItem: nil
        )

        let actions = viewModel.items.map { item in
            PMActionSheetPlainItem(title: item.title,
                                   icon: item.icon.withRenderingMode(.alwaysTemplate),
                                   textColor: UIColorManager.TextNorm,
                                   iconColor: UIColorManager.IconNorm) { (_) in
                action(item)
            }
        }

        let actionsGroup = PMActionSheetItemGroup(items: actions, style: .clickable)
        let actionSheet = PMActionSheet(headerView: headerView, itemGroups: [actionsGroup])
        actionSheet.presentAt(viewController, hasTopConstant: false, animated: true)
    }
}
