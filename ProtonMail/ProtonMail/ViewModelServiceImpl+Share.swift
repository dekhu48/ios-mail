//
//  ViewModelServiceImpl+Share.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 7/19/17.
//  Copyright © 2017 ProtonMail. All rights reserved.
//

import Foundation

//keep this unique
let sharedVMService : ViewModelService = ViewModelServiceShareImpl()
final class ViewModelServiceShareImpl: ViewModelService {
    
    private var latestComposerViewModel : ComposeViewModel?
//    private var activeViewController : ViewModelProtocol?
    
    override func newShareDraftViewModel(_ vmp : ViewModelProtocol, subject: String, content: String) {
        //        activeViewController = vmp
        latestComposerViewModel = ComposeViewModelImpl(subject: subject, body: content, action: .newDraft);
        vmp.setViewModel(latestComposerViewModel!)
    }
}
