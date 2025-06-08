import SwiftUI
import UniformTypeIdentifiers

extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}

struct ContentView: View {
    @AppStorage("pbHash") var pbHash: String = ""
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    @State var showTendiesImporter: Bool = false
    var selectedTendies: Binding<[URL]>
    @State var showErrorAlert = false
    @State var lastError: String?
    @State var hideResetHelp: Bool = true

    var body: some View {
        NavigationStack {
            List {
                Section {} header: {
                    let version = Bundle.main.releaseVersionNumber ?? "Unknown"
                    let build = Int(buildNumber) != 0 ? "Beta \(buildNumber)" : NSLocalizedString("release", comment: "")
                    Label("Version \(version) (\(build))", systemImage: "info.circle.fill")
                }

                Section {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        showTendiesImporter.toggle()
                    }) {
                        Text("select_wallpapers")
                    }
                    .buttonStyle(TintedButton(color: .green, fullwidth: true))
                }
                .listRowInsets(EdgeInsets())
                .padding(7)

                if !selectedTendies.wrappedValue.isEmpty {
                    Section {
                        ForEach(selectedTendies.wrappedValue, id: \.self) { tendie in
                            Text(tendie.deletingPathExtension().lastPathComponent)
                        }
                        .onDelete(perform: delete)
                    } header: {
                        Label("selected_wallpapers", systemImage: "document")
                    }
                }

                Section {
                    if pbHash == "" {
                        Text("please_set_hash")
                    } else {
                        VStack {
                            if !selectedTendies.wrappedValue.isEmpty {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    UIApplication.shared.alert(title: "applying_wallpapers", body: "please_wait", animated: false, withButton: false)

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        do {
                                            try PosterBoardManager.applyTendies(selectedTendies.wrappedValue, appHash: pbHash)
                                            selectedTendies.wrappedValue.removeAll()
                                            SymHandler.cleanup()
                                            try? FileManager.default.removeItem(at: PosterBoardManager.getTendiesStoreURL())
                                            Haptic.shared.notify(.success)
                                            UIApplication.shared.dismissAlert(animated: false)

                                            UIApplication.shared.confirmAlert(title: "applied_successfully", body: "posterboard_open_notice", onOK: {
                                                if !PosterBoardManager.openPosterBoard() {
                                                    UIApplication.shared.confirmAlert(title: "fallback_to_shortcut", body: "fallback_notice", onOK: {
                                                        PosterBoardManager.runShortcut(named: "PosterBoard")
                                                    }, noCancel: true)
                                                }
                                            }, noCancel: true)
                                        } catch {
                                            Haptic.shared.notify(.error)
                                            SymHandler.cleanup()
                                            UIApplication.shared.dismissAlert(animated: false)
                                            UIApplication.shared.alert(body: error.localizedDescription)
                                        }
                                    }
                                }) {
                                    Text("apply")
                                }
                                .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                            }

                            Button(action: {
                                hideResetHelp = false
                            }) {
                                Text("reset_collection")
                            }
                            .buttonStyle(TintedButton(color: .red, fullwidth: true))
                        }
                        .listRowInsets(EdgeInsets())
                        .padding(7)
                    }
                } header: {
                    Label("section_actions", systemImage: "hammer")
                }
            }
            .navigationTitle("Pocket Poster")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let wpURL = URL(string: PosterBoardManager.WallpapersURL) {
                        Link(destination: wpURL) {
                            Image(systemName: "safari")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: {
                        SettingsView()
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
            }
        }
        .fileImporter(
            isPresented: $showTendiesImporter,
            allowedContentTypes: [UTType(filenameExtension: "tendies", conformingTo: .data)!],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let url):
                if selectedTendies.wrappedValue.count + url.count > PosterBoardManager.MaxTendies {
                    UIApplication.shared.alert(title: "max_reached", body: String(format: NSLocalizedString("max_reached_body", comment: ""), PosterBoardManager.MaxTendies))
                } else {
                    selectedTendies.wrappedValue.append(contentsOf: url)
                }
            case .failure(let error):
                lastError = error.localizedDescription
                showErrorAlert.toggle()
            }
        }
        .alert("error", isPresented: $showErrorAlert) {
            Button("ok") {}
        } message: {
            Text(lastError ?? NSLocalizedString("unknown_error", comment: ""))
        }
        .overlay {
            OnBoardingView(cards: resetCollectionsInfo, isFinished: $hideResetHelp)
                .opacity(hideResetHelp ? 0.0 : 1.0)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.5), value: hideResetHelp)
        }
    }

    func delete(at offsets: IndexSet) {
        selectedTendies.wrappedValue.remove(atOffsets: offsets)
    }

    init(selectedTendies: Binding<[URL]>) {
        self.selectedTendies = selectedTendies
        let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:)))!
        let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:)))!
        method_exchangeImplementations(origMethod, fixMethod)
    }
}
