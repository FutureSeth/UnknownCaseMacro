import EnumUnknownCase
//
//let a = 17
//let b = 25
//
//let (result, code) = #stringify(a + b)
//
//print("The value \(result) was produced by the code \"\(code)\"")


@UnknownCase
enum Foo: String {
    case bar
    case baz
}

