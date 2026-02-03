# humotica-core: The complete AI provenance stack
# tibet-core + did-jis-core + Python + C libraries
#
# Usage:
#   docker build -t humotica/core .
#   docker run -it humotica/core python3
#
# Copyright (c) 2026 Humotica
# License: MIT OR Apache-2.0

FROM python:3.12-slim AS builder

# Install Rust
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install maturin
RUN pip install maturin

# Build tibet-core
WORKDIR /build/tibet-core
COPY tibet-core/ .
RUN maturin build --release --features python,cbind
RUN cargo build --release --features cbind

# Build did-jis-core
WORKDIR /build/did-jis-core
COPY did-jis-core/ .
RUN maturin build --release --features python,cbind
RUN cargo build --release --features cbind

# ===========================================
# Final image
# ===========================================
FROM python:3.12-slim

LABEL org.opencontainers.image.title="humotica-core"
LABEL org.opencontainers.image.description="The complete AI provenance stack: tibet-core + did-jis-core"
LABEL org.opencontainers.image.authors="Jasper van de Meent <jasper@humotica.nl>, Root AI <root_idd@humotica.nl>"
LABEL org.opencontainers.image.source="https://github.com/Humotica/humotica-core"
LABEL org.opencontainers.image.licenses="MIT OR Apache-2.0"
LABEL org.opencontainers.image.vendor="Humotica"

# Install Python wheels
COPY --from=builder /build/tibet-core/target/wheels/*.whl /tmp/
COPY --from=builder /build/did-jis-core/target/wheels/*.whl /tmp/
RUN pip install /tmp/*.whl && rm /tmp/*.whl

# Install C libraries
COPY --from=builder /build/tibet-core/target/release/libtibet_core.so /usr/local/lib/
COPY --from=builder /build/did-jis-core/target/release/libdid_jis_core.so /usr/local/lib/
RUN ldconfig

# Install C headers
COPY --from=builder /build/tibet-core/cbind/include/tibet.h /usr/local/include/
COPY --from=builder /build/did-jis-core/cbind/include/did_jis.h /usr/local/include/

# Create non-root user
RUN useradd -m -s /bin/bash humotica
USER humotica
WORKDIR /home/humotica

# Verify installation
RUN python3 -c "from tibet_core import TibetEngine; from did_jis_core import DIDEngine; print('humotica-core ready!')"

CMD ["python3"]
