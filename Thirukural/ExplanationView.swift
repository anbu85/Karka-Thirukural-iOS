//
//  ExplanationView.swift
//  Thirukural
//
//  Created by Anbarasu S on 29/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI
import Combine
import CoreData
import WebKit

final class ExplanationViewModel: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    public var couplet: CDCouplet?
    public var chapter: CDChapter?

    private weak var managedObject: NSManagedObject?
    private var gitHubURL: URL!
    private var fileName: String!


    init(couplet: CDCouplet) {
        self.fileName = couplet.fileName
        self.gitHubURL = couplet.gitHubURL
        self.couplet = couplet
        self.managedObject = couplet

    }

    init(chapter: CDChapter) {
        self.fileName = chapter.fileName
        self.gitHubURL = chapter.gitHubURL
        self.chapter = chapter
        self.managedObject = chapter
    }

    init(section: CDSection) {
        self.fileName = section.fileName
        self.gitHubURL = section.gitHubURL
        self.managedObject = section
    }

    init(subSection: CDSubSection) {
        self.fileName = subSection.fileName
        self.gitHubURL = subSection.gitHubURL
        self.managedObject = subSection
    }

    private var fileURL: URL {
            let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = cacheDir.appendingPathComponent(fileName)
            prettyPrint(fileUrl)
            return fileUrl
    }

    private(set) var sections: [ExplanationSection] = []
    private(set) var youtubeVideos: [YouTubeVideo] = []

    var attributedText = "" {
        didSet {
            let document = ExplanationDocument(markdown: attributedText)
            sections = document.sections
            youtubeVideos = document.youtubeVideos

            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    func exportArathupalForAyya(unparsedString: String) -> () {
        guard let slicedString = unparsedString.slice(from: "உ", to: "## உயர் வள்ளுவ வகுப்பு காணொளி") else {
            return
        }

        let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = cacheDir.appendingPathComponent("export.md")
        print(fileUrl)

        if FileManager.default.fileExists(atPath: fileUrl.path) == false {
            do {
                try slicedString.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            }
        } else {
            if let handle = FileHandle(forWritingAtPath: fileUrl.path) {
                handle.seekToEndOfFile()
                if let data = slicedString.data(using: .utf8) {
                    handle.write(data)
                }
            }
        }

    }

    func fetchFileFromInternet(forceRefresh: Bool = true) {
        revalidateCachedFile(forceRefresh: forceRefresh)
    }

    func fetchFile() {
        loadCachedFile()
        revalidateCachedFile(forceRefresh: false)
    }

    private func loadCachedFile() {
        guard let string = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }

        attributedText = string
    }

    private func revalidateCachedFile(forceRefresh: Bool) {
        var request = URLRequest(
            url: gitHubURL,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )

        if !forceRefresh {
            let validators = cachedValidators()
            if let eTag = validators.eTag {
                request.setValue(eTag, forHTTPHeaderField: "If-None-Match")
            } else if let lastModified = validators.lastModified {
                request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.displayErrorIfCacheIsEmpty(error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                self.displayErrorIfCacheIsEmpty("GitHub returned an invalid response.")
                return
            }

            if httpResponse.statusCode == 304 {
                self.saveCacheMetadata(from: httpResponse, didUpdateFile: false)
                return
            }

            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                self.displayErrorIfCacheIsEmpty(
                    "GitHub returned HTTP \(httpResponse.statusCode)."
                )
                return
            }

            do {
                try data.write(to: self.fileURL, options: .atomic)
                self.saveCacheMetadata(from: httpResponse, didUpdateFile: true)

                guard let string = String(data: data, encoding: .utf8) else {
                    self.displayErrorIfCacheIsEmpty(
                        "The downloaded Markdown file is not valid UTF-8."
                    )
                    return
                }

                DispatchQueue.main.async {
                    self.attributedText = string
                }
            } catch {
                self.displayErrorIfCacheIsEmpty(error.localizedDescription)
            }
        }.resume()
    }

    private func cachedValidators() -> (eTag: String?, lastModified: String?) {
        guard let context = managedObject?.managedObjectContext else {
            return (nil, nil)
        }

        var validators: (eTag: String?, lastModified: String?) = (nil, nil)
        context.performAndWait {
            let record = CDMarkdownCache.record(
                for: gitHubURL,
                in: context,
                createIfNeeded: false
            )
            validators = (record?.eTag, record?.lastModified)
        }
        return validators
    }

    private func saveCacheMetadata(
        from response: HTTPURLResponse,
        didUpdateFile: Bool
    ) {
        guard let context = managedObject?.managedObjectContext else {
            return
        }

        let eTag = response.value(forHTTPHeaderField: "ETag")
        let lastModified = response.value(forHTTPHeaderField: "Last-Modified")
        let resourceURL = gitHubURL!

        context.perform {
            guard let record = CDMarkdownCache.record(
                for: resourceURL,
                in: context,
                createIfNeeded: true
            ) else {
                return
            }

            record.eTag = eTag ?? record.eTag
            record.lastModified = lastModified ?? record.lastModified
            record.lastChecked = Date()
            if didUpdateFile {
                record.lastUpdated = Date()
            }

            do {
                try context.save()
            } catch {
                prettyPrint("Unable to save Markdown cache metadata: \(error)")
            }
        }
    }

    private func displayErrorIfCacheIsEmpty(_ message: String) {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        DispatchQueue.main.async {
            self.attributedText = message
        }
    }
}

