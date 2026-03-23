import UserNotifications
import AppKit

class NotificationService: NSObject, UNUserNotificationCenterDelegate, NSUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private enum RetentionPolicy {
        static let maxLogBytes = 32 * 1024
        static let logMaxAge: TimeInterval = 7 * 24 * 60 * 60
        static let attachmentMaxAge: TimeInterval = 24 * 60 * 60
        static let attachmentMaxCount = 4
    }

    private var useModernAPI = true
    private let fileManager = FileManager.default

    private override init() {
        super.init()
        // Set both delegates
        UNUserNotificationCenter.current().delegate = self
        NSUserNotificationCenter.default.delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.logToFile("Permission: granted=\(granted) error=\(String(describing: error))")
            if !granted {
                DispatchQueue.main.async {
                    self.useModernAPI = false
                }
            }
        }

        // Also dump current settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            self.logToFile("Settings: auth=\(settings.authorizationStatus.rawValue) alert=\(settings.alertSetting.rawValue) sound=\(settings.soundSetting.rawValue) badge=\(settings.badgeSetting.rawValue)")
        }
    }

    private func logToFile(_ message: String) {
        let logFile = cacheDirectory.appendingPathComponent("criterion-notif-log.txt")
        guard UserDefaults.standard.bool(forKey: "developerMode") else {
            try? fileManager.removeItem(at: logFile)
            return
        }

        pruneLogFileIfNeeded(at: logFile)

        let line = "[\(Date())] \(message)\n"
        if let data = line.data(using: .utf8) {
            if fileManager.fileExists(atPath: logFile.path) {
                if let handle = try? FileHandle(forWritingTo: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: logFile)
            }
        }
    }

    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
    }

    private var attachmentDirectory: URL {
        let dir = cacheDirectory.appendingPathComponent("CriterionNowNotificationAttachments", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func pruneLogFileIfNeeded(at fileURL: URL) {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        if let attrs = try? fileManager.attributesOfItem(atPath: fileURL.path),
           let modified = attrs[.modificationDate] as? Date,
           Date().timeIntervalSince(modified) > RetentionPolicy.logMaxAge {
            try? fileManager.removeItem(at: fileURL)
            return
        }

        guard let data = try? Data(contentsOf: fileURL),
              data.count > RetentionPolicy.maxLogBytes else { return }

        let trimmed = Data(data.suffix(RetentionPolicy.maxLogBytes / 2))
        try? trimmed.write(to: fileURL, options: .atomic)
    }

    private func pruneAttachmentFiles() {
        let legacyFile = cacheDirectory.appendingPathComponent("criterion-poster-notif.png")
        try? fileManager.removeItem(at: legacyFile)

        let files = (try? fileManager.contentsOfDirectory(
            at: attachmentDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        let now = Date()
        var retained: [(url: URL, date: Date)] = []

        for file in files {
            let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .creationDateKey])
            let modified = values?.contentModificationDate ?? values?.creationDate ?? .distantPast
            if now.timeIntervalSince(modified) > RetentionPolicy.attachmentMaxAge {
                try? fileManager.removeItem(at: file)
            } else {
                retained.append((file, modified))
            }
        }

        let overflow = retained
            .sorted { $0.date > $1.date }
            .dropFirst(RetentionPolicy.attachmentMaxCount)

        for file in overflow {
            try? fileManager.removeItem(at: file.url)
        }
    }

    private var lastSendTime: Date = .distantPast

    func sendNewFilmNotification(title: String, year: String, director: String, posterImage: NSImage?) {
        // Debounce — no more than 1 notification per 5 seconds
        let now = Date()
        guard now.timeIntervalSince(lastSendTime) > 5 else { return }
        lastSendTime = now

        let displayTitle = "Now Playing on Criterion 24/7"
        var body = year.isEmpty ? title : "\(title) (\(year))"
        if !director.isEmpty {
            body += "\nDir. \(director)"
        }

        logToFile("Sending notification: \(title) - \(body)")

        if useModernAPI {
            sendModernNotification(title: displayTitle, body: body, posterImage: posterImage)
        } else {
            sendLegacyNotification(title: displayTitle, body: body, posterImage: posterImage)
        }
    }

    // MARK: - Modern API (UNUserNotification)

    private func sendModernNotification(title: String, body: String, posterImage: NSImage?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let poster = posterImage, let attachment = createImageAttachment(image: poster) {
            content.attachments = [attachment]
        }

        let request = UNNotificationRequest(
            identifier: "criterion-\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            self?.logToFile("Modern API result: error=\(String(describing: error))")
        }
    }

    // MARK: - Legacy API (NSUserNotification — works for LSUIElement apps)

    private func sendLegacyNotification(title: String, body: String, posterImage: NSImage?) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName

        if let poster = posterImage {
            notification.contentImage = poster
        }

        notification.hasActionButton = true
        notification.actionButtonTitle = "Open"

        NSUserNotificationCenter.default.deliver(notification)
        logToFile("Legacy API: delivered")
    }

    // MARK: - Image Attachment (for modern API)

    private func createImageAttachment(image: NSImage) -> UNNotificationAttachment? {
        pruneAttachmentFiles()
        let fileURL = attachmentDirectory
            .appendingPathComponent("criterion-poster-\(UUID().uuidString)")
            .appendingPathExtension("png")

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else { return nil }

        do {
            try pngData.write(to: fileURL)
            return try UNNotificationAttachment(identifier: "poster", url: fileURL, options: nil)
        } catch {
            return nil
        }
    }

    // MARK: - UNUserNotificationCenterDelegate (modern)

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DispatchQueue.main.async { NSApp.activate(ignoringOtherApps: true) }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    // MARK: - NSUserNotificationCenterDelegate (legacy — always show)

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true // Always show, even when app is frontmost
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        NSApp.activate(ignoringOtherApps: true)
    }
}
