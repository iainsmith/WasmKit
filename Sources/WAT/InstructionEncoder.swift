// swift-format-ignore-file
//// Automatically generated by Utilities/Sources/WasmGen.swift
//// DO NOT EDIT DIRECTLY

import WasmParser
import WasmTypes

/// An instruction encoder that is responsible for encoding opcodes and immediates.
protocol InstructionEncoder: InstructionVisitor {
    /// Encodes an instruction opcode.
    mutating func encodeInstruction(_ opcode: UInt8, _ prefix: UInt8?) throws

    // MARK: - Immediates encoding
    mutating func encodeImmediates(blockType: BlockType) throws
    mutating func encodeImmediates(dataIndex: UInt32) throws
    mutating func encodeImmediates(elemIndex: UInt32) throws
    mutating func encodeImmediates(functionIndex: UInt32) throws
    mutating func encodeImmediates(globalIndex: UInt32) throws
    mutating func encodeImmediates(localIndex: UInt32) throws
    mutating func encodeImmediates(memarg: MemArg) throws
    mutating func encodeImmediates(memory: UInt32) throws
    mutating func encodeImmediates(relativeDepth: UInt32) throws
    mutating func encodeImmediates(table: UInt32) throws
    mutating func encodeImmediates(targets: BrTable) throws
    mutating func encodeImmediates(type: ReferenceType) throws
    mutating func encodeImmediates(type: ValueType) throws
    mutating func encodeImmediates(value: IEEE754.Float32) throws
    mutating func encodeImmediates(value: IEEE754.Float64) throws
    mutating func encodeImmediates(value: Int32) throws
    mutating func encodeImmediates(value: Int64) throws
    mutating func encodeImmediates(dstMem: UInt32, srcMem: UInt32) throws
    mutating func encodeImmediates(dstTable: UInt32, srcTable: UInt32) throws
    mutating func encodeImmediates(elemIndex: UInt32, table: UInt32) throws
    mutating func encodeImmediates(typeIndex: UInt32, tableIndex: UInt32) throws
}