struct ExplanationSection: Identifiable {
    let id: String
    let title: String
    let markdown: String

    var isInitiallyExpanded: Bool {
        let featuredTitles = [
            "குறள் எண்",
            "குறள்",
            "கொண்டு கூட்டும் முறை",
            "குறள் சாரம்",
            "பரிமேலழகர் உரை"
        ]
        return featuredTitles.contains(title)
    }
}

struct ExplanationDocument {
    let sections: [ExplanationSection]
    let youtubeVideos: [YouTubeVideo]

    init(markdown: String) {
        sections = Self.makeSections(from: markdown)
        youtubeVideos = Self.findYouTubeVideos(in: markdown)
    }

    private static func makeSections(from markdown: String) -> [ExplanationSection] {
        var sections: [ExplanationSection] = []
        var title = "விளக்கம்"
        var bodyLines: [String] = []

        func appendCurrentSection() {
            let body = bodyLines
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !body.isEmpty, body != "உ" else {
                bodyLines.removeAll()
                return
            }

            sections.append(
                ExplanationSection(
                    id: "\(sections.count)-\(title)",
                    title: title,
                    markdown: body
                )
            )
            bodyLines.removeAll()
        }

        for line in markdown.components(separatedBy: .newlines) {
            if line.hasPrefix("## ") {
                appendCurrentSection()
                title = String(line.dropFirst(3))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                bodyLines.append(line)
            }
        }

        appendCurrentSection()
        return sections
    }

    private static func findYouTubeVideos(in markdown: String) -> [YouTubeVideo] {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            return []
        }

        let range = NSRange(markdown.startIndex..., in: markdown)
        var videos: [YouTubeVideo] = []

        detector.enumerateMatches(in: markdown, options: [], range: range) {
            result,
            _,
            _ in
            guard let url = result?.url,
                  let videoID = youtubeVideoID(from: url) else {
                return
            }
            let video = YouTubeVideo(
                id: videoID,
                startTime: youtubeStartTime(from: url)
            )
            guard !videos.contains(video) else {
                return
            }
            videos.append(video)
        }

