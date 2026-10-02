#!/usr/bin/env python3
"""
verify.py - check the trust anchor log written by anchor.cbl

Each line of anchor_log.txt is the fixed-width transaction record that
anchor.cbl hashed, a "|" separator, and the 64-character SHA-256 hex digest.
This script recomputes the digest the same way hasher.c does (record bytes,
trailing spaces removed) and compares it with the stored one.

Usage:
    python3 verify.py anchor_log.txt

Exit status: 0 if every entry matches, 1 if any entry is changed, malformed,
or the file is missing or empty.
"""

import hashlib
import re
import sys
from pathlib import Path

HEX_DIGEST = re.compile(r"^[0-9a-f]{64}$")


def parse_entry(line):
    """Split one log line into (record, stored_digest)."""
    record, sep, stored = line.rstrip("\r\n").rpartition("|")
    stored = stored.strip()
    if not sep or not HEX_DIGEST.match(stored):
        raise ValueError("expected '<record>|<64 hex digits>'")
    return record, stored


def compute_digest(record):
    """SHA-256 of the record without trailing spaces, as hasher.c computes it."""
    return hashlib.sha256(record.rstrip(" ").encode("ascii")).hexdigest()


def verify_log(log_path):
    path = Path(log_path)
    if not path.exists():
        print(f"Log file not found: {log_path}")
        return False

    entries = 0
    failures = 0
    for line_number, line in enumerate(path.read_text(encoding="ascii").splitlines(), 1):
        if not line.strip():
            continue
        entries += 1
        try:
            record, stored = parse_entry(line)
        except ValueError as error:
            print(f"Line {line_number}: MALFORMED ({error})")
            failures += 1
            continue

        computed = compute_digest(record)
        if computed == stored:
            print(f"Line {line_number}: VERIFIED  {stored}")
        else:
            print(f"Line {line_number}: MISMATCH  stored {stored}")
            print(f"{'':10}            computed {computed}")
            failures += 1

    if entries == 0:
        print("No entries found.")
        return False

    print(f"{entries - failures} of {entries} entries verified.")
    return failures == 0


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 verify.py <anchor_log.txt>")
        sys.exit(2)
    sys.exit(0 if verify_log(sys.argv[1]) else 1)


if __name__ == "__main__":
    main()
