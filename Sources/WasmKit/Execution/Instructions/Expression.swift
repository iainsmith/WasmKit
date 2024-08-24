import WasmParser

struct InstructionSequence: Equatable {
    let instructions: UnsafeMutableBufferPointer<Instruction>
    /// The maximum height of the value stack during execution of this function.
    /// This height does not count the locals.
    let maxStackHeight: Int

    init(instructions: UnsafeMutableBufferPointer<Instruction>, maxStackHeight: Int) {
        self.instructions = instructions
        assert(self.instructions.last?.isReturn ?? false)
        self.maxStackHeight = maxStackHeight
    }

    var baseAddress: UnsafeMutablePointer<Instruction> {
        self.instructions.baseAddress!
    }

    static func == (lhs: InstructionSequence, rhs: InstructionSequence) -> Bool {
        lhs.instructions.baseAddress == rhs.instructions.baseAddress
    }
}

extension Collection where Element == Instruction {
    func write<Target>(to target: inout Target, context: inout InstructionPrintingContext) where Target : TextOutputStream {
        var hexOffsetWidth = String(self.count - 1, radix: 16).count
        hexOffsetWidth = (hexOffsetWidth + 1) & ~1
        for (index, instruction) in self.enumerated() {
            var hexOffset = String(index, radix: 16)
            while hexOffset.count < hexOffsetWidth {
                hexOffset = "0" + hexOffset
            }
            target.write("0x\(hexOffset): ")
            context.print(instruction: instruction, to: &target)
            target.write("\n")
        }
    }
}

extension Instruction {
    fileprivate var isReturn: Bool {
        if case .return = self {
            return true
        }
        return false
    }
}
