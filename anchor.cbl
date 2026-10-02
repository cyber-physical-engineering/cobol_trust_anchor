      ******************************************************************
      * PROGRAM:    ANCHOR.CBL
      * PURPOSE:    SHA-256 anchor for one COBOL transaction record
      * AUTHOR:     James Thornton
      * DATE:       2025, revised 2026
      *
      * DESCRIPTION:
      *   A proof of concept. The program builds one fixed-width
      *   transaction record and calls a C function that hashes it
      *   with OpenSSL's SHA-256. It prints the hash and writes the
      *   record and the hash to a log file. verify.py recomputes
      *   the hash, so a changed record no longer matches it.
      *   There is no chaining and no key. See README.md for limits.
      *
      * FLOW:
      *   [COBOL record] --> [C SHA-256 bridge] --> [anchor_log.txt]
      *
      * USAGE:
      *   cobc -x -o trust-anchor anchor.cbl hasher.o -lssl -lcrypto
      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRUST-ANCHOR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ANCHOR-LOG ASSIGN TO "anchor_log.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ANCHOR-LOG.
       01  LOG-RECORD                    PIC X(200).

       WORKING-STORAGE SECTION.

      ******************************************************************
      * TRANSACTION RECORD LAYOUT - SIMULATED MAINFRAME FORMAT
      ******************************************************************
       01  WS-TRANSACTION-RECORD.
           05  WS-TX-ID                  PIC X(12).
           05  WS-TX-TIMESTAMP           PIC X(26).
           05  WS-TX-FROM-ACCOUNT        PIC X(16).
           05  WS-TX-TO-ACCOUNT          PIC X(16).
           05  WS-TX-AMOUNT              PIC 9(10)V99.
           05  WS-TX-CURRENCY            PIC X(3).
           05  WS-TX-MEMO                PIC X(30).

      ******************************************************************
      * SHA-256 INTERFACE VARIABLES
      ******************************************************************
       01  WS-HASH-INPUT                 PIC X(256).
       01  WS-HASH-INPUT-LEN             PIC S9(9) COMP-5 VALUE 115.
       01  WS-HASH-OUTPUT                PIC X(64).

      ******************************************************************
      * CONTROL VARIABLES
      ******************************************************************
       01  WS-FILE-STATUS                PIC XX.
       01  WS-DISPLAY-LINE               PIC X(120).
       01  WS-LOG-OUTPUT                 PIC X(200).

       PROCEDURE DIVISION.

       0000-MAIN-PROCEDURE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-LOAD-TRANSACTION
           PERFORM 3000-CALCULATE-HASH
           PERFORM 4000-WRITE-ANCHOR
           PERFORM 9000-TERMINATE
           STOP RUN.

      ******************************************************************
      * INITIALIZATION - DISPLAY BANNER
      ******************************************************************
       1000-INITIALIZE.
           DISPLAY "=================================================="
           DISPLAY "  COBOL TRUST ANCHOR"
           DISPLAY "  SHA-256 anchor for one COBOL transaction record"
           DISPLAY "=================================================="
           DISPLAY " "
           OPEN OUTPUT ANCHOR-LOG
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "ERROR: Cannot open anchor log file"
               DISPLAY "FILE STATUS: " WS-FILE-STATUS
               STOP RUN
           END-IF.

      ******************************************************************
      * SIMULATE READING A TRANSACTION FROM CORE BANKING SYSTEM
      ******************************************************************
       2000-LOAD-TRANSACTION.
           DISPLAY "[DEMO] Building a sample transaction record..."
           MOVE "TXN-20251231" TO WS-TX-ID
           MOVE "2025-12-31T14:30:00.000Z" TO WS-TX-TIMESTAMP
           MOVE "ACCT-7892-0001"  TO WS-TX-FROM-ACCOUNT
           MOVE "ACCT-4451-0099"  TO WS-TX-TO-ACCOUNT
           MOVE 15000.00          TO WS-TX-AMOUNT
           MOVE "USD"             TO WS-TX-CURRENCY
           MOVE "WIRE TRANSFER - VERIFIED" TO WS-TX-MEMO
           DISPLAY "[DEMO] Record built: " WS-TX-ID.

      ******************************************************************
      * CALL C BRIDGE TO CALCULATE SHA-256 HASH
      ******************************************************************
       3000-CALCULATE-HASH.
           DISPLAY "[BRIDGE] Calling the C SHA-256 function..."
           MOVE WS-TRANSACTION-RECORD TO WS-HASH-INPUT

           CALL "CalculateSHA256"
               USING BY REFERENCE WS-HASH-INPUT
                     BY REFERENCE WS-HASH-INPUT-LEN
                     BY REFERENCE WS-HASH-OUTPUT
           END-CALL

           IF RETURN-CODE NOT = 0
               DISPLAY "[ERROR] SHA-256 bridge failed: " RETURN-CODE
               CLOSE ANCHOR-LOG
               STOP RUN
           END-IF

           DISPLAY "[BRIDGE] SHA-256 returned"
           DISPLAY " "
           DISPLAY "============================================="
           DISPLAY "  TRUST ANCHOR CREATED"
           DISPLAY "============================================="
           DISPLAY "  TX-ID:  " WS-TX-ID
           DISPLAY "  AMOUNT: $" WS-TX-AMOUNT " " WS-TX-CURRENCY
           DISPLAY "  HASH:   " WS-HASH-OUTPUT
           DISPLAY "=============================================".

      ******************************************************************
      * WRITE THE LOG ENTRY: RECORD, "|", HASH
      ******************************************************************
       4000-WRITE-ANCHOR.
           MOVE SPACES TO WS-LOG-OUTPUT
           STRING WS-TRANSACTION-RECORD DELIMITED SIZE
                  "|" DELIMITED SIZE
                  WS-HASH-OUTPUT DELIMITED SIZE
               INTO WS-LOG-OUTPUT
           END-STRING

           WRITE LOG-RECORD FROM WS-LOG-OUTPUT
           IF WS-FILE-STATUS = "00"
               DISPLAY " "
               DISPLAY "[ANCHOR] Record written to anchor_log.txt"
           ELSE
               DISPLAY "[ERROR] Write failed: " WS-FILE-STATUS
           END-IF.

      ******************************************************************
      * CLEANUP
      ******************************************************************
       9000-TERMINATE.
           CLOSE ANCHOR-LOG
           DISPLAY " "
           DISPLAY "[COMPLETE] Record and hash written."
           DISPLAY " ".

