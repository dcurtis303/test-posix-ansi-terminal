/*****************************************************************************/
    .data
code_clrscrn:
    .asciz      "\033[2J"
    .balign     16
code_pos:
    .asciz      "\033[000;000H"
    .balign     16

test_str:
    .asciz      "Test\n"

cursor_position:
    .byte       1
    .byte       39

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

_start_l1:
    # set cursor position
    callq   setpos

    # write test string
    mov     $test_str,%rax
    callq   writestr

    callq   nsleep

    # change position and loop
    movb    (cursor_position),%al
    inc     %al
    cmp     $25,%al
    jge      exit
    mov     %al,(cursor_position)
    jmp     _start_l1


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
    jz      hex_to_ascii_done
    
    add     $0x30,%dl
    movb    %dl,(%rdi)
    dec     %rdi

    cmp     $0,%al
    jg      hex_to_ascii_more

hex_to_ascii_done:
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
    cmpb    $0,(%rbx,%rcx,1) #%al
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
    movq    $330000000,(tv_nsec)
    movq    $timespec,%rdi
    xor     %rsi,%rsi
    syscall
    ret


/*****************************************************************************/
exit:
    movq    $60,%rax
    movq    $0,%rdi
    syscall
