//
//  BannerViewController.swift
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

protocol BannerViewControllerDelegate: AnyObject {
    func loadRemoteContent()
    func loadEmbeddedImage()
    func handleMessageExpired()
    func hideBannerController()
    func showBannerController()
}

class BannerViewController: UIViewController {

    let viewModel: BannerViewModel
    weak var delegate: BannerViewControllerDelegate?

    private(set) lazy var customView = UIView()
    private(set) var containerView: UIStackView?
    private(set) lazy var remoteContentBanner = RemoteContentBannerView()
    private(set) lazy var embeddedImageBanner = EmbeddedImageBannerView()
    private(set) lazy var errorBanner = ErrorBannerView()
    private(set) lazy var expirationBanner = ExpirationBannerView()
    private(set) lazy var remoteAndEmbeddedContentBanner = RemoteAndEmbeddedBannerView()
    private(set) lazy var unsubscribeBanner = UnsubscribeBanner()
    private(set) lazy var spamBanner = SpamBannerView()
    private lazy var autoReplyBanner = AutoReplyBanner()
    private(set) lazy var receiptBanner = ReceiptBannerView()

    private(set) var displayedBanners: [BannerType: UIView] = [:] {
        didSet {
            displayedBanners.isEmpty ? delegate?.hideBannerController() : delegate?.showBannerController()
        }
    }

    init(viewModel: BannerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.viewModel.updateExpirationTime = { [weak self] offset in
            self?.expirationBanner.updateTitleWith(offset: offset)
        }

        self.viewModel.messageExpired = { [weak self] in
            self?.delegate?.handleMessageExpired()
        }
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContainerView()

        let bannersBeforeUpdate = displayedBanners

        if viewModel.expirationTime != .distantFuture {
            self.showExpirationBanner()
        }
        handleUnsubscribeBanner()
        handleSpamBanner()
        handleAutoReplyBanner()
        setUpMessageObservation()
        handleReceiptBanner()

        guard bannersBeforeUpdate.sortedBanners != displayedBanners.sortedBanners else { return }
        viewModel.recalculateCellHeight?(false)
    }

    func hideBanner(type: BannerType) {
        if let view = displayedBanners[type] {
            view.removeFromSuperview()
            displayedBanners.removeValue(forKey: type)
        }
        viewModel.recalculateCellHeight?(false)
    }

    func showContentBanner(remoteContent: Bool, embeddedImage: Bool) {
        let bannersBeforeUpdate = displayedBanners
        if displayedBanners[.remoteContent]?.subviews.first as? RemoteAndEmbeddedBannerView != nil {
            return
        } else if remoteContent && embeddedImage {
            showRemoteAndEmbeddedContentBanner()
        } else if remoteContent {
            showRemoteContentBanner()
        } else if embeddedImage {
            showEmbeddedImageBanner()
        }

        guard bannersBeforeUpdate.sortedBanners != displayedBanners.sortedBanners else { return }
        viewModel.recalculateCellHeight?(false)
    }

    func showErrorBanner(error: NSError) {
        errorBanner.setErrorTitle(error.localizedDescription)
        addBannerView(type: .error, shouldAddContainer: true, bannerView: errorBanner)
    }

    private func handleSpamBanner() {
        let isSpamBannerPresenter = displayedBanners.contains(where: { $0.key == .spam })
        let isSpam = viewModel.message.spam != nil
        if isSpamBannerPresenter && isSpam == false {
            hideBanner(type: .spam)
        } else if let spamType = viewModel.spamType, isSpamBannerPresenter == false {
            showSpamBanner(spamType: spamType)
        }
    }

