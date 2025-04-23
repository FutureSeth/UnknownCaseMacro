import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

@main
struct EnumUnknownCasePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumMemberMacro.self,
    ]
}

enum CustomError: Error { case message(String) }

public struct EnumMemberMacro: MemberMacro, ExtensionMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        // Must be an enum.
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw CustomError.message("Must be applied on an enum")
        }
        
        guard let _ = enumDecl.inheritanceClause?.inheritedTypes.first?.type else { return [] }
        
        let cases = enumDecl.memberBlock.members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self)?.elements }
        
        let newElement = try EnumCaseDeclSyntax("case unknown")
        
        let initializer = try InitializerDeclSyntax("init(rawValue: \(String.self))") {
            try SwitchExprSyntax("switch rawValue") {
                for caseList in cases {
                    for `case` in caseList {
                        SwitchCaseSyntax("""
                                   case Self.\(raw: `case`.name).rawValue:
                                     self = .\(raw: `case`.name)
                                   """)
                    }
                }
                SwitchCaseSyntax("""
                           default:
                             self = .unknown
                           """)
            }
        }
        
        let rawValue = try VariableDeclSyntax("var rawValue: \(String.self)") {
            try SwitchExprSyntax("switch self") {
                for caseList in cases {
                    for `case` in caseList {
                        SwitchCaseSyntax("""
                               case .\(raw: `case`.name):
                                 return \(literal: `case`.name.text)
                               """)
                    }
                    
                }
                
                SwitchCaseSyntax("""
                    case .unknown:
                        return "unknown"
                    """)
            }
        }
        
        
        
        return [DeclSyntax(newElement), DeclSyntax(initializer), DeclSyntax(rawValue)]
    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            return []
        }
        
        let enumName = enumDecl.name.text
        
        return [try ExtensionDeclSyntax(
            """
            extension \(raw: enumName): Decodable {
                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let rawValue = try container.decode(String.self)
                    self = \(raw: enumName)(rawValue: rawValue)
                }
            }
            
            extension \(raw: enumName): Encodable {
                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .unknown:
                        try container.encode("unknown")
                    default:
                        try container.encode(self.rawValue)
                    }
                }
            }
            """
        )]
    }
}
