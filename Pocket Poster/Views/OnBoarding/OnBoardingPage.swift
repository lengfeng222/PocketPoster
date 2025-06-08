import SwiftUICore

struct OnBoardingPage: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var image: String
    var link: URL?
    var linkName: String?
    var gradientColors: [Color]

    init(title: String,
         description: String,
         image: String,
         link: URL? = nil,
         linkName: String? = nil,
         gradientColors: [Color] = [Color("WelcomeLight"), Color("WelcomeDark")]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.image = image
        self.link = link
        self.linkName = linkName
        self.gradientColors = gradientColors
    }
}

let onBoardingCards: [OnBoardingPage] = [
    .init(
        title: NSLocalizedString("onboard_welcome_title", comment: ""),
        description: NSLocalizedString("onboard_welcome_desc", comment: ""),
        image: "Logo"
    ),
    .init(
        title: NSLocalizedString("onboard_shortcut_title", comment: ""),
        description: NSLocalizedString("onboard_shortcut_desc", comment: ""),
        image: "Shortcuts",
        link: URL(string: PosterBoardManager.ShortcutURL),
        linkName: NSLocalizedString("onboard_shortcut_button", comment: "")
    ),
    .init(
        title: NSLocalizedString("onboard_nugget_title", comment: ""),
        description: NSLocalizedString("onboard_nugget_desc", comment: ""),
        image: "Nugget",
        link: URL(string: "https://github.com/leminlimez/Nugget/releases/latest"),
        linkName: NSLocalizedString("onboard_nugget_button", comment: "")
    ),
    .init(
        title: NSLocalizedString("onboard_enjoy_title", comment: ""),
        description: NSLocalizedString("onboard_enjoy_desc", comment: ""),
        image: "Cowabunga",
        link: URL(string: PosterBoardManager.WallpapersURL),
        linkName: NSLocalizedString("onboard_enjoy_button", comment: "")
    )
]

let resetCollectionsInfo: [OnBoardingPage] = [
    .init(
        title: NSLocalizedString("reset_title_1", comment: ""),
        description: NSLocalizedString("reset_desc_1", comment: ""),
        image: "CustomCollection"
    ),
    .init(
        title: NSLocalizedString("reset_title_2", comment: ""),
        description: NSLocalizedString("reset_desc_2", comment: ""),
        image: "Language"
    ),
    .init(
        title: NSLocalizedString("reset_title_3", comment: ""),
        description: NSLocalizedString("reset_desc_3", comment: ""),
        image: "SetPrimary"
    ),
    .init(
        title: NSLocalizedString("reset_title_4", comment: ""),
        description: NSLocalizedString("reset_desc_4", comment: ""),
        image: "OriginalCollection"
    )
]
