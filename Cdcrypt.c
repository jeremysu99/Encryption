#include "Version.h"

#if defined(MYDCRYPT_S)
#warning("using my dcrypt.S")
#elif !defined(MYDCRYPT_C)
#warning("using solution decrypt")
#else
#warning("using my Cdcrypt.c")

// version 1.1 05/08/2024
#include <stdio.h>
#include "cipher.h"

/*
 * dcrypt:
 *      descrypts in inbuf with the bookbuf, reverse of encrypt
 * Arguments:
 *      inbuf:
 *          pointer to the inbuf string to descrypt
 *      bookbuf:
 *          pointer to the bookbuf string to xor with
 *      cnt:
 *          number of bytes in both strings
 * Returns:
 *      number of bytes descrypted
 */
// decrypts inbuf with bookbuf; updating inbuf
int
dcrypt(unsigned char *inbuf, unsigned char *bookbuf, int cnt)
{

    if (cnt <= 0)
        return 0;
    // your code here
    unsigned char reversed;

    for (int index = 0; index < cnt; index++){

        *inbuf = *inbuf ^ *bookbuf;
        reversed = 0;

        for (int i = 0; i < 8; i++){
            reversed |= ((*inbuf >> i) & 1) << (7 - i);
        }
        *inbuf = reversed;
        inbuf++;
        bookbuf++;
    }
    return cnt;
}
#endif
