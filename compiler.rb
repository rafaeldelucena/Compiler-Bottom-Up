#!/usr/bin/ruby

=begin Comments
 
  Simplicity over performance every time.
  
  .cfi_startproc Use at the beginning of each function. It initializes some internal data structures and emits initial CFI instructions.
  .cfi_endproc Opens .eh_frame, generates appropriate binary structures (CIE, FDE) and sets up relocation records.

  General Purpose x86_32 Registers
    %EAX - Accumulator for operands and results data
    %EBX - Pointer to data in the DS segment
    %ECX - Counter for string and loop operations
    %EDX - I/O pointer
    %ESI - Pointer to data in the segment pointed to by the DS register; source pointer for string operations
    %EDI - Pointer to data (or destination) in the segment pointed to by the ES register; destination pointer for string operations
    %ESP - Stack pointer (in the SS segment)
    %EBP - Pointer to data on the stack (in the SS segment)   

  General Purpose x86_64 Registers
    %RAX - registrador valor de retorno
    %RBX - registrador base
    %RCX - registrador contador
    %RDX - registrador de dados
    %RSI - registrador de índice da fonte dos dados
    %RDI - registrador de índice do destino dos dados
    %RBP - Frame Pointer Register
    %RSP - Stack Pointer Register
    %R8 - registrador de dados
    %R9 - registrador de dados
    %R10 - registrador ponteiro para a moldura de chamada de função
    %R11 - registrador de linking
    %R12 - registrador de base
    %R13 - registrador de base
    %R14 - registrador de base
    %R15 - registrador de base

    .session .rodata: this segment contains the "Hello World" string, which is tagged read-only.

    General Purpose x86_64 Instructions
      PUSHQ %REG - Push Quadword on Stack
      POPQ %REG - Pop Quadword on Stack
      MOVQ %DEST %SRC - Move Quadword
	  The LEAVE instruction copies the frame pointer (in the EBP register) into the stack pointer register (ESP), which releases the stack space allocated to the stack frame. The old frame pointer (the frame pointer for the calling procedure that was saved by the ENTER
instruction) is then popped from the stack into the EBP register, restoring the calling procedure’s stack frame. A RET instruction is commonly executed following a LEAVE instruction to return program control to the calling procedure.  
    General Purpose x86_32 Instructions
      MOVL %DEST %SRC - Move Longword
=end

class Compiler
  
  def initialize
    @string_constants = {}
	@arg_regs = ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
    @id = 0
  end

  def get_arg(anArgument)
  	if anArgument.is_a?(Array)
		compile_exp(anArgument)
		return [:subExp]
	end
    
	id = @string_constants[anArgument]
    return id if id #if string_constants[anArgument].not_exists then id.nil
    id = @id
    @id += 1
    @string_constants[anArgument] = id #create key/value (id/anArgument) pairs on string_constants hash
  	return [:strConst, id]
  end
  
  def output_constants
    puts "\t.section\t.rodata"
    @string_constants.each do |value, key|
      puts ".LC#{key}:"
      puts "\t.string \"#{value}\""
    end
  end

  def allocate_args(anArgs)
  	_args = anArgs
	stack_args = _args.slice!(@arg_regs.size..-1) if anArgs.size > @arg_regs.size
	if !stack_args.nil? then
	  offset = (stack_args.size)*8
	  puts "\tsubq \t$#{offset}, %rsp"
	  while !stack_args.empty?
		puts "\tmovq\t#{stack_args.shift}, #{offset -= 8}(%rsp)"
	  end
	end
    _args.each_with_index do |arg, i|
    	puts "\tmovq\t#{arg}, #{@arg_regs[i]}"
    end
  end

  def prolog
    output_constants
    puts "\t.text"
    puts "\t.globl \tmain"
    puts "\t.type	main, @function"
    puts "main:"
    puts ".LFB0:"
    puts"\t.cfi_startproc"
    puts "\tpushq \t%rbp"
    puts "\t.cfi_def_cfa_offset 16"
    puts "\t.cfi_offset 6, -16"
    puts "\tmovq	%rsp, %rbp"
    puts "\t.cfi_def_cfa_register 6"
  end
  
  def epilog
  	puts "\tleave" # Recupera o contexto da Stack
    puts "\t.cfi_def_cfa 7, 8"
    puts "\tret"
    puts "\t.cfi_endproc"
    puts ".LFE0:"
    puts "\t.size	main, .-main"
    puts "\t.ident	\"Compiler 0.1\""
    puts "\t.section	.note.GNU-stack,\"\",@progbits"
  end

  def compile_exp(anExp)
  	if anExp[0] == :do then
    	anExp[1..-1].each do |exp|
			compile_exp(exp)
		end
		return	
	end
		
	args = []
    call = anExp[0].to_s
	anExp[1..-1].each do |arg|
		aType, aParam = get_arg(arg)
		if anExp[0] != :do then
			if aType == :strConst
				args << "$.LC#{aParam}"
			else
				args << "%rax"
			end
		end
	end
	allocate_args(args)
    puts "\tcall\t#{call}"
  end
  
  def compile(anExp)
    prolog
	compile_exp(anExp)
    epilog
  end
end
aProg = [:puts, "Hello", "World", "!!"]
=begin
aProg = [:do,
	[:puts, "Chainning"], 
	[:printf, "Expressions", ","],
	[:puts, "with"],
	[:puts, "do", "!!"],
]	
=end

#aProg = [:puts, "Adding sub-%ld",[:printf, "expressions"]]
Compiler.new.compile(aProg)
