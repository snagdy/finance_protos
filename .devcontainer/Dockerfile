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
        apt-transport-https \
        gnupg \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
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
WORKDIR /workspaces/finance_protos