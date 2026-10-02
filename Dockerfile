###############################################################################
# COBOL Trust Anchor: Docker build
#
# Builds the COBOL program and its C SHA-256 bridge with GnuCOBOL and
# OpenSSL, then runs the demo in a small runtime image.
###############################################################################

FROM debian:bookworm-slim AS builder

LABEL description="COBOL Trust Anchor: SHA-256 anchor for one COBOL transaction record (proof of concept)"

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnucobol \
    libssl-dev \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy source files
COPY hasher.c .
COPY anchor.cbl .

# Compile C bridge as object file
RUN gcc -c -fPIC -Wall hasher.c -o hasher.o

# Compile COBOL with C linkage
RUN cobc -x -o trust-anchor anchor.cbl hasher.o -lssl -lcrypto

###############################################################################
# Runtime Stage - Minimal footprint
###############################################################################
FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcob4 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled binary
COPY --from=builder /build/trust-anchor .

# Create output directory
RUN mkdir -p /app/output

# Set environment for GnuCOBOL runtime
ENV COB_LIBRARY_PATH=/usr/lib

# Run the trust anchor demo
CMD ["./trust-anchor"]

