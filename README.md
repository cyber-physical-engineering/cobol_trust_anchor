# COBOL Trust Anchor

A proof of concept. A COBOL program builds one fixed-width bank-transfer record, hashes it with SHA-256 through a C function, and writes the record and its hash to a log. A Python script recomputes the hash to check the log.

**Status: prototype.** Built and run with GnuCOBOL 3.2 and OpenSSL 3 (October 2026). The program prints the record's SHA-256, `verify.py` reports 1 of 1 entries verified, and a copy of the log with one word changed fails.

James Thornton set the architecture and requirements. The code was written with AI-assisted development in late 2025. The tests and checks were re-run in October 2026.

## What it does

1. `anchor.cbl` fills a 115-byte transaction record. The layout is below.
2. It calls `CalculateSHA256` in `hasher.c`, which hashes the record with OpenSSL's SHA-256 and returns 64 hex characters.
3. It prints the hash and writes one line to `anchor_log.txt`: the record, a `|`, and the hash.
4. `verify.py` reads the log, recomputes each hash and prints VERIFIED or MISMATCH for each line.

COBOL has no hash function of its own, so the hash lives in C. The record layout stays COBOL's.

### Record layout

| Field | Picture | Bytes |
|---|---|---|
| Transaction ID | `X(12)` | 12 |
| Timestamp | `X(26)` | 26 |
| From account | `X(16)` | 16 |
| To account | `X(16)` | 16 |
| Amount | `9(10)V99` | 12 |
| Currency | `X(3)` | 3 |
| Memo | `X(30)` | 30 |

Total: 115 bytes. The C side drops trailing spaces before hashing, and `verify.py` does the same.

## Quick start

With Docker:

```bash
docker build -t cobol-trust-anchor .
docker run --rm cobol-trust-anchor
```

Without Docker, with GnuCOBOL, the OpenSSL headers and gcc installed:

```bash
make
./trust-anchor
python3 verify.py anchor_log.txt
```

The run prints the record's hash:

```
=============================================
  TRUST ANCHOR CREATED
=============================================
  TX-ID:  TXN-20251231
  AMOUNT: $0000015000.00 USD
  HASH:   eb9444ab8932c736f41bedd70ed29c630cc6d4c0463cd0cd9f940f0e94208915
=============================================
```

That hash is the SHA-256 of the record, checked independently in Python. To check it yourself:

```bash
python3 -c "import hashlib; r = 'TXN-20251231' + '2025-12-31T14:30:00.000Z'.ljust(26) + 'ACCT-7892-0001'.ljust(16) + 'ACCT-4451-0099'.ljust(16) + '000001500000' + 'USD' + 'WIRE TRANSFER - VERIFIED'; print(hashlib.sha256(r.encode()).hexdigest())"
```

## How it works

`anchor.cbl` passes three things to C by reference: the record, its length, and a 64-byte output field. The length field is `PIC S9(9) COMP-5`, a native 4-byte integer that matches the C `int`. `hasher.c` writes exactly 64 bytes and returns 0 or 1, which COBOL reads in `RETURN-CODE`. A non-zero return stops the program.

`verify.py` splits each line at the last `|`, hashes the record the same way, and compares. It exits 0 only when every entry matches, and 1 for a mismatch, a malformed line, or a missing or empty file.

## What it is not

- There is no chaining. Each line stands alone; nothing ties a record to the one before it.
- There is no key. Anyone who can rewrite the record can rewrite its hash to match. A real version needs chaining plus a signature or an outside anchor.
- `anchor_log.txt` is an ordinary file. Nothing makes it append-only.
- The mainframe is simulated. One record is built in `WORKING-STORAGE`; nothing reads VSAM or hooks CICS.
- Nothing here meets any regulation. It shows one mechanism: a hash a reviewer can recompute.

## CI

On every push the workflow builds the Docker image, runs the demo, and runs `verify.py` on the log it wrote. It then changes one word in a copy of the log and requires `verify.py` to fail.

## License

MIT. See [LICENSE](LICENSE).
