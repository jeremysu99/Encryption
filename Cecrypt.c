#include "Version.h"

#if defined(MYECRYPT_S)
#warning("using my ecrypt.S")
#elif !defined(MYECRYPT_C)
#warning("using solution ecrypt")
#else
#warning("using my Cecrypt.c")

// version 1.1 05/08/2024
#include <stdio.h>
#include "cipher.h"

/*
 * ecrypt
 *      encrpts the inbuf with bookbuf
 * Arguments:
 *      inbuf:
 *          pointer to inbuf string to encrpt
 *      bookbuf:
 *          pointer to bookbuf string to xor with
 *      cnt:
 *          number of bytes in both strings
 * Returns:
 *      bytes encrypted
 */
// encrypts inbuf with bookbuf; updating inbuf
int
ecrypt(unsigned char *inbuf, unsigned char *bookbuf, int cnt)
{
    if (cnt <= 0)
        return 0;
    // your code her
    unsigned char reversed;

    for (int index = 0; index < cnt; index++){
        reversed = 0;

        for (int i = 0; i < 8; i++){
            reversed |= ((*inbuf >> i) & 1) << (7 - i);
        }

        *inbuf = reversed ^ *bookbuf;

        inbuf++;
        bookbuf++;
    }
  
    return cnt;
}
#endif
