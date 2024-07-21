import WasmParser

struct Encoder {
    var output: [UInt8] = []

    mutating func writeHeader() {
        output.append(contentsOf: [
            0x00, 0x61, 0x73, 0x6D,  // magic
            0x01, 0x00, 0x00, 0x00,  // version
        ])
    }

    mutating func section(id: UInt8, _ sectionContent: (inout Encoder) throws -> Void) rethrows {
        output.append(id)
        var contentEncoder = Encoder()
        try sectionContent(&contentEncoder)
        writeUnsignedLEB128(UInt32(contentEncoder.output.count))
        output.append(contentsOf: contentEncoder.output)
    }

    mutating func encodeVector<Source: Collection>(
        _ values: Source, encodeElement: (Source.Element, inout Encoder) throws -> Void
    ) rethrows {
        writeUnsignedLEB128(UInt32(values.count))
        for value in values {
            try encodeElement(value, &self)
        }
    }

    mutating func encodeVector<Source: Collection, Element: WasmEncodable>(_ values: Source, transform: (Source.Element) -> (Element)) {
        encodeVector(
            values,
            encodeElement: { element, encoder in
                transform(element).encode(to: &encoder)
            })
    }

    mutating func encodeVector<Source: Collection>(_ values: Source) where Source.Element: WasmEncodable {
        encodeVector(values, encodeElement: { $0.encode(to: &$1) })
    }

    mutating func encodeByteVector(_ values: [UInt8]) {
        writeUnsignedLEB128(UInt32(values.count))
        output.append(contentsOf: values)
    }

    mutating func encode<T: WasmEncodable>(_ value: T) {
        value.encode(to: &self)
    }

    mutating func writeUnsignedLEB128<T: UnsignedInteger & FixedWidthInteger>(_ value: T) {
        var value = value
        repeat {
            var byte = UInt8(value & 0b0111_1111)
            value >>= 7
            if value != 0 {
                byte |= 0b1000_0000
            }
            output.append(byte)
        } while value != 0
    }

    mutating func writeSignedLEB128<T: SignedInteger & FixedWidthInteger>(_ value: T) {
        func leb128LoopUntil(_ until: (T, UInt8) -> Bool) {
            var value = value
            while true {
                let byte = UInt8(value & 0b0111_1111)
                value >>= 7
                if until(value, byte) {
                    output.append(byte)
                    break
                } else {
                    output.append(byte | 0b1000_0000)
                }
            }
        }

        if value < 0 {
            leb128LoopUntil { value, byte in
                return value == -1 && (byte & 0b0100_0000) != 0
            }
        } else {
            leb128LoopUntil { value, byte in
                return value == 0 && (byte & 0b0100_0000) == 0
            }
        }
    }

    mutating func writeExpression(lexer: inout Lexer, watModule: inout WatModule) throws {
        var parser = ExpressionParser<ExpressionEncoder>(lexer: lexer)
        var exprEncoder = ExpressionEncoder()
        try parser.parse(visitor: &exprEncoder, watModule: &watModule)
        try exprEncoder.visitEnd()
        output.append(contentsOf: exprEncoder.encoder.output)
        lexer = parser.parser.lexer
    }
}

protocol WasmEncodable {
    func encode(to encoder: inout Encoder)
}

extension ValueType: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        switch self {
        case .i32: encoder.output.append(0x7F)
        case .i64: encoder.output.append(0x7E)
        case .f32: encoder.output.append(0x7D)
        case .f64: encoder.output.append(0x7C)
        case .ref(let refType): refType.encode(to: &encoder)
        }
    }
}

extension ReferenceType: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        switch self {
        case .funcRef: encoder.output.append(0x70)
        case .externRef: encoder.output.append(0x6F)
        }
    }
}

extension FunctionType: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        encoder.output.append(0x60)
        encoder.writeUnsignedLEB128(UInt32(parameters.count))
        for param in parameters {
            param.encode(to: &encoder)
        }
        encoder.writeUnsignedLEB128(UInt32(results.count))
        for result in results {
            result.encode(to: &encoder)
        }
    }
}

extension TableType: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        elementType.encode(to: &encoder)
        limits.encode(to: &encoder)
    }
}

