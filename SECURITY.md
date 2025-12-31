# Security Policy

## Reporting a Vulnerability

Big Data Plumbing takes security seriously. If you discover a security vulnerability in this project, please report it responsibly.

### How to Report

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please email security concerns to: **security@bigdataplumbing.com**

Include the following in your report:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution**: Dependent on severity, typically within 30 days

### Scope

This security policy applies to:
- The COBOL Trust Anchor demonstration code
- The C cryptographic bridge (`hasher.c`)
- Docker build configurations

### Out of Scope

This is a **proof-of-concept demonstration**, not production software. The following are known limitations:

- No key management (production would use HSM)
- No hash chaining (production would chain hashes)
- No append-only storage enforcement
- Single-threaded execution

### Security Best Practices

If adapting this pattern for production:

1. **Use Hardware Security Modules (HSM)** for cryptographic operations
2. **Implement hash chaining** - include previous hash in current calculation
3. **Use append-only storage** - WORM drives or blockchain anchoring
4. **Add timestamp authority** - RFC 3161 trusted timestamps
5. **Enable audit logging** - track all access to the trust anchor

---

*Big Data Plumbing / HealthSec Alliance*  
*"We don't rewrite your mainframe. We secure it."*

