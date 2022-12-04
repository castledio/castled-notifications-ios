//
//  NotificationService.swift
//  CastledNotification
//
//  Created by Faisal Azeez on 21/11/2022.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        /*
         if let bestAttemptContent = bestAttemptContent {
         // Modify the notification content here...
         bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
         
         contentHandler(bestAttemptContent)
         }*/
        
        if let customCasledDict = request.content.userInfo[CastledConstants.kCastledPushMainCustomKey] as? NSDictionary{
            if customCasledDict[CastledConstants.kCastledPushNotificationIdKey] is String{
                defer {
                    contentHandler(bestAttemptContent ?? request.content)
                }
                
                guard let attachment = request.attachment else { return }
                
                bestAttemptContent?.attachments = [attachment]
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let customCasledDict = content.userInfo[CastledConstants.kCastledPushMainCustomKey] as? NSDictionary, let attachmentURL = customCasledDict[CastledConstants.kCastledPushMediaUrl] as? String,let imageData = try? Data(contentsOf: URL(string: attachmentURL)!) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {

    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString + ".jpg"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
