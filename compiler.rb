#!/usr/bin/ruby

=begin Comments
  Simplicity over performance every time.
  .cfi_startproc Use at the beginning of each function. It initializes some internal data structures and emits initial CFI instructions.
  .cfi_endproc Opens .eh_frame, generates appropriate binary structures (CIE, FDE) and sets up relocation records.
    
    %ESP - Stack Pointer Register
    
    General Purpose x86_64 Registers
    %RAX - registrador valor de retorno
    %RBX - registrador base
    %RCX - registrador contador
    %RDX - registrador de dados
    %RSI - registrador de índice da fonte dos dados
    %RDI - registrador de índice do destino dos dados
    %RBP - registrador ponteiro para a moldura de chamada de função
    %RSP - registrador ponteiro para a pilha de execução
    %R8 - registrador de dados
    %R9 - registrador de dados
    %R10 - registrador ponteiro para a moldura de chamada de função
    %R11 - registrador de linking
    %R12 - registrador de base
    %R13 - registrador de base
    %R14 - registrador de base
    %R15 - registrador de base
=end

class Compiler
  @string_constants = {}
  
  def header(aTitle)
    puts <<HEADER
    .file \"#{aTitle}.rb\"
    .text
    .global main
    .type	main, @function
main:
 .LFB0:
    .cfi_startproc
HEADER
  end
  
  def save_context
    puts <<SAVE_CONTEXT
    pushq %rbp
SAVE_CONTEXT
  end
  
  def restore_context
    puts <<RESTORE_CONTEXT
    popq %rbp
RESTORE_CONTEXT
  end
  
  def ret
    "ret
    .cfi_endproc"
  end
  
  def compile(anExp)
    header(anExp[0])
    save_context
    puts <<PROLOG
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    movq	%rsp, %rbp
    .cfi_def_cfa_register 6
PROLOG
    restore_context
    puts <<EPILOG
    .cfi_def_cfa 7, 8
EPILOG
puts <<GLOBAL_EPILOG
 .LFE0:
    .size	main, .-main
    .ident	"Compiler 0.1"
    .section	.note.GNU-stack,"",@progbits
GLOBAL_EPILOG
  end
end

aProg = [:puts, "Hello World"]

Compiler.new.compile(aProg)
