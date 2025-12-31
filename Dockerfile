###############################################################################
# COBOL Trust Anchor - Docker Build
# 
# Big Data Plumbing / HealthSec Alliance
# "Bridging 1980s Infrastructure to 2026 Security Standards"
#
# This container compiles and runs a demonstration of cryptographic
# trust anchoring for legacy COBOL transaction systems.
###############################################################################

FROM debian:bookworm-slim AS builder

LABEL maintainer="Big Data Plumbing <contact@bigdataplumbing.com>"
LABEL description="Zero Trust Anchor for Legacy Mainframe Systems"

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
RUN gcc -c -fPIC hasher.c -o hasher.o -lcrypto

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