struct ElementExprCollector: VoidInstructionVisitor {
    var isAllRefFunc: Bool = true
    var useExpression: Bool {
        // if all instructions are ref.func, use function indices representation
        return !isAllRefFunc
    }
    let addFunctionIndex: (UInt32?) -> Void

    mutating func parse(indices: WatParser.ElementDecl.Indices, watModule: inout WatModule) throws {
        switch indices {
        case .elementExprList(let lexer):
            var parser = ExpressionParser<ElementExprCollector>(lexer: lexer)
            try parser.parseElemExprList(visitor: &self, watModule: &watModule)
        case .functionList(let lexer):
            try self.parseFunctionList(lexer: lexer, watModule: watModule)
        }
    }

    private mutating func parseFunctionList(lexer: Lexer, watModule: WatModule) throws {
        var parser = Parser(lexer)
        while let funcUse = try parser.takeIndexOrId() {
            let (_, funcIndex) = try watModule.functionsMap.resolve(use: funcUse)
            addFunctionIndex(UInt32(funcIndex))
        }
    }

    mutating func visitRefFunc(functionIndex: UInt32) throws {
        addFunctionIndex(functionIndex)
    }
    mutating func visitRefNull(type: ReferenceType) throws {
        isAllRefFunc = false
        addFunctionIndex(nil)
    }
}

extension WAT.WatParser.ElementDecl {
    func encode(to encoder: inout Encoder, watModule: inout WatModule) throws {
        var flags: UInt32 = 0
        var tableIndex: UInt32? = nil
        var isPassive = false
        var hasTableIndex = false
        switch self.mode {
        case .active(let table, _):
            let index: Int?
            if let table {
                index = try watModule.tablesMap.resolve(use: table).index
            } else {
                index = nil
            }
            if type != .funcRef || (index != nil && index != 0) {
                // has index
                flags |= 0b0010
                tableIndex = UInt32(index ?? 0)
                hasTableIndex = true
            }
        case .passive:
            // is passive
            flags |= 0b0001
            isPassive = true
        case .declarative:
            // is declarative
            flags |= 0b0011
            isPassive = true
        case .inline:
            fatalError("Inline element segment should be replaced with active mode")
        }

        var functionIndices: [UInt32?] = []
        var collector = ElementExprCollector(addFunctionIndex: { functionIndices.append($0) })
        try collector.parse(indices: indices, watModule: &watModule)

        if collector.useExpression {
            // use expression
            flags |= 0b0100
        }

        encoder.writeUnsignedLEB128(flags)
        if let tableIndex = tableIndex {
            encoder.writeUnsignedLEB128(tableIndex)
        }
        if case let .active(_, offset) = self.mode {
            switch offset {
            case .source(var lexer):
                try encoder.writeExpression(lexer: &lexer, watModule: &watModule)
            case .synthesized(let offset):
                var exprEncoder = ExpressionEncoder()
                try exprEncoder.visitI32Const(value: Int32(offset))
                try exprEncoder.visitEnd()
                encoder.output.append(contentsOf: exprEncoder.encoder.output)
            }
        }
        if isPassive || hasTableIndex {
            if collector.useExpression {
                encoder.encode(type)
            } else {
                // Write ExternKind.func
                encoder.writeUnsignedLEB128(UInt8(0x00))
            }
        }

        if collector.useExpression {
            try encoder.encodeVector(functionIndices) { funcIndex, encoder in
                var exprEncoder = ExpressionEncoder()
                if let funcIndex {
                    try exprEncoder.visitRefFunc(functionIndex: funcIndex)
                } else {
                    try exprEncoder.visitRefNull(type: type)
                }
                try exprEncoder.visitEnd()
                encoder.output.append(contentsOf: exprEncoder.encoder.output)
            }
        } else {
            encoder.encodeVector(functionIndices) { funcIndex, encoder in
                guard let funcIndex else { fatalError("null function reference in non-expression mode") }
                encoder.writeUnsignedLEB128(funcIndex)
            }
        }
    }
}

extension String: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        encoder.writeUnsignedLEB128(UInt32(utf8.count))
        encoder.output.append(contentsOf: utf8)
    }
}

extension Export: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        encoder.encode(name)
        switch descriptor {
        case .function(let index):
            encoder.output.append(0x00)
            encoder.writeUnsignedLEB128(UInt32(index))
        case .table(let index):
            encoder.output.append(0x01)
            encoder.writeUnsignedLEB128(UInt32(index))
        case .memory(let index):
            encoder.output.append(0x02)
            encoder.writeUnsignedLEB128(UInt32(index))
        case .global(let index):
            encoder.output.append(0x03)
            encoder.writeUnsignedLEB128(UInt32(index))
        }
    }
}

