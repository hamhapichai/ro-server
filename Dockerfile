# ============================================
# Hercules RO Emulator - Multi-stage Dockerfile
# For Dokploy deployment on Linux
# ============================================

# Stage 1: Build Hercules from source
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
    gcc \
    g++ \
    zlib1g-dev \
    libmysqlclient-dev \
    libpcre3-dev \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone Hercules (PRE-RE branch)
ARG HERCULES_BRANCH=stable
RUN git clone --depth 1 --branch ${HERCULES_BRANCH} https://github.com/HerculesWS/Hercules.git .

# Configure for pre-renewal mode
RUN ./configure --enable-prere=yes --enable-packetver=20180418

# Build
RUN make clean && make sql -j$(nproc)

# ============================================
# Stage 2: Runtime image
# ============================================
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmariadb3 \
    libpcre3 \
    zlib1g \
    libssl3 \
    gosu \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create hercules user
RUN useradd -m -s /bin/bash hercules

WORKDIR /hercules

# Copy compiled binaries from builder
COPY --from=builder /build/login-server /hercules/
COPY --from=builder /build/char-server /hercules/
COPY --from=builder /build/map-server /hercules/

# Copy required directories
COPY --from=builder /build/conf /hercules/conf
COPY --from=builder /build/db /hercules/db
COPY --from=builder /build/npc /hercules/npc
COPY --from=builder /build/maps /hercules/maps
COPY --from=builder /build/sql-files /hercules/sql-files
COPY --from=builder /build/log /hercules/log
COPY --from=builder /build/save /hercules/save
COPY --from=builder /build/cache /hercules/cache

# Create necessary directories
RUN mkdir -p /hercules/log /hercules/save /hercules/cache \
    && chown -R hercules:hercules /hercules

# Copy entrypoint script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
# Login: 6900, Char: 6121, Map: 5121
EXPOSE 6900 6121 5121

# Set default environment variables
ENV DB_HOST=db \
    DB_PORT=3306 \
    DB_USER=ragnarok \
    DB_PASS=ragnarok \
    DB_NAME=hercules \
    SERVER_NAME=MyROServer \
    WISP_NAME=Server \
    PUBLIC_IP=127.0.0.1

ENTRYPOINT ["/entrypoint.sh"]