// InstructionEncoder implements the InstructionVisitor protocol to call the corresponding encode method.
extension InstructionEncoder {
    mutating func visitUnreachable() throws { try encodeInstruction(0x00, nil) }
    mutating func visitNop() throws { try encodeInstruction(0x01, nil) }
    mutating func visitBlock(blockType: BlockType) throws {
        try encodeInstruction(0x02, nil)
        try encodeImmediates(blockType: blockType)
    }
    mutating func visitLoop(blockType: BlockType) throws {
        try encodeInstruction(0x03, nil)
        try encodeImmediates(blockType: blockType)
    }
    mutating func visitIf(blockType: BlockType) throws {
        try encodeInstruction(0x04, nil)
        try encodeImmediates(blockType: blockType)
    }
    mutating func visitElse() throws { try encodeInstruction(0x05, nil) }
    mutating func visitEnd() throws { try encodeInstruction(0x0B, nil) }
    mutating func visitBr(relativeDepth: UInt32) throws {
        try encodeInstruction(0x0C, nil)
        try encodeImmediates(relativeDepth: relativeDepth)
    }
    mutating func visitBrIf(relativeDepth: UInt32) throws {
        try encodeInstruction(0x0D, nil)
        try encodeImmediates(relativeDepth: relativeDepth)
    }
    mutating func visitBrTable(targets: BrTable) throws {
        try encodeInstruction(0x0E, nil)
        try encodeImmediates(targets: targets)
    }
    mutating func visitReturn() throws { try encodeInstruction(0x0F, nil) }
    mutating func visitCall(functionIndex: UInt32) throws {
        try encodeInstruction(0x10, nil)
        try encodeImmediates(functionIndex: functionIndex)
    }
    mutating func visitCallIndirect(typeIndex: UInt32, tableIndex: UInt32) throws {
        try encodeInstruction(0x11, nil)
        try encodeImmediates(typeIndex: typeIndex, tableIndex: tableIndex)
    }
    mutating func visitDrop() throws { try encodeInstruction(0x1A, nil) }
    mutating func visitSelect() throws { try encodeInstruction(0x1B, nil) }
    mutating func visitTypedSelect(type: ValueType) throws {
        try encodeInstruction(0x1C, nil)
        try encodeImmediates(type: type)
    }
    mutating func visitLocalGet(localIndex: UInt32) throws {
        try encodeInstruction(0x20, nil)
        try encodeImmediates(localIndex: localIndex)
    }
    mutating func visitLocalSet(localIndex: UInt32) throws {
        try encodeInstruction(0x21, nil)
        try encodeImmediates(localIndex: localIndex)
    }
    mutating func visitLocalTee(localIndex: UInt32) throws {
        try encodeInstruction(0x22, nil)
        try encodeImmediates(localIndex: localIndex)
    }
    mutating func visitGlobalGet(globalIndex: UInt32) throws {
        try encodeInstruction(0x23, nil)
        try encodeImmediates(globalIndex: globalIndex)
    }
    mutating func visitGlobalSet(globalIndex: UInt32) throws {
        try encodeInstruction(0x24, nil)
        try encodeImmediates(globalIndex: globalIndex)
    }
    mutating func visitI32Load(memarg: MemArg) throws {
        try encodeInstruction(0x28, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load(memarg: MemArg) throws {
        try encodeInstruction(0x29, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitF32Load(memarg: MemArg) throws {
        try encodeInstruction(0x2A, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitF64Load(memarg: MemArg) throws {
        try encodeInstruction(0x2B, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Load8S(memarg: MemArg) throws {
        try encodeInstruction(0x2C, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Load8U(memarg: MemArg) throws {
        try encodeInstruction(0x2D, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Load16S(memarg: MemArg) throws {
        try encodeInstruction(0x2E, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Load16U(memarg: MemArg) throws {
        try encodeInstruction(0x2F, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load8S(memarg: MemArg) throws {
        try encodeInstruction(0x30, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load8U(memarg: MemArg) throws {
        try encodeInstruction(0x31, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load16S(memarg: MemArg) throws {
        try encodeInstruction(0x32, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load16U(memarg: MemArg) throws {
        try encodeInstruction(0x33, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load32S(memarg: MemArg) throws {
        try encodeInstruction(0x34, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Load32U(memarg: MemArg) throws {
        try encodeInstruction(0x35, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Store(memarg: MemArg) throws {
        try encodeInstruction(0x36, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Store(memarg: MemArg) throws {
        try encodeInstruction(0x37, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitF32Store(memarg: MemArg) throws {
        try encodeInstruction(0x38, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitF64Store(memarg: MemArg) throws {
        try encodeInstruction(0x39, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Store8(memarg: MemArg) throws {
        try encodeInstruction(0x3A, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI32Store16(memarg: MemArg) throws {
        try encodeInstruction(0x3B, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Store8(memarg: MemArg) throws {
        try encodeInstruction(0x3C, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Store16(memarg: MemArg) throws {
        try encodeInstruction(0x3D, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitI64Store32(memarg: MemArg) throws {
        try encodeInstruction(0x3E, nil)
        try encodeImmediates(memarg: memarg)
    }
    mutating func visitMemorySize(memory: UInt32) throws {
        try encodeInstruction(0x3F, nil)
        try encodeImmediates(memory: memory)
    }
    mutating func visitMemoryGrow(memory: UInt32) throws {
        try encodeInstruction(0x40, nil)
        try encodeImmediates(memory: memory)
    }
    mutating func visitI32Const(value: Int32) throws {
        try encodeInstruction(0x41, nil)
        try encodeImmediates(value: value)
    }
    mutating func visitI64Const(value: Int64) throws {
        try encodeInstruction(0x42, nil)
        try encodeImmediates(value: value)
    }
    mutating func visitF32Const(value: IEEE754.Float32) throws {
        try encodeInstruction(0x43, nil)
        try encodeImmediates(value: value)
    }
    mutating func visitF64Const(value: IEEE754.Float64) throws {
        try encodeInstruction(0x44, nil)
        try encodeImmediates(value: value)
    }
    mutating func visitRefNull(type: ReferenceType) throws {
        try encodeInstruction(0xD0, nil)
        try encodeImmediates(type: type)
    }
    mutating func visitRefIsNull() throws { try encodeInstruction(0xD1, nil) }
    mutating func visitRefFunc(functionIndex: UInt32) throws {
        try encodeInstruction(0xD2, nil)
        try encodeImmediates(functionIndex: functionIndex)
    }
    mutating func visitI32Eqz() throws { try encodeInstruction(0x45, nil) }
    mutating func visitI32Eq() throws { try encodeInstruction(0x46, nil) }
    mutating func visitI32Ne() throws { try encodeInstruction(0x47, nil) }
    mutating func visitI32LtS() throws { try encodeInstruction(0x48, nil) }
    mutating func visitI32LtU() throws { try encodeInstruction(0x49, nil) }
    mutating func visitI32GtS() throws { try encodeInstruction(0x4A, nil) }
    mutating func visitI32GtU() throws { try encodeInstruction(0x4B, nil) }
    mutating func visitI32LeS() throws { try encodeInstruction(0x4C, nil) }
    mutating func visitI32LeU() throws { try encodeInstruction(0x4D, nil) }
    mutating func visitI32GeS() throws { try encodeInstruction(0x4E, nil) }
    mutating func visitI32GeU() throws { try encodeInstruction(0x4F, nil) }
    mutating func visitI64Eqz() throws { try encodeInstruction(0x50, nil) }
    mutating func visitI64Eq() throws { try encodeInstruction(0x51, nil) }
    mutating func visitI64Ne() throws { try encodeInstruction(0x52, nil) }
    mutating func visitI64LtS() throws { try encodeInstruction(0x53, nil) }
    mutating func visitI64LtU() throws { try encodeInstruction(0x54, nil) }
    mutating func visitI64GtS() throws { try encodeInstruction(0x55, nil) }
    mutating func visitI64GtU() throws { try encodeInstruction(0x56, nil) }
    mutating func visitI64LeS() throws { try encodeInstruction(0x57, nil) }
    mutating func visitI64LeU() throws { try encodeInstruction(0x58, nil) }
    mutating func visitI64GeS() throws { try encodeInstruction(0x59, nil) }
    mutating func visitI64GeU() throws { try encodeInstruction(0x5A, nil) }
    mutating func visitF32Eq() throws { try encodeInstruction(0x5B, nil) }
    mutating func visitF32Ne() throws { try encodeInstruction(0x5C, nil) }
    mutating func visitF32Lt() throws { try encodeInstruction(0x5D, nil) }
    mutating func visitF32Gt() throws { try encodeInstruction(0x5E, nil) }
    mutating func visitF32Le() throws { try encodeInstruction(0x5F, nil) }
    mutating func visitF32Ge() throws { try encodeInstruction(0x60, nil) }
    mutating func visitF64Eq() throws { try encodeInstruction(0x61, nil) }
    mutating func visitF64Ne() throws { try encodeInstruction(0x62, nil) }
    mutating func visitF64Lt() throws { try encodeInstruction(0x63, nil) }
    mutating func visitF64Gt() throws { try encodeInstruction(0x64, nil) }
    mutating func visitF64Le() throws { try encodeInstruction(0x65, nil) }
    mutating func visitF64Ge() throws { try encodeInstruction(0x66, nil) }
    mutating func visitI32Clz() throws { try encodeInstruction(0x67, nil) }
    mutating func visitI32Ctz() throws { try encodeInstruction(0x68, nil) }
    mutating func visitI32Popcnt() throws { try encodeInstruction(0x69, nil) }
    mutating func visitI32Add() throws { try encodeInstruction(0x6A, nil) }
    mutating func visitI32Sub() throws { try encodeInstruction(0x6B, nil) }
    mutating func visitI32Mul() throws { try encodeInstruction(0x6C, nil) }
    mutating func visitI32DivS() throws { try encodeInstruction(0x6D, nil) }
    mutating func visitI32DivU() throws { try encodeInstruction(0x6E, nil) }
    mutating func visitI32RemS() throws { try encodeInstruction(0x6F, nil) }
    mutating func visitI32RemU() throws { try encodeInstruction(0x70, nil) }
    mutating func visitI32And() throws { try encodeInstruction(0x71, nil) }
    mutating func visitI32Or() throws { try encodeInstruction(0x72, nil) }
    mutating func visitI32Xor() throws { try encodeInstruction(0x73, nil) }
    mutating func visitI32Shl() throws { try encodeInstruction(0x74, nil) }
    mutating func visitI32ShrS() throws { try encodeInstruction(0x75, nil) }
    mutating func visitI32ShrU() throws { try encodeInstruction(0x76, nil) }
    mutating func visitI32Rotl() throws { try encodeInstruction(0x77, nil) }
    mutating func visitI32Rotr() throws { try encodeInstruction(0x78, nil) }
    mutating func visitI64Clz() throws { try encodeInstruction(0x79, nil) }
    mutating func visitI64Ctz() throws { try encodeInstruction(0x7A, nil) }
    mutating func visitI64Popcnt() throws { try encodeInstruction(0x7B, nil) }
    mutating func visitI64Add() throws { try encodeInstruction(0x7C, nil) }
    mutating func visitI64Sub() throws { try encodeInstruction(0x7D, nil) }
    mutating func visitI64Mul() throws { try encodeInstruction(0x7E, nil) }
    mutating func visitI64DivS() throws { try encodeInstruction(0x7F, nil) }
    mutating func visitI64DivU() throws { try encodeInstruction(0x80, nil) }
    mutating func visitI64RemS() throws { try encodeInstruction(0x81, nil) }
    mutating func visitI64RemU() throws { try encodeInstruction(0x82, nil) }
    mutating func visitI64And() throws { try encodeInstruction(0x83, nil) }
    mutating func visitI64Or() throws { try encodeInstruction(0x84, nil) }
    mutating func visitI64Xor() throws { try encodeInstruction(0x85, nil) }
    mutating func visitI64Shl() throws { try encodeInstruction(0x86, nil) }
    mutating func visitI64ShrS() throws { try encodeInstruction(0x87, nil) }
    mutating func visitI64ShrU() throws { try encodeInstruction(0x88, nil) }
    mutating func visitI64Rotl() throws { try encodeInstruction(0x89, nil) }
    mutating func visitI64Rotr() throws { try encodeInstruction(0x8A, nil) }
    mutating func visitF32Abs() throws { try encodeInstruction(0x8B, nil) }
    mutating func visitF32Neg() throws { try encodeInstruction(0x8C, nil) }
    mutating func visitF32Ceil() throws { try encodeInstruction(0x8D, nil) }
    mutating func visitF32Floor() throws { try encodeInstruction(0x8E, nil) }
    mutating func visitF32Trunc() throws { try encodeInstruction(0x8F, nil) }
    mutating func visitF32Nearest() throws { try encodeInstruction(0x90, nil) }
    mutating func visitF32Sqrt() throws { try encodeInstruction(0x91, nil) }
    mutating func visitF32Add() throws { try encodeInstruction(0x92, nil) }
    mutating func visitF32Sub() throws { try encodeInstruction(0x93, nil) }
    mutating func visitF32Mul() throws { try encodeInstruction(0x94, nil) }
    mutating func visitF32Div() throws { try encodeInstruction(0x95, nil) }
    mutating func visitF32Min() throws { try encodeInstruction(0x96, nil) }
    mutating func visitF32Max() throws { try encodeInstruction(0x97, nil) }
    mutating func visitF32Copysign() throws { try encodeInstruction(0x98, nil) }
    mutating func visitF64Abs() throws { try encodeInstruction(0x99, nil) }
    mutating func visitF64Neg() throws { try encodeInstruction(0x9A, nil) }
    mutating func visitF64Ceil() throws { try encodeInstruction(0x9B, nil) }
    mutating func visitF64Floor() throws { try encodeInstruction(0x9C, nil) }
    mutating func visitF64Trunc() throws { try encodeInstruction(0x9D, nil) }
    mutating func visitF64Nearest() throws { try encodeInstruction(0x9E, nil) }
    mutating func visitF64Sqrt() throws { try encodeInstruction(0x9F, nil) }
    mutating func visitF64Add() throws { try encodeInstruction(0xA0, nil) }
    mutating func visitF64Sub() throws { try encodeInstruction(0xA1, nil) }
    mutating func visitF64Mul() throws { try encodeInstruction(0xA2, nil) }
    mutating func visitF64Div() throws { try encodeInstruction(0xA3, nil) }
    mutating func visitF64Min() throws { try encodeInstruction(0xA4, nil) }
    mutating func visitF64Max() throws { try encodeInstruction(0xA5, nil) }
    mutating func visitF64Copysign() throws { try encodeInstruction(0xA6, nil) }
    mutating func visitI32WrapI64() throws { try encodeInstruction(0xA7, nil) }
    mutating func visitI32TruncF32S() throws { try encodeInstruction(0xA8, nil) }
    mutating func visitI32TruncF32U() throws { try encodeInstruction(0xA9, nil) }
    mutating func visitI32TruncF64S() throws { try encodeInstruction(0xAA, nil) }
    mutating func visitI32TruncF64U() throws { try encodeInstruction(0xAB, nil) }
    mutating func visitI64ExtendI32S() throws { try encodeInstruction(0xAC, nil) }
    mutating func visitI64ExtendI32U() throws { try encodeInstruction(0xAD, nil) }
    mutating func visitI64TruncF32S() throws { try encodeInstruction(0xAE, nil) }
    mutating func visitI64TruncF32U() throws { try encodeInstruction(0xAF, nil) }
    mutating func visitI64TruncF64S() throws { try encodeInstruction(0xB0, nil) }
    mutating func visitI64TruncF64U() throws { try encodeInstruction(0xB1, nil) }
    mutating func visitF32ConvertI32S() throws { try encodeInstruction(0xB2, nil) }
    mutating func visitF32ConvertI32U() throws { try encodeInstruction(0xB3, nil) }
    mutating func visitF32ConvertI64S() throws { try encodeInstruction(0xB4, nil) }
    mutating func visitF32ConvertI64U() throws { try encodeInstruction(0xB5, nil) }
    mutating func visitF32DemoteF64() throws { try encodeInstruction(0xB6, nil) }
    mutating func visitF64ConvertI32S() throws { try encodeInstruction(0xB7, nil) }
    mutating func visitF64ConvertI32U() throws { try encodeInstruction(0xB8, nil) }
    mutating func visitF64ConvertI64S() throws { try encodeInstruction(0xB9, nil) }
    mutating func visitF64ConvertI64U() throws { try encodeInstruction(0xBA, nil) }
    mutating func visitF64PromoteF32() throws { try encodeInstruction(0xBB, nil) }
    mutating func visitI32ReinterpretF32() throws { try encodeInstruction(0xBC, nil) }
    mutating func visitI64ReinterpretF64() throws { try encodeInstruction(0xBD, nil) }
    mutating func visitF32ReinterpretI32() throws { try encodeInstruction(0xBE, nil) }
    mutating func visitF64ReinterpretI64() throws { try encodeInstruction(0xBF, nil) }
    mutating func visitI32Extend8S() throws { try encodeInstruction(0xC0, nil) }
    mutating func visitI32Extend16S() throws { try encodeInstruction(0xC1, nil) }
    mutating func visitI64Extend8S() throws { try encodeInstruction(0xC2, nil) }
    mutating func visitI64Extend16S() throws { try encodeInstruction(0xC3, nil) }
    mutating func visitI64Extend32S() throws { try encodeInstruction(0xC4, nil) }
    mutating func visitMemoryInit(dataIndex: UInt32) throws {
        try encodeInstruction(0x08, 0xFC)
        try encodeImmediates(dataIndex: dataIndex)
    }
    mutating func visitDataDrop(dataIndex: UInt32) throws {
        try encodeInstruction(0x09, 0xFC)
        try encodeImmediates(dataIndex: dataIndex)
    }
    mutating func visitMemoryCopy(dstMem: UInt32, srcMem: UInt32) throws {
        try encodeInstruction(0x0A, 0xFC)
        try encodeImmediates(dstMem: dstMem, srcMem: srcMem)
    }
    mutating func visitMemoryFill(memory: UInt32) throws {
        try encodeInstruction(0x0B, 0xFC)
        try encodeImmediates(memory: memory)
    }
    mutating func visitTableInit(elemIndex: UInt32, table: UInt32) throws {
        try encodeInstruction(0x0C, 0xFC)
        try encodeImmediates(elemIndex: elemIndex, table: table)
    }
    mutating func visitElemDrop(elemIndex: UInt32) throws {
        try encodeInstruction(0x0D, 0xFC)
        try encodeImmediates(elemIndex: elemIndex)
    }
    mutating func visitTableCopy(dstTable: UInt32, srcTable: UInt32) throws {
        try encodeInstruction(0x0E, 0xFC)
        try encodeImmediates(dstTable: dstTable, srcTable: srcTable)
    }
    mutating func visitTableFill(table: UInt32) throws {
        try encodeInstruction(0x11, 0xFC)
        try encodeImmediates(table: table)
    }
    mutating func visitTableGet(table: UInt32) throws {
        try encodeInstruction(0x25, nil)
        try encodeImmediates(table: table)
    }
    mutating func visitTableSet(table: UInt32) throws {
        try encodeInstruction(0x26, nil)
        try encodeImmediates(table: table)
    }
    mutating func visitTableGrow(table: UInt32) throws {
        try encodeInstruction(0x0F, 0xFC)
        try encodeImmediates(table: table)
    }
    mutating func visitTableSize(table: UInt32) throws {
        try encodeInstruction(0x10, 0xFC)
        try encodeImmediates(table: table)
    }
    mutating func visitI32TruncSatF32S() throws { try encodeInstruction(0x00, 0xFC) }
    mutating func visitI32TruncSatF32U() throws { try encodeInstruction(0x01, 0xFC) }
    mutating func visitI32TruncSatF64S() throws { try encodeInstruction(0x02, 0xFC) }
    mutating func visitI32TruncSatF64U() throws { try encodeInstruction(0x03, 0xFC) }
    mutating func visitI64TruncSatF32S() throws { try encodeInstruction(0x04, 0xFC) }
    mutating func visitI64TruncSatF32U() throws { try encodeInstruction(0x05, 0xFC) }
    mutating func visitI64TruncSatF64S() throws { try encodeInstruction(0x06, 0xFC) }
    mutating func visitI64TruncSatF64U() throws { try encodeInstruction(0x07, 0xFC) }
}
