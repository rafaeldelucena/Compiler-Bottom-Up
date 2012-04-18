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
    
    General Purpose x86_32 Instructions
      MOVL %DEST %SRC - Move Longword
=end

class Compiler
  
  def initialize
    @string_constants = {}
    @id = 0
  end

  def get_arg(anArgument)
    id = @string_constants[anArgument]
    return id if id #if string_constants[anArgument].not_exists then id.nil
    id = @id
    @id += 1
    @string_constants[anArgument] = id #create key/value (id/anArgument) pairs on string_constants hash
  end
  
  def output_constants
    puts "\t.section\t.rodata"
    @string_constants.each do |value, key|
      puts ".LC#{key}:"
      puts "\t.string \"#{value}\""
    end
  end

  def header
    puts "\t.text"
    puts "\t.globl main"
    puts "\t.type	main, @function"
    puts "main:"
    puts ".LFB0:"
    puts"\t.cfi_startproc"
  end
  
  def save_context
    puts "\tpushq %rbp"
  end
  
  def restore_context
    puts "\tpopq %rbp"
  end
  
  def prolog
    puts "\t.cfi_def_cfa_offset 16"
    puts "\t.cfi_offset 6, -16"
    puts "\tmovq	%rsp, %rbp"
  end

  def epilog
    puts "\t.cfi_def_cfa 7, 8"
    puts "\tret"
    puts "\t.cfi_endproc"
  end
  
  def global_epilog
    puts ".LFE0:"
    puts "\t.size	main, .-main"
    puts "\t.ident	\"Compiler 0.1\""
    puts "\t.section	.note.GNU-stack,\"\",@progbits"
  end

  def compile(anExp)
    call = anExp[0].to_s
    args = anExp[1..-1].collect {|arg| get_arg(arg)}

    output_constants
    header
    save_context
    prolog
    puts "\t.cfi_def_cfa_register 6"
    args.each do |arg|
      puts "\tmovl\t$.LC#{arg}, %edi"
    end
    puts "\tcall\t#{call}"
    restore_context
    epilog
    global_epilog
  end
end

aProg = [:puts, "Hello World"]

Compiler.new.compile(aProg)
