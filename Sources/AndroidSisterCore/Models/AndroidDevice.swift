import Foundation

public struct AndroidDevice: Identifiable, Hashable, Sendable {
    public enum State: String, Hashable, Sendable {
        case connected = "device"
        case unauthorized
        case offline
        case noPermissions = "no permissions"
        case unknown

        public var isUsable: Bool {
            self == .connected
        }
    }

    public let serial: String
    public let state: State
    public let model: String?
    public let product: String?
    public let transportID: String?
    public let manufacturer: String?
    public let androidVersion: String?
    public let sdkLevel: Int?

    public var id: String { serial }

    public init(
        serial: String,
        state: State,
        model: String? = nil,
        product: String? = nil,
        transportID: String? = nil,
        manufacturer: String? = nil,
        androidVersion: String? = nil,
        sdkLevel: Int? = nil
    ) {
        self.serial = serial
        self.state = state
        self.model = model
        self.product = product
        self.transportID = transportID
        self.manufacturer = manufacturer
        self.androidVersion = androidVersion
        self.sdkLevel = sdkLevel
    }

    public var displayName: String {
        if let model, !model.isEmpty {
            return model.replacingOccurrences(of: "_", with: " ")
        }
        return serial
    }

    public func applying(_ facts: AndroidDeviceFacts) -> AndroidDevice {
        AndroidDevice(
            serial: serial,
            state: state,
            model: facts.model ?? model,
            product: product,
            transportID: transportID,
            manufacturer: facts.manufacturer,
            androidVersion: facts.androidVersion,
            sdkLevel: facts.sdkLevel
        )
    }
}

public struct AndroidDeviceFacts: Equatable, Sendable {
    public let manufacturer: String?
    public let model: String?
    public let androidVersion: String?
    public let sdkLevel: Int?

    public init(
        manufacturer: String?,
        model: String?,
        androidVersion: String?,
        sdkLevel: Int?
    ) {
        self.manufacturer = manufacturer
        self.model = model
        self.androidVersion = androidVersion
        self.sdkLevel = sdkLevel
    }
}
