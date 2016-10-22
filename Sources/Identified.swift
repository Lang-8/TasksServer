import Foundation

protocol Identified {

    var id: UInt64 { get }

}

func fetch<T: Identified>(by idString: String, in array: [T]) -> T? {
    guard let id = UInt64(idString) else { return .none}
    return array.filter { $0.id == id }.first
}
