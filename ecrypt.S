#include "Version.h"

#ifndef MYECRYPT_S
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
    // int ecrypt(unsigned char *inbuf, unsigned char *bookbuf, int cnt)
    // encrypts  inbuf with bookbuf; updating inbuf
    //////////////////////////////////////////////////
    .global ecrypt
    .type   ecrypt, %function
    .equ    FP_OFF, 28

   // r0 contains char *inbuf
   // r1 contains char *bookbuf
   // r2 contains cnt
   // r3 contains index in for loop
   //
   // preserved register use table
   //
   // r4 contains inbuf byte
   // r5 contains reversed byte
   // r6 contains i in inner for loop
   // r7 contains temporary val wheen reversing
   // r8 contains 7-i
   // r9

ecrypt:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF

    cmp     r2, 0       // if buffer is empty we are done
    ble     .Ldone
    mov     r3, 0
    // your code here

.Lfor:
    cmp     r3, r2
    bge     .Ldone

    mov     r5, 0
    ldrb    r4, [r0]    // put the inbuf byte in r4
    mov     r6, 0
.Lforinner:
    lsr     r7, r4, r6  // shift byte right by i and store in r7
    and     r7, r7, 1   // and it with 1
    mov     r8, 7
    sub     r8, r8, r6

    lsl     r7, r7, r8  // shift byte left by 7 - i
    orr     r5, r5, r7  // store or operation in reversed byte

    add     r6, r6, 1
    cmp     r6, 8
    blt     .Lforinner

    // fall through

    ldrb    r7, [r1]    // put the bookbuf byte in r7
    eor     r4, r5, r7  // xor the reversed byte with bookbuf byte
    strb    r4, [r0]    // store value of r4 back in inbuf

    add     r3, r3, 1   // increment byte count
    add     r0, r0, 1   // increment pointer
    add     r1, r1, 1   // increment opinter
    
    b       .Lfor
.Ldone:

    // make sure to return cnt processed
    mov     r0, r2
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size ecrypt, (. - ecrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
