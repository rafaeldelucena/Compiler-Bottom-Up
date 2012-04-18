#!/usr/bin/ruby

class Compiler
  def compile(anExp)
    puts <<PROLOG
      .file	"bootstrap.c"
	    .text
      .globl	main
	    .type	main, @function
      main:
      .LFB0:
	    .cfi_startproc
	    pushq	%rbp
	    .cfi_def_cfa_offset 16
	    .cfi_offset 6, -16
	    movq	%rsp, %rbp
	    .cfi_def_cfa_register 6
PROLOG
    puts <<EPILOG
      popq	%rbp
	    .cfi_def_cfa 7, 8
	    ret
	    .cfi_endproc
EPILOG
    puts <<GLOBAL_EPILOG
    .LFE0:
	  .size	main, .-main
	  .ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	  .section	.note.GNU-stack,"",@progbits

GLOBAL_EPILOG
  end
end

aProg = [:puts,"Hello World"]

Compiler.new.compile(aProg)
