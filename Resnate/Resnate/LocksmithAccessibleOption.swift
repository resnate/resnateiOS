import Foundation

// MARK: Accessible
public enum LocksmithAccessibleOption: RawRepresentable {
    case WhenUnlocked, AfterFirstUnlock, Always, WhenUnlockedThisDeviceOnly, AfterFirstUnlockThisDeviceOnly, AlwaysThisDeviceOnly, WhenPasscodeSetThisDeviceOnly
    
    public init?(rawValue: String) {
        if #available(iOS 8.0, *) {
            switch rawValue {
            case String(kSecAttrAccessibleWhenUnlocked):
                self = WhenUnlocked
            case String(kSecAttrAccessibleAfterFirstUnlock):
                self = AfterFirstUnlock
            case String(kSecAttrAccessibleAlways):
                self = Always
            case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
                self = WhenUnlockedThisDeviceOnly
            case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
                self = AfterFirstUnlockThisDeviceOnly
            case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
                self = AlwaysThisDeviceOnly
            case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
                self = WhenPasscodeSetThisDeviceOnly
            default:
                self = WhenUnlocked
            }
        } else {
            self = WhenUnlocked
        }
    }
    
    public var rawValue: String {
        switch self {
        case .WhenUnlocked:
            return String(kSecAttrAccessibleWhenUnlocked)
        case .AfterFirstUnlock:
            return String(kSecAttrAccessibleAfterFirstUnlock)
        case .Always:
            return String(kSecAttrAccessibleAlways)
        case .WhenPasscodeSetThisDeviceOnly:
            if #available(iOS 8.0, *) {
                return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            } else {
                return ""
            }
        case .WhenUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .AfterFirstUnlockThisDeviceOnly:
            return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .AlwaysThisDeviceOnly:
            return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
        }
    }
}
