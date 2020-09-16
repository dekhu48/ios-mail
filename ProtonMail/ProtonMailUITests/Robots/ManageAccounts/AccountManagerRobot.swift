//
//  AccountManagerRobot.swift
//  ProtonMailUITests
//
//  Created by denys zelenchuk on 25.08.20.
//  Copyright © 2020 ProtonMail. All rights reserved.
//

import XCTest

fileprivate let addAccountCellIdentifier = "addAccountLabel"
fileprivate let removeAllButtonIdentifier = "UINavigationItem.rightBarButtonItem"
fileprivate let swipeUserCellTrailingButtonIdentifier = "trailing0"

fileprivate let removeAllLabel = "Remove All"

private func userAccountCellIdentifier(_ email: String) -> String { return "AccountManagerUserCell.\(email)" }
private func loggedOutUserAccountCellIdentifier(_ email: String) -> String { return "AccountManagerUserCell.\(email)_(logged_out)" }

/**
 Represents Account Manager view.
*/
class AccountManagerRobot {
    
    var verify: Verify! = nil
    
    init() {
        verify = Verify()
    }
    
    func addAccount() -> ConnectAccountRobot {
        Element.wait.forStaticTextFieldWithIdentifier(addAccountCellIdentifier).tap()
        return ConnectAccountRobot()
    }

    func logoutAccount(_ email: String) -> AccountManagerRobot {
        return swipeLeft(email)
            .logout()
            .confirmLogout()
    }
    
    func deleteAccount(_ email: String) -> AccountManagerRobot {
        return swipeLeftToDelete(email)
            .remove()
            .confirmRemove()
    }
    
    func removeAllAccounts() -> LoginRobot {
        return removeAll()
            .confirmRemoveAll()
    }
    
    private func removeAll() -> RemoveAllAlertRobot {
        Element.wait.forButtonWithIdentifier(removeAllLabel).tap()
        return RemoveAllAlertRobot()
    }
    
    private func swipeLeft(_ email: String) -> AccountManagerRobot {
        Element.wait.forCellWithIdentifier(userAccountCellIdentifier(email)).swipeLeft()
        return AccountManagerRobot()
    }
    
    private func swipeLeftToDelete(_ email: String) -> AccountManagerRobot {
        Element.wait.forCellWithIdentifier(loggedOutUserAccountCellIdentifier(email)).swipeLeft()
        return AccountManagerRobot()
    }

    private func logout() -> LogoutAccountAlertRobot {
        Element.wait.forButtonWithIdentifier(swipeUserCellTrailingButtonIdentifier).tap()
        return LogoutAccountAlertRobot()
    }

    private func remove() -> RemoveAccountAlertRobot {
        Element.button.tapByIdentifier(swipeUserCellTrailingButtonIdentifier)
        return RemoveAccountAlertRobot()
    }

    private func confirmLastAccountLogout() -> LoginRobot {
     
        return LoginRobot()
    }
    
    /**
     RemoveAllAlertRobot class contains actions for Remove all accounts alert.
     */
    class RemoveAllAlertRobot {
        
        func confirmRemoveAll() -> LoginRobot {
            app.alerts.buttons.element(boundBy: 1).tap()
            return LoginRobot()
        }
    }
    
    /**
     RemoveAllAlertRobot class contains actions for Remove all accounts alert.
     */
    class RemoveAccountAlertRobot {
        
        func confirmRemove() -> AccountManagerRobot {
            app.alerts.buttons.element(boundBy: 1).tap()
            return AccountManagerRobot()
        }
    }
    
    /**
     RemoveAllAlertRobot class contains actions for Remove all accounts alert.
     */
    class LogoutAccountAlertRobot {
        
        func confirmLogout() -> AccountManagerRobot {
            app.alerts.buttons.element(boundBy: 1).tap()
            return AccountManagerRobot()
        }
        
        func confirmLogoutWithMultipleAccounts() -> AccountManagerRobot {
            app.alerts.buttons.element(boundBy: 1).tap()
            return AccountManagerRobot()
        }
        
        func confirmLastAccountLogout() -> LoginRobot {
            
            return LoginRobot()
        }
    }

    /**
    * Contains all the validations that can be performed by [AccountManagerRobot].
    */
    class Verify {

        func manageAccountsOpened() {
        }

        func switchedToAccount(_ username: String) {
            
        }
        
        func accountLoggedOut(_ email: String) {
            Element.wait.forCellWithIdentifier(loggedOutUserAccountCellIdentifier(email), file: #file, line: #line)
        }
        
        func accountRemoved(_ email: String) {
            Element.wait.forCellWithIdentifierToDisappear(loggedOutUserAccountCellIdentifier(email), file: #file, line: #line)
        }
    }
}
