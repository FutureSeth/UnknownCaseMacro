import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftCompilerPlugin

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(EnumUnknownCaseMacros)
import EnumUnknownCaseMacros

let testMacros: [String: Macro.Type] = [
    "stringify": EnumMemberMacro.self,
]

struct EnumUnknownCasePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumMemberMacro.self,
    ]
}
#endif

final class EnumUnknownCaseTests: XCTestCase {
//    func testMacro() throws {
//        #if canImport(EnumUnknownCaseMacros)
//        assertMacroExpansion(
//            """
//            #stringify(a + b)
//            """,
//            expandedSource: """
//            (a + b, "a + b")
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }

//    func testMacroWithStringLiteral() throws {
//        #if canImport(EnumUnknownCaseMacros)
//        assertMacroExpansion(
//            #"""
//            #stringify("Hello, \(name)")
//            """#,
//            expandedSource: #"""
//            ("Hello, \(name)", #""Hello, \(name)""#)
//            """#,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
}
