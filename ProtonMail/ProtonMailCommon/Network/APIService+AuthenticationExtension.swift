//
//  APIService+AuthenticationExtension.swift
//  ProtonMail
//
//
//  Copyright (c) 2019 Proton Technologies AG
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
import PromiseKit
import PMAuthentication

/// Auth extension
extension APIService {
    private func completeAuthFlow(credential: AuthCredential, password: String, passwordMode: Int, completion: @escaping AuthCompleteBlockNew) {
        var keySalt: String?
        var privateKey: String?
        
        func done(userInfo: UserInfo?) {
            credential.update(salt: keySalt, privateKey: privateKey)
            if passwordMode == 1 {
                guard let keysalt : Data = keySalt?.decodeBase64() else {
                    return completion(nil, .resCheck, nil, nil, userInfo, NSError.authInValidKeySalt())
                }
                let mpwd = PasswordUtils.getMailboxPassword(password, salt: keysalt)
                return completion(mpwd, .resCheck, credential, nil, userInfo, nil)
            } else {
                return completion(nil, .resCheck, credential, nil, userInfo, nil)
            }
        }
        
        let saltapi = GetKeysSalts(api: self)
        saltapi.authCredential = credential
        let userApi = GetUserInfoRequest(api: self)
        userApi.authCredential = credential
        firstly {
            when(fulfilled: saltapi.run(), userApi.run())
        }.done { (saltRes, userRes)  in
            guard  let salt = saltRes.keySalt,
                let privatekey = userRes.userInfo?.getPrivateKey(by: saltRes.keyID) else {
                    return completion(nil, .resCheck, nil, nil, userRes.userInfo, NSError.authInvalidGrant())
            }
            keySalt = salt
            privateKey = privatekey
            done(userInfo: userRes.userInfo)
        }.catch { err in
            let error = err as NSError
            if error.isInternetError() {
                return completion(nil, .resCheck, nil, nil, nil, NSError.internetError())
            } else {
                return completion(nil, .resCheck, nil, nil, nil, NSError.authInvalidGrant())
            }
        }
    }
    
    
    func confirm2FA(_ code: Int, password: String, context: TwoFactorContext, completion: @escaping AuthCompleteBlockNew) {
        self.authApi.confirm2FA(code, context: context) { result in
            switch result {
            case .failure(Authenticator.Errors.serverError(let error)): // error response returned by server
                return completion(nil, .resCheck, nil, nil, nil, error)
            
            case .failure(let error as NSError): // network or parsing error
                return completion(nil, .resCheck, nil, nil, nil, error.isInternetError() ? NSError.internetError() : NSError.authInvalidGrant())
                
            case .success(.newCredential(let credential, let passwordMode)): // success without 2FA
                let authCredential = AuthCredential(credential)
                self.completeAuthFlow(credential: authCredential, password: password, passwordMode: passwordMode.rawValue, completion: completion)
                
            case .success(.updatedCredential), .success(.ask2FA):
                assert(false, "Should never happen in this flow")
            }
        }
    }
    
    func authenticate(username: String, password: String, completion: @escaping AuthCompleteBlockNew) {
        self.authApi.authenticate(username: username, password: password) { result in
            switch result {
            case .failure(Authenticator.Errors.serverError(let error)): // error response returned by server
                return completion(nil, .resCheck, nil, nil, nil, error)
                
            case .failure(Authenticator.Errors.emptyServerSrpAuth):
                return completion(nil, .resCheck, nil, nil, nil, NSError.authUnableToGeneratePwd())
                
            case .failure(Authenticator.Errors.emptyClientSrpAuth):
                return completion(nil, .resCheck, nil, nil, nil, NSError.authUnableToGenerateSRP())
                
            case .failure(Authenticator.Errors.wrongServerProof):
                return completion(nil, .resCheck, nil, nil, nil, NSError.authServerSRPInValid())
                
            case .failure(Authenticator.Errors.emptyAuthResponse):
                return completion(nil, .resCheck, nil, nil, nil, NSError.authUnableToParseToken())
                
            case .failure(Authenticator.Errors.emptyAuthInfoResponse):
                return completion(nil, .resCheck, nil, nil, nil, NSError.authUnableToParseAuthInfo())
            
            case .failure(_): // network or parsing error
                return completion(nil, .resCheck, nil, nil, nil, NSError.internetError())
            
            case .success(.ask2FA(let context)): // success but need 2FA
                return completion(nil, .ask2FA, nil, context, nil, nil)
                
            case .success(.newCredential(let credential, let passwordMode)): // success without 2FA
                let authCredential = AuthCredential(credential)
                self.completeAuthFlow(credential: authCredential, password: password, passwordMode: passwordMode.rawValue, completion: completion)
            
            case .success(.updatedCredential):
                assert(false, "Should never happen in this flow")
            }
        }
    }
    
    func authRefresh(_ authCredential: AuthCredential, completion: AuthRefreshComplete?) {
        let oldCredential = PMAuthentication.Credential(authCredential)
        self.authApi.refreshCredential(oldCredential) { result in
            switch result {
            case .success(let status):
                guard case Authenticator.Status.updatedCredential(let newCredential) = status else {
                    assert(false, "Was trying to refresh credential but got something else instead")
                    PMLog.D("Was trying to refresh credential but got something else instead")
                    completion?(nil, nil, NSError.authInvalidGrant())
                }
                self.refreshTokenFailedCount = 0
                completion?(nil, newCredential, nil)
                
            case .failure(let error):
                var err: NSError = error as NSError
                if case Authenticator.Errors.serverError(let serverResponse) = error {
                    err = serverResponse
                }
                
                var needsRetry : Bool = false
                err.upload(toAnalytics : AuthErrorTitle)
                if err.code == NSURLErrorTimedOut ||
                    err.code == NSURLErrorNotConnectedToInternet ||
                    err.code == NSURLErrorCannotConnectToHost ||
                    err.code == APIErrorCode.API_offline ||
                    err.code == APIErrorCode.HTTP503 {
                    needsRetry = true
                } else {
                    self.refreshTokenFailedCount += 1
                }
                
                if self.refreshTokenFailedCount > 5 || !needsRetry {
                    PMLog.D("self.refreshTokenFailedCount == 5")
                    completion?(nil, nil, NSError.authInvalidGrant())
                } else {
                    completion?(nil, nil, NSError.internetError())
                }
            }
        }
    }
}

extension PMAuthentication.Credential {
    init(_ authCredential: AuthCredential) {
        self.init(UID: authCredential.sessionID,
                  accessToken: authCredential.accessToken,
                  refreshToken: authCredential.refreshToken,
                  expiration: authCredential.expiration,
                  scope: [])
    }
}
extension AuthCredential {
    convenience init(_ credential: PMAuthentication.Credential) {
        self.init(sessionID: credential.UID,
                  accessToken: credential.accessToken,
                  refreshToken: credential.refreshToken,
                  expiration: credential.expiration,
                  privateKey: nil,
                  passwordKeySalt: nil)
    }
}
