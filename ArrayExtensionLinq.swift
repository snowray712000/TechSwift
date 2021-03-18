extension Array {
    func any(_ fn: (Element) -> Bool) -> Bool {
        for a1 in self {
            if ( fn(a1) ) { return true }
        }
        return false
    }
    func all(_ fn: (Element) -> Bool) -> Bool {
        for a1 in self {
            if ( !fn(a1) ) { return false }
        }
        return true
    }
}
