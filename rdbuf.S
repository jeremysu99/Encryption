#include "Version.h"

#ifndef MYRDBUF_S
    .section .note.GNU-stack,"",%progbits
    .end
#else

    // version 1.1 05/08/2024
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // global constants
    #include "cipher.h"

    .extern fread
    .text

    //////////////////////////////////////////////////////
    // int rdbuf(FILE *in, FILE *book, int cnt, unsigned char *inbuf,
    //          unsigned char *bookbuf)
    // OBSERVE this has 5 arguments!
    //
    // This function reads up to cnt bytes into inbuf from FILE *in such
    // as bytes = fread(). bytes is the actual number of bytes read.
    // Then read the same number of bytes from the FILE *book into the
    // buffer bookbuf.
    // 
    //  Arguments
    //  in       pointer of type FILE where the input data is read from
    //  fobook   pointer of type FILE where the bookfile is read from
    //  cnt      max number of bytes to read into inbuf
    //  inbuf    buffer where the input data is read into
    //  bookbuf  buffer where the bookfile data is read into
    // 
    //  Returns
    //  0        when EOF is reached on the in
    //  bytes    number of bytes actually read
    //  RETRN_FAIL
    //           when the read on bookbuf does not return bytes
    //////////////////////////////////////////////////////

    .type   rdbuf, %function
    .global rdbuf
    // determine how many registers to save and set FP_OFF
    .equ    FP_OFF, 20
    .equ    ARG5, 4
    .equ    FRMADD, 0 
   // preserved register use table fill this in to help you
   //
   // r4
   // r5
   // r6
   // r7
   // r8
   // r9
 
rdbuf:
    // set up stack frame
    push    {r4-r7, fp, lr}
    add     fp, sp, FP_OFF
    add     sp, sp, -FRMADD

    mov     r4, r0  //put *in in r4
    mov     r7, r1  //put *fpbook in r7

    mov     r0, r3
    mov     r1, 1
    mov     r3, r4

    bl      fread   //sets r0 to return value
    mov     r6, r0  //put bytes in r6
    
    ldr     r5, [fp, ARG5]    //put *bookbuf in r5
    mov     r0, r5
    mov     r1, 1
    mov     r2, r6
    mov     r3, r7
    bl      fread

    cmp     r0, r6
    bne     .Lnoteq
    mov     r0, r6
    b       .Ldone
.Lnoteq:
    mov     r0, RETRN_FAIL

     // fread() from FILE *in into inbuf
     // now fread() the same number of bytes from the bookfp
     // as was read from the input FILE *in into bookbuf
     // if bytes read from bookfile is not the same as read into inbuf,
     // then return RETRN_FAIL;

     // return the number of bytes read

.Ldone:
    // remove stack frame
    sub     sp, fp, FP_OFF
    pop     {r4-r7, fp, lr}
    bx      lr

    .size   rdbuf, (. - rdbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif
