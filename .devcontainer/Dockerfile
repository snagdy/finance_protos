FROM mcr.microsoft.com/vscode/devcontainers/base:debian-11

# Install packages needed for protobuf development
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
        protobuf-compiler \
        python3-pip \
        python3-dev \
        curl \
        unzip \
        git \
        build-essential \
        cmake \
        clang-format \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install protoc plugins for various languages
RUN pip3 install grpcio-tools

# Install buf for modern protobuf workflow (optional but recommended)
RUN BUF_VERSION="1.30.0" \
    && curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" -o /usr/local/bin/buf \
    && chmod +x /usr/local/bin/buf

# Create a non-root user with sudo access
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN getent group $USER_GID || groupadd --gid $USER_GID $USERNAME \
    && id -u $USERNAME &>/dev/null || useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME


# Set up development environment and permissions
WORKDIR /workspaces/option-pricing-protos