extension WatParser.GlobalDecl {
    func encode(to encoder: inout Encoder, watModule: inout WatModule) throws {
        encoder.encode(type)
        guard case var .definition(expr) = kind else {
            fatalError("imported global declaration should not be encoded here")
        }
        try encoder.writeExpression(lexer: &expr, watModule: &watModule)
    }
}

extension WatParser.MemoryDecl: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        encoder.encode(type)
    }
}

extension Limits: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        var flags = 0
        if max != nil {
            flags |= 0b0001
        }
        if shared {
            flags |= 0b0010
        }
        if isMemory64 {
            flags |= 0b0100
        }

        encoder.output.append(UInt8(flags))
        encoder.writeUnsignedLEB128(min)
        if let max = max {
            encoder.writeUnsignedLEB128(max)
        }
    }
}

extension GlobalType: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        encoder.encode(self.valueType)
        switch self.mutability {
        case .constant:
            encoder.output.append(0x00)
        case .variable:
            encoder.output.append(0x01)
        }
    }
}

extension Import: WasmEncodable {
    func encode(to encoder: inout Encoder) {
        encoder.encode(module)
        encoder.encode(name)
        switch descriptor {
        case .function(let typeIndex):
            encoder.output.append(0x00)
            encoder.writeUnsignedLEB128(UInt32(typeIndex))
        case .table(let tableType):
            encoder.output.append(0x01)
            tableType.encode(to: &encoder)
        case .memory(let memoryType):
            encoder.output.append(0x02)
            memoryType.encode(to: &encoder)
        case .global(let globalType):
            encoder.output.append(0x03)
            globalType.encode(to: &encoder)
        }
    }
}

extension WatParser.DataSegmentDecl.Offset {
    func encode(to encoder: inout Encoder, watModule: inout WatModule, isMemory64: Bool) throws {
        switch self {
        case .source(var offset):
            try encoder.writeExpression(lexer: &offset, watModule: &watModule)
        case .synthesized(let index):
            var exprEncoder = ExpressionEncoder()
            if isMemory64 {
                try exprEncoder.visitI64Const(value: Int64(index))
            } else {
                try exprEncoder.visitI32Const(value: Int32(index))
            }
            try exprEncoder.visitEnd()
            encoder.output.append(contentsOf: exprEncoder.encoder.output)
        }
    }
}

extension WatParser.DataSegmentDecl {
    func encode(to encoder: inout Encoder, watModule: inout WatModule) throws {
        func isMemory64(memoryIndex: Int) -> Bool {
            guard memoryIndex < watModule.memories.count else { return false }
            return watModule.memories[memoryIndex].type.isMemory64
        }
        switch (self.memory, self.offset) {
        case (nil, let offset?):
            // active with default memory
            encoder.output.append(0x00)
            try offset.encode(to: &encoder, watModule: &watModule, isMemory64: isMemory64(memoryIndex: 0))
        case (nil, nil):
            // passive
            encoder.output.append(0x01)
        case (let memory?, let offset?):
            let memoryIndex = try watModule.memories.resolve(use: memory).index
            if memoryIndex == 0 {
                // active with default memory
                encoder.output.append(0x00)
            } else {
                // active with explicit memory index
                encoder.output.append(0x02)
                encoder.writeUnsignedLEB128(UInt32(memoryIndex))
            }
            try offset.encode(to: &encoder, watModule: &watModule, isMemory64: isMemory64(memoryIndex: memoryIndex))
        case (_?, nil):
            fatalError("memory with memory index but no offset")
        }
        encoder.encodeByteVector(data)
    }
}

struct ExpressionEncoder: InstructionEncoder {
    var encoder = Encoder()
    var hasDataSegmentInstruction: Bool = false

    mutating func encodeUnsigned<T: UnsignedInteger & FixedWidthInteger>(_ value: T) {
        encoder.writeUnsignedLEB128(value)
    }
    mutating func encodeSigned<T: SignedInteger & FixedWidthInteger>(_ value: T) {
        encoder.writeSignedLEB128(value)
    }
    mutating func encodeByte(_ value: UInt8) {
        encoder.output.append(value)
    }
    mutating func encodeFixedWidth<T: FixedWidthInteger>(_ value: T) {
        let value = value.littleEndian
        withUnsafeBytes(of: value) { bytes in
            encoder.output.append(contentsOf: bytes)
        }
    }