    private func showSpamBanner(spamType: SpamType) {
        spamBanner.infoTextView.attributedText = spamType.text
        spamBanner.iconImageView.image = spamType.icon
        spamBanner.button.setAttributedTitle(spamType.buttonTitle, for: .normal)
        spamBanner.button.isHidden = spamType.buttonTitle == nil
        spamBanner.button.addTarget(self, action: #selector(markAsLegitimate), for: .touchUpInside)
        addBannerView(type: .spam, shouldAddContainer: true, bannerView: spamBanner)
    }

    private func setUpMessageObservation() {
        viewModel.reloadBanners = { [weak self] in
            self?.handleUnsubscribeBanner()
            self?.handleSpamBanner()
            self?.handleAutoReplyBanner()
        }
    }

    private func handleReceiptBanner() {
        let isPresented = displayedBanners.contains(where: { $0.key == .sendReceipt })
        guard !isPresented, viewModel.shouldShowReceiptBanner else { return }
        showReceiptBanner()
    }

    private func handleUnsubscribeBanner() {
        let isUnsubscribeBannerDisplayed = displayedBanners.contains(where: { $0.key == .unsubscribe })
        if isUnsubscribeBannerDisplayed && !viewModel.canUnsubscribe {
            hideBanner(type: .unsubscribe)
        }
        guard viewModel.canUnsubscribe && !isUnsubscribeBannerDisplayed else { return }
        showUnsubscribeBanner()
    }

    private func handleAutoReplyBanner() {
        let isAutoReplyBannerDisplayed = displayedBanners.contains(where: { $0.key == .autoReply })

        if !isAutoReplyBannerDisplayed && viewModel.isAutoReply {
            showAutoReplyBanner()
        }
    }

    private func showAutoReplyBanner() {
        addBannerView(type: .autoReply, shouldAddContainer: true, bannerView: autoReplyBanner)
    }

    private func setupContainerView() {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        customView.addSubview(stackView)

        [
            stackView.topAnchor.constraint(equalTo: customView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: customView.trailingAnchor)
        ].activate()
        containerView = stackView
    }

    private func showRemoteContentBanner() {
        remoteContentBanner.loadContentButton.addTarget(self,
                                                        action: #selector(self.loadRemoteContent),
                                                        for: .touchUpInside)
        addBannerView(type: .remoteContent, shouldAddContainer: true, bannerView: remoteContentBanner)
    }

    private func showEmbeddedImageBanner() {
        embeddedImageBanner.loadContentButton.addTarget(self,
                                                        action: #selector(self.loadEmbeddedImages),
                                                        for: .touchUpInside)
        addBannerView(type: .remoteContent, shouldAddContainer: true, bannerView: embeddedImageBanner)
    }

    private func showRemoteAndEmbeddedContentBanner() {
        remoteAndEmbeddedContentBanner.loadImagesButton.addTarget(self,
                                                                  action: #selector(self.loadEmbeddedImageAndCheck),
                                                                  for: .touchUpInside)
        remoteAndEmbeddedContentBanner.loadContentButton.addTarget(self,
                                                                   action: #selector(self.loadRemoteContentAndCheck),
                                                                   for: .touchUpInside)
        addBannerView(type: .remoteContent, shouldAddContainer: true, bannerView: remoteAndEmbeddedContentBanner)
    }

    private func showExpirationBanner() {
        let banner = self.expirationBanner
        banner.updateTitleWith(offset: viewModel.getExpirationOffset())

        addBannerView(type: .expiration, shouldAddContainer: false, bannerView: banner)
    }

    private func showUnsubscribeBanner() {
        let banner = unsubscribeBanner
        banner.unsubscribeButton.addTarget(viewModel, action: #selector(viewModel.unsubscribe), for: .touchUpInside)
        addBannerView(type: .unsubscribe, shouldAddContainer: true, bannerView: banner)
    }

    private func showReceiptBanner() {
        let banner = receiptBanner
        if viewModel.hasSentReceipt {
            banner.hasSentReceipt()
        } else {
            banner.sendButton.addTarget(self, action: #selector(self.sendReceipt), for: .touchUpInside)
        }
        addBannerView(type: .sendReceipt, shouldAddContainer: true, bannerView: banner)
    }

    private func addBannerView(type: BannerType, shouldAddContainer: Bool, bannerView: UIView) {
        guard let containerView = self.containerView else { return }
        var viewToAdd = bannerView
        if shouldAddContainer {
            let bannerContainerView = UIView()
            bannerContainerView.addSubview(bannerView)
            [
                bannerView.topAnchor.constraint(equalTo: bannerContainerView.topAnchor, constant: 12),
                bannerView.leadingAnchor.constraint(equalTo: bannerContainerView.leadingAnchor, constant: 12),
                bannerView.trailingAnchor.constraint(equalTo: bannerContainerView.trailingAnchor, constant: -12),
                bannerView.bottomAnchor.constraint(equalTo: bannerContainerView.bottomAnchor, constant: -12)
            ].activate()
            viewToAdd = bannerContainerView
        }
        let indexToInsert = findIndexToInsert(type)

        containerView.insertArrangedSubview(viewToAdd, at: indexToInsert)
        displayedBanners[type] = viewToAdd
    }

    private func findIndexToInsert(_ typeToInsert: BannerType) -> Int {
        guard let containerView = self.containerView else { return 0 }

        var indexToInsert = 0
        for (index, view) in containerView.arrangedSubviews.enumerated() {
            if let type = displayedBanners.first(where: { _, value -> Bool in
                return value == view
            }) {
                if type.key.order > typeToInsert.order {
                    indexToInsert = index
                }
            }
        }
        return indexToInsert
    }

    @objc
    private func loadRemoteContentAndCheck() {
        delegate?.loadRemoteContent()
        remoteAndEmbeddedContentBanner.loadContentButton.isEnabled = false
        if remoteAndEmbeddedContentBanner.areBothButtonDisabled {
            self.hideBanner(type: .remoteContent)
        }
        viewModel.resetLoadedHeight?()
    }

    @objc
    private func loadEmbeddedImageAndCheck() {
        delegate?.loadEmbeddedImage()
        remoteAndEmbeddedContentBanner.loadImagesButton.isEnabled = false
        if remoteAndEmbeddedContentBanner.areBothButtonDisabled {
            self.hideBanner(type: .remoteContent)
        }
        viewModel.resetLoadedHeight?()
    }

    @objc
    private func loadRemoteContent() {
        delegate?.loadRemoteContent()
        self.hideBanner(type: .remoteContent)
        viewModel.resetLoadedHeight?()
    }

    @objc
    private func loadEmbeddedImages() {
        delegate?.loadEmbeddedImage()
        self.hideBanner(type: .remoteContent)
        viewModel.resetLoadedHeight?()
    }

    @objc
    private func markAsLegitimate() {
        viewModel.markAsLegitimate()
        hideBanner(type: .spam)
    }

    @objc
    private func sendReceipt() {
        guard self.isOnline else {
            LocalString._no_internet_connection.alertToast()
            return
        }
        viewModel.sendReceipt()
        self.receiptBanner.hasSentReceipt()
    }
}

private extension Dictionary where Key == BannerType, Value == UIView {

    var sortedBanners: [Key] {
        keys.sorted(by: { $0.order > $1.order })
    }

}
