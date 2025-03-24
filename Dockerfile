###############################################
# Stage 1: Builder - Compile proto files
###############################################
FROM debian:bullseye-slim AS builder

# Install required tools for proto compilation
RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    protobuf-compiler-grpc \
    python3-pip \
    curl \
    unzip \
    git \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Install language-specific protobuf plugins
RUN pip3 install grpcio-tools==1.53.0 mypy-protobuf==3.4.0

# Install specific version of protoc (optional if you need a newer version than in apt)
# RUN PROTOC_VERSION=22.3 \
#     && curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
#     && unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local \
#     && rm protoc-${PROTOC_VERSION}-linux-x86_64.zip

# Set up workspace
WORKDIR /build

# Copy proto files and scripts
COPY proto/ /build/proto/
COPY scripts/ /build/scripts/

# Make scripts executable
RUN chmod +x /build/scripts/*.sh

# Create output directories
RUN mkdir -p /build/gen/cpp \
    && mkdir -p /build/gen/python \
    && mkdir -p /build/gen/java \
    && mkdir -p /build/gen/go \
    && mkdir -p /build/gen/csharp

# Generate code for all supported languages
RUN /build/scripts/build_protos.sh

###############################################
# Stage 2: Final image - Minimal distribution
###############################################
FROM alpine:3.17

# Create a non-root user
RUN addgroup -S protouser && adduser -S protouser -G protouser

# Create directory structure
WORKDIR /proto

# Copy proto files from builder
COPY --from=builder --chown=protouser:protouser /build/proto/ /proto/

# Copy generated code for each language
COPY --from=builder --chown=protouser:protouser /build/gen/ /gen/

# Copy documentation and metadata
COPY --chown=protouser:protouser README.md /

# Switch to non-root user
USER protouser

# Add metadata
LABEL org.opencontainers.image.source="https://github.com/snagdy/finance-protos"
LABEL org.opencontainers.image.description="Protocol Buffers definitions for Black-Scholes option pricing"
LABEL org.opencontainers.image.licenses="MIT"

# Default command just shows information about the image
CMD ["cat", "/README.md"]