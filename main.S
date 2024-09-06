#include "Version.h"

#ifndef MYMAIN_S
    .section .note.GNU-stack,"",%progbits
    .end
#else

    // version 1.3 05/11/2024 //
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // imports
    #include "main.h"
    #include "rdbuf.h"
    #include "setup.h"
    #include "cipher.h"
    .extern fwrite
    .extern stdin
    .extern stdout
    .extern stderr
    //
    // cipher [-d | -e] -b bookfile
    //
    // int main(int argc, char **argv)
    //
    .section .rodata
    // string literals for fprint
.Lrdmess:  .string "%s: read failed\n"
    .align 2
.Lwrmess:  .string "%s: write failed\n"

    .text
    .global main
    .type   main, %function
    //
    // complete the stack frame layout
    //
    .equ    FP_OFF,     32  // fp offset in main stack frame

    // use the same stack allocation order as in Cmain.c

    //
    // add your local variables here if you need them:
    //
    .equ    FPBOOK, 4 + FP_OFF
    .equ    INBUF, BUFSZ + FPBOOK
    .equ    BOOKBUF, BUFSZ + INBUF
    .equ    FUNC, 4 + BOOKBUF
    .equ    ARGV0, 4 + FUNC
    .equ    PAD, 4 + ARGV0
    .equ    OARG5, 4 + FUNC
    .equ    FRMADD, OARG5 - FP_OFF
    // NOTICE: Adjust PAD so the total size of frame (including 
    // preserved registers r4-r10, fp,lr) in bytes divides by 8 evenly
    // (8-byte aligned) keep the two buffers 8-byte aligned as well
    //.equ    PAD,             	    // Stack frame PAD
    //.equ    OARG5,           	    // output arg5 must be at bottom
    //.equ    FRMADD,OARG5-FP_OFF   // total space for locals + outarg5

    //
    // preserved register use table fill this in describing your use for each
    //
    // r4
    // r5
    // r6
    // r7
    // r8
    // r9
    // r10

main:
    push    {r4-r10, fp, lr}        // observe: odd number of regs saved
    add     fp, sp, FP_OFF          // set frame pointer to frame base
    // allocate space for locals and outgoing args below
    add     sp, sp, -FRMADD
    str     r1, [fp, -ARGV0]
    mov     r9, r1

    // call int setup(argc, argv, &func, &fpbook)
    add     r2, fp, -FUNC
    add     r3, fp, -FPBOOK
    bl      setup
    cmp     r0, RETRN_FAIL
    beq     .Lfail

    // initialize the preserved registers and stack variables
    // for main loop
    ldr     r0, =stdin
    ldr     r0, [r0]
    ldr     r1, [fp, -FPBOOK]
    mov     r2, BUFSZ
    add     r3, fp, -INBUF
    add     r4, fp, -BOOKBUF
    str     r4, [fp, -OARG5]
    //
    // top of loop
    //
    mov     r5, r0
    mov     r6, r1
    mov     r7, r2
    mov     r8, r3

.Lloop:
    bl      rdbuf
    mov     r10, r0     //store retval in r10
    cmp     r10, 0
    beq     .Lexitloop
    
    // int rdbuf(r0=stdin, r1=fpbook, r2=BUFSZ, r3=inbuf,OARG5=bookbuf)
    // cnt = rdbuf(FILE *, FILE*, int, unsigned char *, unsigned char *)
    //
    cmp     r10, RETRN_FAIL
    beq     .Lreadfail

    
    //
    // cnt = func(unsigned char *inbuf, unsigned char *bookbuf, int cnt)
    //
    add     r0, fp, -INBUF
    add     r1, fp, -BOOKBUF
    mov     r2, r10
    ldr     r3, [fp, -FUNC]
    blx     r3
    //
    // fwrite(inbuf, 1, cnt, stdout)
    // 
    add     r0, fp, -INBUF
    mov     r1, 1
    mov     r2, r10
    ldr     r3, =stdout
    ldr     r3, [r3]
    bl      fwrite

    cmp     r0, r10
    bne     .Lwritefail
    //
    // bottom of loop
    //
    mov     r0, r5
    mov     r1, r6
    mov     r2, r7
    mov     r3, r8

    b   .Lloop
    //
    // error handling code
    //
.Lreadfail:
    ldr     r0, =stderr
    ldr     r0, [r0]
    ldr     r1, =.Lrdmess
    ldr     r2, [fp, -ARGV0]
    //mov     r2, r9
    bl      fprintf
    b       .Lfail
.Lwritefail:
    ldr     r0, =stderr
    ldr     r0, [r0]
    ldr     r1, =.Lwrmess
    ldr     r2, [fp, -ARGV0]
    bl      fprintf
    ldr     r0, [fp, -FPBOOK]
    bl      fclose
    b       .Lfail
    //
    // end of error handling code
    //
.Lexitloop:
    ldr     r0, [fp, -FPBOOK]
    bl      fclose
    mov     r0, EXIT_SUCCESS
    b       .Ldone
.Lfail:
    mov     r0, EXIT_FAILURE

.Ldone:
    // set return value
    sub     sp, fp, FP_OFF
    pop     {r4-r10, fp, lr}
    bx      lr

    .size   main, (. - main)
    .section .note.GNU-stack,"",%progbits
.end
#endif
