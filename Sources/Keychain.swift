import Foundation

public final class Keychain {
    private let identifier: String
    private lazy var values: NSMutableDictionary = {
        guard let data = loadData()
            , let values = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableDictionary
            else { return NSMutableDictionary() }
        return values
    }()

    private func save(data: Data) -> Bool {
        let query =
            [ kSecClass: kSecClassGenericPassword
            , kSecAttrAccount: identifier
            , kSecValueData: data
            ] as CFDictionary

        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        return status == noErr
    }

    private func loadData() -> Data? {
        let query =
            [ kSecClass: kSecClassGenericPassword
            , kSecAttrAccount: identifier
            , kSecReturnData: kCFBooleanTrue
            , kSecMatchLimit: kSecMatchLimitOne
            ] as CFDictionary

        let dataTypeRef = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        let status = SecItemCopyMatching(query, dataTypeRef)
        guard let data = dataTypeRef.pointee as? Data, status == noErr else { return nil }
        return data
    }

    private func delete() {
        let query =
            [ kSecClass: kSecClassGenericPassword
            , kSecAttrAccount: identifier
            ] as CFDictionary

        SecItemDelete(query)
    }

    public init(identifier: String) {
        self.identifier = identifier
    }

    public subscript<T: AnyObject>(aKey: NSCopying) -> T? {
        get { return object(forKey: aKey) }
        set { _ = setObject(newValue, forKey: aKey) }
    }

    private func object<T: AnyObject>(forKey aKey: NSCopying) -> T? {
        return values.object(forKey: aKey) as? T
    }

    private func setObject(_ anObject: AnyObject?, forKey aKey: NSCopying) -> Bool {
        if let objectToSet = anObject {
            values.setObject(objectToSet, forKey: aKey)
        } else {
            values.removeObject(forKey: aKey)
        }
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: values)
        return save(data: archivedData)
    }

    public func clear() {
        delete()
        values = NSMutableDictionary()
    }
}
