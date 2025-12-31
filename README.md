# 🔐 COBOL Trust Anchor

> **"70% of the world's financial transactions run on COBOL. None of them are cryptographically anchored."**

A proof-of-concept demonstrating **Zero Trust security for legacy mainframe systems**. This project bridges **COBOL-85** transaction processing with **SHA-256 cryptographic anchoring**—without rewriting the core business logic.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![COBOL](https://img.shields.io/badge/COBOL-85-green.svg)]()
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)]()

---

## 🎯 The Problem

Legacy mainframe systems process **trillions of dollars daily** in banking, healthcare claims, and insurance. These systems were designed before cybersecurity existed as a discipline. A sophisticated attacker with root access can:

- **Modify transaction logs** retroactively
- **Erase evidence** of fraudulent transfers  
- **Falsify audit trails** to hide intrusion

Traditional security (firewalls, access controls) cannot detect post-compromise tampering of historical records.

---

## 💡 The Solution: Cryptographic Trust Anchors

Instead of the **risky and expensive** approach of rewriting core banking systems, we inject a **lightweight trust anchor sidecar** that:

1. **Intercepts** each transaction record
2. **Computes** a SHA-256 cryptographic hash
3. **Writes** the hash to an append-only immutable log

Even if an attacker gains root access to the mainframe, they **cannot alter historical ledgers** without breaking the cryptographic chain. Auditors can verify integrity by recomputing hashes.

```
┌─────────────────────────────────────────────────────────────────┐
│                    LEGACY MAINFRAME                             │
│  ┌──────────────┐    ┌───────────────────┐    ┌──────────────┐ │
│  │   COBOL      │───▶│  C CRYPTO BRIDGE  │───▶│  IMMUTABLE   │ │
│  │  TRANSACTION │    │    (SHA-256)      │    │     LOG      │ │
│  │   RECORDS    │    │                   │    │              │ │
│  └──────────────┘    └───────────────────┘    └──────────────┘ │
│        ▲                                             │         │
│        │              ZERO TRUST ANCHOR              ▼         │
│   [VSAM/DB2]                                   [AUDIT CHAIN]   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- Docker installed on your system

### Run the Demo

```bash
# Clone the repository
git clone https://github.com/BigDataPlumbing/cobol_trust_anchor.git
cd cobol_trust_anchor

# Build and run
docker build -t cobol-trust-anchor .
docker run --rm cobol-trust-anchor
```

### Expected Output

```
==================================================
  COBOL TRUST ANCHOR - Zero Trust for Mainframes
  Big Data Plumbing / HealthSec Alliance
==================================================

[MAINFRAME] Loading transaction from VSAM...
[MAINFRAME] Transaction loaded: TXN-20251231
[BRIDGE] Invoking SHA-256 cryptographic engine...
[CRYPTO] SHA-256 Hash Generated

=============================================
  TRUST ANCHOR CREATED
=============================================
  TX-ID:  TXN-20251231
  AMOUNT: $0000015000.00 USD
  HASH:   a3f2b8c9e1d4f6a8b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5
=============================================

[ANCHOR] Record written to immutable_log.txt
[COMPLETE] Trust anchor secured.
```

---

## 📁 Project Structure

```
cobol_trust_anchor/
├── anchor.cbl      # COBOL transaction processor
├── hasher.c        # C-interop SHA-256 bridge
├── Dockerfile      # Multi-stage build
├── Makefile        # Local development build
├── README.md       # Documentation
├── LICENSE         # MIT License
└── .gitignore      # Build artifacts
```

---

## 🏗️ Architecture Deep Dive

### Why C-Interop?

COBOL lacks native cryptographic primitives. GnuCOBOL's C-interop capability allows us to:

1. Keep the COBOL business logic **unchanged** (no regression risk)
2. Leverage battle-tested OpenSSL for cryptography
3. Maintain the **COBOL-as-source-of-truth** paradigm that regulated industries require

### The Hash Chain

Each log entry contains:
```
TIMESTAMP | TX-ID | FROM-ACCT | TO-ACCT | AMOUNT | SHA-256-HASH
```

For production deployment, the hash would include the **previous record's hash**, creating an unbreakable chain (similar to blockchain, but for a single-source ledger).

### Local Development (Without Docker)

If you have GnuCOBOL installed locally:

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt-get install gnucobol libssl-dev gcc

# Compile
make

# Run
./trust-anchor
```

---

## 🏥 Industry Applications

| Industry | Legacy System | Use Case |
|----------|--------------|----------|
| **Banking** | COBOL/CICS/DB2 | Wire transfer integrity verification |
| **Healthcare** | MUMPS/Epic | HIPAA audit log protection |
| **Insurance** | AS/400 COBOL | Claims processing tamper detection |
| **Government** | Legacy batch systems | Compliance audit trails |

---

## 🛡️ Compliance Alignment

This pattern supports:

- **HIPAA** - Audit log integrity requirements
- **PCI-DSS** - Requirement 10 (track access to cardholder data)  
- **SOX** - Financial record integrity
- **NIST Zero Trust** - "Never trust, always verify" for legacy systems

---

## 🔧 Production Considerations

This is a **proof-of-concept**. Production deployment would require:

- [ ] Hardware Security Module (HSM) integration for key management
- [ ] Append-only storage (WORM drives or blockchain anchoring)
- [ ] Real-time transaction interception (CICS exit points)
- [ ] Hash chaining (include previous hash in current calculation)
- [ ] External timestamp authority (RFC 3161)
- [ ] Performance optimization for high-volume transaction streams

---

## 🧪 Testing

To verify the cryptographic integrity:

```bash
# Run the program
docker run --rm -v $(pwd)/output:/app/output cobol-trust-anchor

# Verify hash (example with openssl)
echo -n "TXN-20251231|2025-12-31T14:30:00.000Z|ACCT-7892-0001|ACCT-4451-0099|15000.00USD|WIRE TRANSFER - VERIFIED" | \
  openssl dgst -sha256 -hex
```

---

## 👥 About

**Big Data Plumbing** specializes in bridging legacy infrastructure with modern security requirements. We do the "Deep Plumbing" that connects 1980s mainframes to 2026 Zero Trust architectures.

**HealthSec Alliance** focuses on securing healthcare data systems, from legacy MUMPS installations to modern FHIR APIs.

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

This is a showcase project demonstrating architectural patterns. For production implementations, please contact [Big Data Plumbing](https://github.com/BigDataPlumbing).

---

<p align="center">
  <i>"We don't rewrite your mainframe. We secure it."</i>
</p>

