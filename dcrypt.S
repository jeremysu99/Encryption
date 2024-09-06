#include "Version.h"

#ifndef MYDCRYPT_S
    .section .note.GNU-stack,"",%progbits
    .end
#else

    // version 1.1 05/08/2024
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "cipher.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int dcrypt(unsigned char *inbuf, unsigned char *bookbuf, int cnt)
    // decrypts inbuf using bookbuf; result in inbuf
    //////////////////////////////////////////////////
    .global dcrypt
    .type   dcrypt, %function
    .equ    FP_OFF, 28

    // r0 contains char *inbuf
    // r1 contains char *bookbuf
    // r2 contains cnt
    // r3 contains index of outer loop
    //
    // preserved register use table
    //
    // r4 contains inbuf byte
    // r5 contains inner loop index
    // r6 contains bookbuf byte
    // r7 contains eversed byte
    // r8 contains 7-i
    // r9 contains temporary val in reversing bits

dcrypt:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF


    cmp     r2, 0               // if buffer is empty we are done
    ble     .Ldone
    // your code here 
    mov     r3, 0       // initialize loop index

.Lfor:
    cmp     r3, r2
    bge     .Ldone

    ldrb    r4, [r0]    // put inbuf byte in r4
    ldrb    r6, [r1]    // put bookbuf byte in r6
    eor     r4, r4, r6  // xor bookbuf with inbuf

    mov     r5, 0       // initialize inner loop index
    mov     r7, 0       // set reversed to 0
.Lforinner:
    lsr     r9, r4, r5  // shift right by i
    and     r9, r9, 1   // and with 1
    mov     r8, 7
    sub     r8, r8, r5
    lsl     r9, r9, r8  // shift left 7-i
    orr     r7, r7, r9  // or reversed

    add     r5, r5, 1   // increment index
    cmp     r5, 8
    blt     .Lforinner

    // fall through

    mov     r4, r7
    strb    r4, [r0]    // store in inbuf 
    add     r0, r0, 1   // increment pointer
    add     r1, r1, 1   // increment pointer
    add     r3, r3, 1   // increment index
    b       .Lfor

.Ldone:
    // make sure to return cnt processed
    mov    r0, r2
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size dcrypt, (. - dcrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
