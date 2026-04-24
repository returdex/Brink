import Foundation
import SwiftUI

enum L10n {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    static func nestedTasksStillActive(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("%lld nested tasks still active", comment: ""),
            count
        )
    }

    static func importCompleteMessage(taskCount: Int, filename: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("Loaded %lld tasks from %@.", comment: ""),
            taskCount,
            filename
        )
    }

    static func exportCompleteMessage(format: String, filename: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("Saved %@ to %@.", comment: ""),
            format,
            filename
        )
    }
}