        return videos
    }

    private static func youtubeVideoID(from url: URL) -> String? {
        guard let host = url.host?.lowercased() else {
            return nil
        }

        let candidate: String?
        if host == "youtu.be" || host == "www.youtu.be" {
            candidate = url.pathComponents.dropFirst().first
        } else if host == "youtube.com" || host == "www.youtube.com" ||
                    host == "m.youtube.com" {
            if url.path == "/watch" {
                candidate = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )?.queryItems?.first(where: { $0.name == "v" })?.value
            } else if url.pathComponents.count >= 3,
                      ["embed", "shorts"].contains(url.pathComponents[1]) {
                candidate = url.pathComponents[2]
            } else {
                candidate = nil
            }
        } else {
            candidate = nil
        }

        guard let candidate = candidate else {
            return nil
        }

        let allowedCharacters = CharacterSet.alphanumerics.union(
            CharacterSet(charactersIn: "_-")
        )
        let videoID = candidate.unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()

        return videoID.isEmpty ? nil : videoID
    }

    private static func youtubeStartTime(from url: URL) -> Int? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let value = components?.queryItems?
            .first(where: { $0.name == "t" || $0.name == "start" })?
            .value?
            .lowercased() else {
            return nil
        }

        if let seconds = Int(value) {
            return seconds
        }

        let pattern = #"^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?$"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(
                in: value,
                range: NSRange(value.startIndex..., in: value)
              ) else {
            return nil
        }

        func component(at index: Int) -> Int {
            let range = match.range(at: index)
            guard range.location != NSNotFound,
                  let swiftRange = Range(range, in: value) else {
                return 0
            }
            return Int(value[swiftRange]) ?? 0
        }

        let seconds = component(at: 1) * 3600 + component(at: 2) * 60 + component(at: 3)
        return seconds > 0 ? seconds : nil
    }
}

struct YouTubeVideo: Hashable {
    let id: String
    let startTime: Int?
}

final class YouTubePlayerController: ObservableObject {
    @Published private(set) var activeVideo: YouTubeVideo?

    func play(_ video: YouTubeVideo) {
        activeVideo = video
    }

    func close() {
        activeVideo = nil
    }
}

struct ExplanationView: View {
    @ObservedObject var vm: ExplanationViewModel
    @EnvironmentObject private var videoPlayer: YouTubePlayerController

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ExplanationPageHeader()

                if vm.sections.isEmpty {
                    ProgressView("விளக்கத்தைத் தயாரிக்கிறது…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                } else {
                    ForEach(vm.sections) { section in
                        ExplanationSectionCard(section: section)
                    }
                }

                if !vm.youtubeVideos.isEmpty {
                    ExplanationVideoSection(
                        videos: vm.youtubeVideos,
                        activeVideo: videoPlayer.activeVideo,
                        onPlay: videoPlayer.play
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .padding(.bottom, videoPlayer.activeVideo == nil ? 0 : 170)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.08),
                    Color(.systemGroupedBackground),
                    Color.indigo.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationBarTitle("விரிவான விளக்கம்", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                vm.fetchFileFromInternet()
            }, label: {
                Image(systemName: "arrow.clockwise")
            })
            .accessibilityLabel("விளக்கத்தைப் புதுப்பி")
        )
        .onAppear {
            vm.fetchFile()
        }
    }
}

struct ExplanationPageHeader: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("திருக்குறள்")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("உரை, இலக்கணம் மற்றும் விரிவான கருத்தாக்கம்")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 5)
    }
}

struct ExplanationSectionCard: View {
    let section: ExplanationSection
    @State private var isExpanded: Bool

