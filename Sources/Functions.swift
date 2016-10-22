import Foundation

func add<T>(to elements: [T]) -> (T) -> [T] {
    return { element in
        return elements + [element]
    }
}

func replace<T: Equatable>(in elements: [T]) -> (T) -> [T] {
    return { element in
        guard let index = elements.index(of: element) else { return elements }
        var tmpElements = elements
        tmpElements.replaceSubrange(index ..< index + 1, with: [element])
        return tmpElements
    }
}

func toBool(_ string: String) -> Bool {
    return string.lowercased() == "true"
}
