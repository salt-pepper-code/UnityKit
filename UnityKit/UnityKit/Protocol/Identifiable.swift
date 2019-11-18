protocol Identifiable: Equatable {
    var uuid: String { get }
}

public func == (lhs: Object, rhs: Object) -> Bool {
    return lhs.uuid == rhs.uuid
}

public func == (lhs: Scene, rhs: Scene) -> Bool {
    return lhs.uuid == rhs.uuid
}
