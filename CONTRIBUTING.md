# Contributing to COBOL Trust Anchor

Thank you for your interest in contributing to COBOL Trust Anchor! This project demonstrates cryptographic security patterns for legacy mainframe systems.

## Ways to Contribute

### 🐛 Bug Reports

If you find a bug, please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- Environment details (OS, Docker version, etc.)

### 💡 Feature Requests

We welcome ideas for extending this demonstration:
- Additional hash algorithms (SHA-3, BLAKE3)
- Hash chaining implementation
- Alternative legacy language bridges (MUMPS, PL/I)
- Integration patterns for specific mainframe platforms

### 🔧 Code Contributions

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Style

- **COBOL**: Follow IBM Enterprise COBOL style guidelines
- **C**: Use K&R style with 4-space indentation
- **Comments**: Clear, professional documentation

### Testing

Before submitting:
```bash
# Build and run locally
docker build -t cobol-trust-anchor .
docker run --rm cobol-trust-anchor
```

## Development Setup

### Prerequisites
- Docker (recommended)
- OR: GnuCOBOL + libssl-dev + gcc (for local development)

### Local Build (Without Docker)
```bash
# Debian/Ubuntu
sudo apt-get install gnucobol libssl-dev gcc
make
./trust-anchor
```

## Questions?

For questions about:
- **This demo**: Open a GitHub issue
- **Production implementations**: Contact Big Data Plumbing
- **Security concerns**: See [SECURITY.md](SECURITY.md)

---

*Big Data Plumbing / HealthSec Alliance*

