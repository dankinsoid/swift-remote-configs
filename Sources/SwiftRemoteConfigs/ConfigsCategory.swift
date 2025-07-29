import Foundation

public struct ConfigsCategory: RawRepresentable, Hashable, OptionSet, Comparable {

	public var rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public static let all = ConfigsCategory(rawValue: 0xFFFFFFFF)
	public static let secure = ConfigsCategory(rawValue: 0x00000001)
	public static let insecure = ConfigsCategory(rawValue: 0x00000002)
	public static let remote = ConfigsCategory(rawValue: 0x00000004)

	public static func < (lhs: ConfigsCategory, rhs: ConfigsCategory) -> Bool {
		if lhs.rawValue.nonzeroBitCount == rhs.rawValue.nonzeroBitCount {
			return lhs.rawValue < rhs.rawValue
		} else {
			return lhs.rawValue.nonzeroBitCount < rhs.rawValue.nonzeroBitCount
		}
	}
}

#if compiler(>=5.6)
extension ConfigsCategory: Sendable {}
#endif
