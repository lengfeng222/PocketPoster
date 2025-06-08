import SwiftUI

struct SettingsView: View {
    @AppStorage("pbHash") var pbHash: String = ""

    @State var checkingForHash: Bool = false
    @State var hashCheckTask: Task<Void, any Error>? = nil

    @State var showErrorAlert = false
    @State var errorAlertTitle: String?
    @State var errorAlertDescr: String?

    var body: some View {
        List {
            // MARK: - App Hash Input & Detection
            Section {
                VStack {
                    TextField("input_app_hash", text: $pbHash)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.body, design: .monospaced))

                    HStack {
                        Spacer()
                        Button(action: {
                            UIApplication.shared.confirmAlert(
                                title: NSLocalizedString("waiting_app_hash", comment: ""),
                                body: NSLocalizedString("nugget_instruction", comment: ""),
                                confirmTitle: NSLocalizedString("cancel", comment: ""),
                                onOK: {
                                    cancelWaitForHash()
                                },
                                noCancel: true
                            )
                            startWaitForHash()
                        }) {
                            Text("auto_detect")
                        }
                        .foregroundStyle(.green)
                        .onChange(of: checkingForHash) {
                            if !checkingForHash {
                                UIApplication.shared.dismissAlert(animated: true)
                            }
                        }
                    }
                }
            } header: {
                Label("section_app_hash", systemImage: "lock.app.dashed")
            }

            // MARK: - App Actions
            Section {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    UserDefaults.standard.set(false, forKey: "finishedTutorial")
                }) {
                    Text("replay_tutorial")
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    do {
                        try PosterBoardManager.clearCache()
                        Haptic.shared.notify(.success)
                        errorAlertTitle = NSLocalizedString("cache_cleared", comment: "")
                        errorAlertDescr = ""
                        showErrorAlert = true
                    } catch {
                        Haptic.shared.notify(.error)
                        errorAlertTitle = NSLocalizedString("error", comment: "")
                        errorAlertDescr = error.localizedDescription
                        showErrorAlert = true
                    }
                }) {
                    Text("clear_cache")
                }
                .foregroundStyle(.red)
            } header: {
                Label("section_actions", systemImage: "gear")
            }

            // MARK: - Tool Links
            Section {
                if let scURL = URL(string: PosterBoardManager.ShortcutURL) {
                    Link(destination: scURL) {
                        Label("download_shortcut", systemImage: "arrow.down.circle")
                    }
                }
                if let fbURL = URL(string: "shortcuts://run-shortcut?name=PosterBoard&input=text&text=troubleshoot") {
                    Link(destination: fbURL) {
                        Label("create_alternative", systemImage: "appclip")
                    }
                }
                if let nURL = URL(string: "https://github.com/leminlimez/Nugget") {
                    Link(destination: nURL) {
                        Label("open_nugget", image: "github.fill")
                    }
                }
            } header: {
                Label("section_links", systemImage: "link")
            }

            // MARK: - Community & Support
            Section {
                Link(destination: URL(string: "https://github.com/leminlimez/Pocket-Poster")!) {
                    Label("view_on_github", image: "github.fill")
                }
                Link(destination: URL(string: "https://discord.gg/MN8JgqSAqT")!) {
                    Label("join_discord", image: "discord.fill")
                }
                Link(destination: URL(string: "https://ko-fi.com/leminlimez")!) {
                    Label("support_on_kofi", image: "ko-fi")
                }
            } header: {
                Label("section_community", systemImage: "globe")
            }

            // MARK: - Credits
            Section {
                LinkCell(imageName: "leminlimez", url: "https://github.com/leminlimez", title: "LeminLimez", contribution: "Main Developer", circle: true)
                LinkCell(imageName: "serstars", url: "https://github.com/SerStars", title: "SerStars", contribution: "Web Design", circle: true)
                LinkCell(imageName: "Nathan", url: "https://github.com/verygenericname", title: "Nathan", contribution: "Vulnerability Research", circle: true)
                LinkCell(imageName: "duy", url: "https://github.com/khanhduytran0", title: "DuyKhanhTran", contribution: "Vulnerability Research", circle: true)
                LinkCell(imageName: "sky", url: "https://bsky.app/profile/did:plc:xykfeb7ieeo335g3aly6vev4", title: "dootskyre", contribution: "Shortcut Creator", circle: true)

                LinkCell(
                    imageName: "lengfeng",
                    url: "https://github.com/lengfeng222",
                    title: NSLocalizedString("author_lengfeng", comment: ""),
                    contribution: NSLocalizedString("contribution_translation", comment: ""),
                    circle: true
                )
            } header: {
                Label("section_credits", systemImage: "wrench.and.screwdriver")
            }
        }

        .alert(errorAlertTitle ?? NSLocalizedString("error", comment: ""), isPresented: $showErrorAlert) {
            Button(NSLocalizedString("alert_ok", comment: "")) {}
        } message: {
            Text(errorAlertDescr ?? NSLocalizedString("unknown_error", comment: ""))
        }
    }

    func startWaitForHash() {
        checkingForHash = true
        hashCheckTask = Task {
            let filePath = SymHandler.getLCDocumentsDirectory().appendingPathComponent("NuggetAppHash")
            while !FileManager.default.fileExists(atPath: filePath.path()) {
                try? await Task.sleep(nanoseconds: 500_000_000)
                try Task.checkCancellation()
            }

            do {
                let contents = try String(contentsOf: filePath)
                try? FileManager.default.removeItem(at: filePath)
                await MainActor.run {
                    pbHash = contents
                }
            } catch {
                print(error.localizedDescription)
            }

            await MainActor.run {
                checkingForHash = false
                hashCheckTask = nil
            }
        }
    }

    func cancelWaitForHash() {
        hashCheckTask?.cancel()
        hashCheckTask = nil
        checkingForHash = false
    }
}
