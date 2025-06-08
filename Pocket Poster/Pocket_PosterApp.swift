import SwiftUI

@main
struct Pocket_PosterApp: App {
    @AppStorage("finishedTutorial") var finishedTutorial: Bool = false
    @AppStorage("pbHash") var pbHash: String = ""

    @State var selectedTendies: [URL] = []
    @State var downloadURL: String? = nil
    @State var showDownloadAlert = false

    var body: some Scene {
        WindowGroup {
            Group {
                if finishedTutorial {
                    ContentView(selectedTendies: $selectedTendies)
                } else {
                    OnBoardingView(cards: onBoardingCards, isFinished: $finishedTutorial)
                }
            }
            .transition(.opacity)
            .animation(.easeOut(duration: 0.5), value: finishedTutorial)

            .alert("alert_download_title", isPresented: $showDownloadAlert) {
                Button("ok") {
                    downloadWallpaper()
                }
                Button("cancel", role: .cancel) {}
            } message: {
                Text(String(format: NSLocalizedString("alert_download_body", comment: ""), DownloadManager.getWallpaperNameFromURL(string: downloadURL ?? "/Unknown")))
            }

            .onOpenURL(perform: { url in
                if url.absoluteString.starts(with: "pocketposter://download") {
                    if !url.absoluteString.hasSuffix(".tendies") {
                        UIApplication.shared.alert(body: NSLocalizedString("only_tendies_supported", comment: ""))
                    } else if selectedTendies.count >= PosterBoardManager.MaxTendies {
                        UIApplication.shared.alert(title: NSLocalizedString("max_reached", comment: ""), body: String(format: NSLocalizedString("max_reached_body", comment: ""), PosterBoardManager.MaxTendies))
                    } else {
                        downloadURL = url.absoluteString.replacingOccurrences(of: "pocketposter://download?url=", with: "")
                        showDownloadAlert = true
                    }
                } else if url.absoluteString.starts(with: "pocketposter://app-hash?uuid=") {
                    pbHash = url.absoluteString.replacingOccurrences(of: "pocketposter://app-hash?uuid=", with: "")
                } else if url.pathExtension == "tendies" {
                    if selectedTendies.count >= PosterBoardManager.MaxTendies {
                        UIApplication.shared.alert(title: NSLocalizedString("max_reached", comment: ""), body: String(format: NSLocalizedString("max_reached_body", comment: ""), PosterBoardManager.MaxTendies))
                    } else {
                        do {
                            let newURL = try DownloadManager.copyTendies(from: url)
                            selectedTendies.append(newURL)
                            Haptic.shared.notify(.success)
                            UIApplication.shared.alert(title: String(format: NSLocalizedString("import_success", comment: ""), url.lastPathComponent), body: "")
                        } catch {
                            Haptic.shared.notify(.error)
                            UIApplication.shared.alert(title: NSLocalizedString("import_failed", comment: ""), body: error.localizedDescription)
                        }
                    }
                }
            })
        }
    }

    func downloadWallpaper() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        UIApplication.shared.alert(
            title: NSLocalizedString("downloading", comment: "") + " \(DownloadManager.getWallpaperNameFromURL(string: downloadURL ?? "/Unknown"))...",
            body: NSLocalizedString("please_wait", comment: ""),
            animated: false,
            withButton: false
        )

        Task {
            do {
                let newURL = try await DownloadManager.downloadFromURL(string: downloadURL!)
                selectedTendies.append(newURL)
                Haptic.shared.notify(.success)
                UIApplication.shared.dismissAlert(animated: true)
            } catch {
                Haptic.shared.notify(.error)
                UIApplication.shared.dismissAlert(animated: true)
                UIApplication.shared.alert(title: NSLocalizedString("download_failed", comment: ""), body: error.localizedDescription)
            }
        }
    }
}
