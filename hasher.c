/*
 * hasher.c - SHA-256 Bridge for GnuCOBOL
 * 
 * Big Data Plumbing / HealthSec Alliance
 * "Deep Plumbing for Regulated Industries"
 *
 * This module provides a COBOL-callable SHA-256 hashing function,
 * enabling legacy mainframe applications to generate cryptographic
 * trust anchors without modification to core business logic.
 *
 * Architecture: COBOL Transaction → C Bridge → SHA-256 Hash → Immutable Log
 */

#include <stdio.h>
#include <string.h>
#include <openssl/sha.h>

/*
 * CalculateSHA256 - COBOL-Interop Entry Point
 *
 * Parameters (passed by reference from COBOL):
 *   input_data   - Pointer to the transaction record (null-terminated or padded)
 *   input_len    - Length of input data
 *   output_hash  - 64-byte buffer for hex-encoded SHA-256 result
 *
 * GnuCOBOL Call Convention:
 *   CALL "CalculateSHA256" USING BY REFERENCE WS-RECORD
 *                                BY REFERENCE WS-RECORD-LEN
 *                                BY REFERENCE WS-HASH-OUTPUT
 */
void CalculateSHA256(char *input_data, int *input_len, char *output_hash) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    int i;
    int len = *input_len;

    /* Trim trailing spaces (COBOL pads fields) */
    while (len > 0 && input_data[len - 1] == ' ') {
        len--;
    }

    /* Calculate SHA-256 digest */
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, input_data, len);
    SHA256_Final(hash, &sha256);

    /* Convert to hex string (64 chars) */
    for (i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        sprintf(output_hash + (i * 2), "%02x", hash[i]);
    }
    output_hash[64] = '\0';
}

