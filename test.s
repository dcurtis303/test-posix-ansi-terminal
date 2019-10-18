/*****************************************************************************/
    .data
code_clrscrn:
    .asciz      "\033[2J"
    .balign     8
code_pos:
    .asciz      "\033[000;000H"
    .balign     8

test_str:
    .asciz      "Test\n"

cursor_position:
    .byte       215
    .byte       20

timespec:
tv_sec:
    .quad       0
tv_nsec:
    .quad       0      

    .balign     16
dummy:
    .fill       16, 1, 0


/*****************************************************************************/
    .text
    .global _start

/*****************************************************************************/
_start:
    # clear screen
    mov     $code_clrscrn,%rax
    callq   writestr

    # set cursor position
    callq   setpos


    mov     $test_str,%rax
    callq   writestr

    jmp     exit


/*****************************************************************************/
setpos:
    movq    $cursor_position,%rsi
    movq    $code_pos+4,%rdi 
    callq   hex_to_ascii

    inc     %rsi
    movq    $code_pos+8,%rdi 
    callq   hex_to_ascii

    mov     $code_pos,%rax
    callq   writestr

    retq


/*****************************************************************************/
hex_to_ascii:
    xor     %rax,%rax
    movb    (%rsi),%al
    mov     $10,%bx
hex_to_ascii_more:
    xor     %rdx,%rdx
    div     %bx
    add     $0x30,%dl

    movb    %dl,(%rdi)
    dec     %rdi

    cmp     $0,%al
    jg      hex_to_ascii_more

    add     $0x30,%dl
    movb    %dl,(%rdi)

    retq



/*****************************************************************************/
writestr:
    push    %rax
    callq   getstrlen

    movq    %rax,%rdx
    pop     %rsi
    movq    $1,%rax
    movq    $1,%rdi
    syscall

    ret


/*****************************************************************************/
getstrlen:
    movq    %rax,%rbx
    xor     %rax,%rax
    xor     %rcx,%rcx
getstrlen_cmp:
    cmpb    (%rbx,%rcx,1),%al
    je      getstrlen_ret
    inc     %rcx
    jmp     getstrlen_cmp

getstrlen_ret:
    movq    %rcx,%rax
    ret


/*****************************************************************************/
nsleep:
    movq    $35,%rax
    movq    $0,(tv_sec)
    movq    $33000,(tv_nsec)
    movq    $timespec,%rdi
    xor     %rsi,%rsi
    syscall
    ret


/*****************************************************************************/
exit:
    movq    $60,%rax
    movq    $0,%rdi
    syscall