    // MARK: Special instructions
    mutating func visitMemoryInit(dataIndex: UInt32) throws {
        try encodeInstruction(0x08, 0xFC)
        try encodeImmediates(dataIndex: dataIndex)
        encodeByte(0x00)  // reserved value
    }

    mutating func visitTypedSelect(type: ValueType) throws {
        try encodeInstruction(0x1C, nil)
        encodeByte(0x01)  // number of result types
        try encodeImmediates(type: type)
    }

    // MARK: InstructionEncoder conformance

    mutating func encodeInstruction(_ opcode: UInt8, _ prefix: UInt8?) throws {
        if let prefix {
            encoder.output.append(prefix)
        }
        encoder.output.append(opcode)
    }
    mutating func encodeImmediates(blockType: WasmParser.BlockType) throws {
        switch blockType {
        case .empty: encoder.output.append(0x40)
        case .type(let valueType): encoder.encode(valueType)
        case .funcType(let typeIndex):
            encoder.writeSignedLEB128(Int64(typeIndex))
        }
    }
    mutating func encodeImmediates(dataIndex: UInt32) throws {
        hasDataSegmentInstruction = true
        encodeUnsigned(dataIndex)
    }
    mutating func encodeImmediates(elemIndex: UInt32) throws { encodeUnsigned(elemIndex) }
    mutating func encodeImmediates(functionIndex: UInt32) throws { encodeUnsigned(functionIndex) }
    mutating func encodeImmediates(globalIndex: UInt32) throws { encodeUnsigned(globalIndex) }
    mutating func encodeImmediates(localIndex: UInt32) throws { encodeUnsigned(localIndex) }
    mutating func encodeImmediates(memarg: WasmParser.MemArg) throws {
        encodeUnsigned(UInt(memarg.align.trailingZeroBitCount))
        encodeUnsigned(memarg.offset)
    }
    mutating func encodeImmediates(memory: UInt32) throws { encodeUnsigned(memory) }
    mutating func encodeImmediates(relativeDepth: UInt32) throws { encodeUnsigned(relativeDepth) }
    mutating func encodeImmediates(table: UInt32) throws { encodeUnsigned(table) }
    mutating func encodeImmediates(targets: WasmParser.BrTable) throws {
        encoder.encodeVector(targets.labelIndices) { value, encoder in
            encoder.writeUnsignedLEB128(value)
        }
        encodeUnsigned(targets.defaultIndex)
    }
    mutating func encodeImmediates(type: WasmTypes.ValueType) throws { encoder.encode(type) }
    mutating func encodeImmediates(type: WasmTypes.ReferenceType) throws { encoder.encode(type) }
    mutating func encodeImmediates(value: Int32) throws { encodeSigned(value) }
    mutating func encodeImmediates(value: Int64) throws { encodeSigned(value) }
    mutating func encodeImmediates(value: WasmParser.IEEE754.Float32) throws { encodeFixedWidth(value.bitPattern) }
    mutating func encodeImmediates(value: WasmParser.IEEE754.Float64) throws { encodeFixedWidth(value.bitPattern) }
    mutating func encodeImmediates(dstMem: UInt32, srcMem: UInt32) throws {
        encodeUnsigned(dstMem)
        encodeUnsigned(srcMem)
    }
    mutating func encodeImmediates(dstTable: UInt32, srcTable: UInt32) throws {
        encodeUnsigned(dstTable)
        encodeUnsigned(srcTable)
    }
    mutating func encodeImmediates(elemIndex: UInt32, table: UInt32) throws {
        encodeUnsigned(elemIndex)
        encodeUnsigned(table)
    }
    mutating func encodeImmediates(typeIndex: UInt32, tableIndex: UInt32) throws {
        encodeUnsigned(typeIndex)
        encodeUnsigned(tableIndex)
    }
}

