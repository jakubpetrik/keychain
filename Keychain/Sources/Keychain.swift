public final class Keychain {
    private let identifier: String
    private lazy var values: NSMutableDictionary = {
        guard let data = self.load()
            , values = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableDictionary else {
                return NSMutableDictionary()
        }
        return values
    }()

    private func save(data: Data) -> Bool {
        let query = [
              kSecClass as String       : kSecClassGenericPassword as String
            , kSecAttrAccount as String : identifier
            , kSecValueData as String   : data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        return status == noErr
    }

    private func load() -> Data? {
        let query = [
              kSecClass as String       : kSecClassGenericPassword
            , kSecAttrAccount as String : identifier
            , kSecReturnData as String  : kCFBooleanTrue
            , kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        let dataTypeRef = UnsafeMutablePointer<AnyObject?>(allocatingCapacity: 1)

        let status = SecItemCopyMatching(query, dataTypeRef)

        guard let data = dataTypeRef.pointee as? Data where status == noErr else { return nil }
        return data
    }

    private func delete() -> Bool {
        let query = [
              kSecClass as String       : kSecClassGenericPassword
            , kSecAttrAccount as String : identifier
        ]

        let status = SecItemDelete(query as CFDictionary)
        
        return status == noErr
    }

    public init(identifier: String) {
        self.identifier = identifier
    }

    public subscript(aKey: NSCopying) -> AnyObject? {
        get { return object(forKey: aKey) }
        set { _ = setObject(newValue, forKey: aKey) }
    }

    public func object<T: AnyObject>(forKey aKey: NSCopying) -> T? {
        return values.object(forKey: aKey) as? T
    }

    public func setObject(_ anObject: AnyObject?, forKey aKey: NSCopying) -> Bool {
        if let objectToSet = anObject {
            values.setObject(objectToSet, forKey: aKey)
        }
        else {
            values.removeObject(forKey: aKey)
        }
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: values)
        return save(data: archivedData)
    }

    public func clear() {
        _ = delete()
        values = NSMutableDictionary()
    }
}
