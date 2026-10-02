# Contributing

This is a prototype. Issues and pull requests are welcome. There is no release schedule and no promised response time.

## Build and test

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

A changed log must fail: copy `anchor_log.txt`, edit one character, and run `verify.py` on the copy. CI does the same.

## Before you open a pull request

1. Run the steps above.
2. Keep the change small and say what it fixes.
3. Keep COBOL comments inside column 72 and the C bridge warning-free with `-Wall -Wextra`.
4. If the change removes a limit listed in the README, update that section.

## Ideas that fit

- Chain the records: include the previous hash in each new hash.
- Sign the log or anchor the newest hash somewhere the writer cannot reach.
- Read records from a file instead of building one in `WORKING-STORAGE`.