func encode(module: inout WatModule) throws -> [UInt8] {
    var encoder = Encoder()
    encoder.writeHeader()

    var codeEncoder = Encoder()
    let functions = module.functionsMap.compactMap { (function: WatParser.FunctionDecl) -> ([WatParser.LocalDecl], WatParser.FunctionDecl)? in
        guard case let .definition(locals, _) = function.kind else {
            return nil
        }
        return (locals, function)
    }
    var functionSection: [UInt32] = []
    var hasDataSegmentInstruction = false

    if !functions.isEmpty {
        try codeEncoder.section(id: 0x0A) { encoder in
            try encoder.encodeVector(
                functions,
                encodeElement: { source, encoder in
                    let (locals, function) = source
                    var exprEncoder = ExpressionEncoder()
                    // Encode locals
                    var localsEntries: [(type: ValueType, count: UInt32)] = []
                    for local in locals {
                        if localsEntries.last?.type == local.type {
                            localsEntries[localsEntries.count - 1].count += 1
                        } else {
                            localsEntries.append((type: local.type, count: 1))
                        }
                    }
                    exprEncoder.encoder.encodeVector(localsEntries) { local, encoder in
                        encoder.writeUnsignedLEB128(local.count)
                        local.type.encode(to: &encoder)
                    }
                    let funcTypeIndex = try function.parse(visitor: &exprEncoder, watModule: &module)
                    functionSection.append(UInt32(funcTypeIndex))
                    // TODO?
                    try exprEncoder.visitEnd()
                    encoder.writeUnsignedLEB128(UInt(exprEncoder.encoder.output.count))
                    encoder.output.append(contentsOf: exprEncoder.encoder.output)
                    hasDataSegmentInstruction = hasDataSegmentInstruction || exprEncoder.hasDataSegmentInstruction
                })
        }
    }

    // Section 1: Type section
    if !module.types.isEmpty {
        encoder.section(id: 0x01) { encoder in
            encoder.encodeVector(module.types, transform: \.type.signature)
        }
    }

    // Section 2: Import section
    if !module.imports.isEmpty {
        encoder.section(id: 0x02) { encoder in
            encoder.encodeVector(module.imports)
        }
    }

    // Section 3: Function section
    if !functionSection.isEmpty {
        encoder.section(id: 0x03) { encoder in
            encoder.encodeVector(functionSection) { typeIndex, encoder in
                encoder.writeUnsignedLEB128(UInt32(typeIndex))
            }
        }
    }

    // Section 4: Table section
    let tables = module.tablesMap.definitions()
    if !tables.isEmpty {
        encoder.section(id: 0x04) { encoder in
            encoder.encodeVector(tables) { table, encoder in
                table.type.encode(to: &encoder)
            }
        }
    }

    // Section 5: Memory section
    let memories = module.memories.definitions()
    if !memories.isEmpty {
        encoder.section(id: 0x05) { encoder in
            encoder.encodeVector(memories)
        }
    }

    // Section 6: Global section
    let globals = module.globals.definitions()
    if !globals.isEmpty {
        try encoder.section(id: 0x06) { encoder in
            try encoder.encodeVector(globals) { global, encoder in
                try global.encode(to: &encoder, watModule: &module)
            }
        }
    }

    // Section 7: Export section
    if !module.exports.isEmpty {
        encoder.section(id: 0x07) { encoder in
            encoder.encodeVector(module.exports) { export, encoder in
                export.encode(to: &encoder)
            }
        }
    }

    // Section 8: Start section
    if let start = module.start {
        encoder.section(id: 0x08) { encoder in
            encoder.writeUnsignedLEB128(start)
        }
    }

    // Section 9: Element section
    if !module.elementsMap.isEmpty {
        try encoder.section(id: 0x09) { encoder in
            try encoder.encodeVector(module.elementsMap) {
                try $0.encode(to: &$1, watModule: &module)
            }
        }
    }

    // Section 12: DataCount section
    if !module.data.isEmpty, hasDataSegmentInstruction {
        encoder.section(id: 0x0C) { encoder in
            encoder.writeUnsignedLEB128(UInt32(module.data.count))
        }
    }

    // Section 10: Code section
    encoder.output.append(contentsOf: codeEncoder.output)

    // Section 11: Data section
    if !module.data.isEmpty {
        try encoder.section(id: 0x0B) { encoder in
            try encoder.encodeVector(module.data) { data, encoder in
                try data.encode(to: &encoder, watModule: &module)
            }
        }
    }

    return encoder.output
}