    init(section: ExplanationSection) {
        self.section = section
        _isExpanded = State(initialValue: section.isInitiallyExpanded)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            MDText(markdown: section.markdown)
                .padding(.top, 14)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            HStack(spacing: 11) {
                Image(systemName: iconName)
                    .foregroundColor(accentColor)
                    .frame(width: 28, height: 28)
                    .background(accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(section.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
        .accentColor(accentColor)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accentColor.opacity(0.12), lineWidth: 1)
        )
    }

    private var iconName: String {
        if section.title.contains("குறள்") {
            return "quote.opening"
        } else if section.title.contains("இலக்கண") {
            return "text.book.closed"
        } else if section.title.contains("ஆங்கில") {
            return "globe"
        } else if section.title.contains("ஒலி") {
            return "speaker.wave.2.fill"
        } else if section.title.contains("காணொளி") {
            return "play.rectangle.fill"
        } else {
            return "text.alignleft"
        }
    }

    private var accentColor: Color {
        if section.title.contains("குறள்") {
            return .orange
        } else if section.title.contains("இலக்கண") {
            return .purple
        } else if section.title.contains("ஆங்கில") {
            return .blue
        } else {
            return .indigo
        }
    }
}

struct ExplanationVideoSection: View {
    let videos: [YouTubeVideo]
    let activeVideo: YouTubeVideo?
    let onPlay: (YouTubeVideo) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("காணொளி விளக்கம்", systemImage: "play.rectangle.fill")
                .font(.headline)
                .foregroundColor(.red)

            ForEach(videos, id: \.self) { video in
                YouTubeVideoThumbnail(
                    video: video,
                    isPlaying: activeVideo == video,
                    onPlay: { onPlay(video) }
                )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityLabel("YouTube காணொளி")
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.12), lineWidth: 1)
        )
    }
}

struct YouTubeVideoThumbnail: View {
    let video: YouTubeVideo
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            Color.black
                .aspectRatio(16.0 / 9.0, contentMode: .fit)
                .overlay {
                AsyncImage(
                    url: URL(string: "https://i.ytimg.com/vi/\(video.id)/hqdefault.jpg")
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.black
                        .overlay(ProgressView().tint(.white))
                }
                .clipped()
            }
            .overlay(Color.black.opacity(0.18))
            .overlay {
                Image(systemName: isPlaying ? "waveform" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 68, height: 48)
                        .background(isPlaying ? Color.black.opacity(0.78) : Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .overlay(alignment: .bottomTrailing) {
                if let startTime = video.startTime {
                    Text(Self.formattedTime(startTime))
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(8)
                    }
                }
            .clipped()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isPlaying ? "YouTube காணொளி இயங்குகிறது" : "YouTube காணொளியை இயக்கு"
        )
    }

    private static func formattedTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct FloatingYouTubePlayer: View {
    let video: YouTubeVideo
    let onClose: () -> Void

    var body: some View {
        YouTubeVideoView(video: video)
            .frame(width: 280, height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.black.opacity(0.78))
                        .clipShape(Circle())
                }
                .padding(7)
                .accessibilityLabel("காணொளியை மூடு")
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 14, y: 6)
            .accessibilityElement(children: .contain)
    }
}

struct YouTubeVideoView: UIViewRepresentable {
    let video: YouTubeVideo

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        webView.isHidden = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedVideo != video else {
            return
        }

        context.coordinator.loadedVideo = video
        webView.isHidden = true
        let startParameter = video.startTime.map { "&start=\($0)" } ?? ""
        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
          <meta name="referrer" content="strict-origin-when-cross-origin">
          <style>
            html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: #000; }
            iframe { display: block; width: 100%; height: 100%; border: 0; }
          </style>
        </head>
        <body>
          <iframe
            src="https://www.youtube.com/embed/\(video.id)?playsinline=1&rel=0&origin=https%3A%2F%2Fwww.karka.in\(startParameter)"
            title="YouTube video"
            referrerpolicy="strict-origin-when-cross-origin"
            allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture">
          </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.karka.in"))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var loadedVideo: YouTubeVideo?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            UIView.transition(
                with: webView,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: { webView.isHidden = false }
            )
        }
    }
}

struct AttrLabel: UIViewRepresentable {

    typealias TheUIView = UILabel
    fileprivate var configuration = { (view: TheUIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}

extension String {

    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }

}
