/*
 * hasher.c - SHA-256 bridge for GnuCOBOL
 *
 * COBOL has no built-in hash function, so anchor.cbl calls this C function.
 * It hashes the transaction record with OpenSSL's SHA-256 and returns the
 * digest as 64 lowercase hex characters.
 *
 * Called from COBOL as:
 *   CALL "CalculateSHA256" USING BY REFERENCE WS-HASH-INPUT
 *                                BY REFERENCE WS-HASH-INPUT-LEN
 *                                BY REFERENCE WS-HASH-OUTPUT
 *
 * WS-HASH-INPUT-LEN must be PIC S9(9) COMP-5, a native 4-byte integer that
 * matches the C int below. WS-HASH-OUTPUT must be PIC X(64). Exactly 64 bytes
 * are written, with no terminating NUL, so nothing past the field is touched.
 * Returns 0 on success and 1 on failure; COBOL sees it in RETURN-CODE.
 */

#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>

int CalculateSHA256(const char *input_data, const int *input_len, char *output_hash) {
    unsigned char digest[EVP_MAX_MD_SIZE];
    unsigned int digest_len = 0;
    char hex[65];
    int len = *input_len;
    int i;

    if (len < 0) {
        return 1;
    }

    /* COBOL pads fields with spaces. Hash the record without trailing spaces. */
    while (len > 0 && input_data[len - 1] == ' ') {
        len--;
    }

    if (EVP_Digest(input_data, (size_t)len, digest, &digest_len, EVP_sha256(), NULL) != 1
            || digest_len != 32) {
        memset(output_hash, '0', 64);
        return 1;
    }

    for (i = 0; i < 32; i++) {
        snprintf(hex + (i * 2), 3, "%02x", digest[i]);
    }
    memcpy(output_hash, hex, 64);
    return 0;
}
