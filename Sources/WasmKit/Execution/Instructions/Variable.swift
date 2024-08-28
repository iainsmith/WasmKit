/// > Note:
/// <https://webassembly.github.io/spec/core/syntax/instructions.html#variable-instructions>
extension ExecutionState {
    mutating func globalGet(sp: Sp, pc: Pc, globalGetOperand: Instruction.GlobalGetOperand) throws -> Pc {
        var pc = pc
        let global = pc.read(InternalGlobal.self)
        global.withValue{
            sp[globalGetOperand.result] = $0.rawValue
        }
        return pc
    }
    mutating func globalSet(sp: Sp, pc: Pc, globalSetOperand: Instruction.GlobalSetOperand) throws -> Pc {
        var pc = pc
        let global = pc.read(InternalGlobal.self)
        let value = sp[globalSetOperand.value]
        global.withValue{ $0.rawValue = value }
        return pc
    }

    mutating func copyStack(sp: Sp, copyStackOperand: Instruction.CopyStackOperand) {
        sp[copyStackOperand.dest] = sp[copyStackOperand.source]
    }
}
