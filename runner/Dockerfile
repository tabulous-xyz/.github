# check=skip=InvalidDefaultArgInFrom

ARG DOCKER_BASE_IMAGE_URI
ARG PYTHON_VERSION=3.10.10

FROM $DOCKER_BASE_IMAGE_URI

WORKDIR /runner

ARG RUNNER_VERSION="2.323.0"
ARG RUNNER_ARCH="x64"

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies

RUN groupadd --gid 1001 runner \
  && useradd --uid 1001 --gid runner --shell /bin/bash --create-home runner

RUN apt-get update && apt-get install -y --no-install-recommends \
    amazon-ecr-credential-helper \
    build-essential \
    ca-certificates \
    curl \
    fonts-liberation \
    gh \
    git \
    git-lfs \
    gnupg \
    gosu \
    jq \
    # libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libbz2-dev \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libffi-dev \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-4-dev \
    liblzma-dev \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libssl-dev \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    locales \
    lsb-release \
    musl-tools \
    openssh-client \
    software-properties-common \
    unzip \
    wget \
    zlib1g-dev \
    libasound2-dev \
    libicu-dev \
    pkg-config \
    uuid-runtime \
  # Python packages will be installed after adding PPA
  && add-apt-repository -y ppa:deadsnakes/ppa \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates

RUN locale-gen en_US.UTF-8

# Install Node.js 20
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update \
  && apt-get install -y --no-install-recommends nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install BuildKit

ARG BUILDKIT_VERSION="0.13.2"
RUN set -e; \
  curl -L -o buildkit.tar.gz "https://github.com/moby/buildkit/releases/download/v${BUILDKIT_VERSION}/buildkit-v${BUILDKIT_VERSION}.linux-amd64.tar.gz"; \
  tar -xzf buildkit.tar.gz -C /usr/local; \
  rm buildkit.tar.gz; \
  chmod +x /usr/local/bin/buildctl /usr/local/bin/buildkitd; \
  /usr/local/bin/buildctl --version; \
  /usr/local/bin/buildkitd --help > /dev/null; \
  echo "BuildKit v${BUILDKIT_VERSION} installed successfully";

# Install containerd (runtime)
ARG CONTAINERD_VERSION="1.7.18"
RUN set -e; \
  curl -L -o containerd.tar.gz "https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"; \
  tar -xzf containerd.tar.gz -C /usr/local; \
  rm containerd.tar.gz; \
  /usr/local/bin/containerd --version; \
  echo "containerd v${CONTAINERD_VERSION} installed successfully";

RUN curl -fSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

# Install Rustup/Cargo/sccache
ENV RUSTUP_HOME=/runner/.rustup
ENV CARGO_HOME=/runner/.cargo
ENV PATH="/runner/.rustup/bin:/runner/.cargo/bin:${PATH}"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  && . "/runner/.cargo/env" \
  && rustup toolchain install stable \
  && rustup target add x86_64-unknown-linux-musl \
  && rustup target add wasm32-unknown-unknown \
  && cargo install cargo-edit

ARG SCCACHE_VERSION="0.10.0"
RUN curl -Lo sccache.tar.gz https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz \
  && tar -xzf sccache.tar.gz \
  && mkdir -p /usr/local/bin \
  && mv sccache-v${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache /usr/local/bin/sccache \
  && chmod +x /usr/local/bin/sccache \
  && rm -rf sccache.tar.gz sccache-v${SCCACHE_VERSION}-x86_64-unknown-linux-musl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV RUSTC_WRAPPER=/usr/local/bin/sccache \
    SCCACHE_GHA_ENABLED=on

# Download and extract the GitHub Actions runner
RUN curl -L -o actions-runner.tar.gz "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" && \
  tar xzf ./actions-runner.tar.gz && \
  rm ./actions-runner.tar.gz && \
  ./bin/installdependencies.sh

ARG ECR_CRED_HELPER_VERSION="0.9.1"
RUN curl -Lo /usr/local/bin/docker-credential-ecr-login "https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/${ECR_CRED_HELPER_VERSION}/linux-amd64/docker-credential-ecr-login" && \
    chmod +x /usr/local/bin/docker-credential-ecr-login

# Global npm configuration (as root)
RUN npm config set cache /runner/.npm --global \
    && npm config set fund false --global

RUN chown -R runner:runner /runner

USER root

# NODE

COPY --chown=runner:runner \
  package.json package-lock.json ./

RUN npm install

# PYTHON

RUN python3.10 -m venv /runner/.venv

COPY --chown=runner:runner \
  Pipfile Pipfile.lock ./

ENV PIPENV_VENV_IN_PROJECT=1

RUN /runner/.venv/bin/pip install --upgrade pip && \
    /runner/.venv/bin/pip install pipenv && \
    /runner/.venv/bin/pipenv sync

COPY --chown=runner:runner \
  runner/entrypoint.sh /runner/entrypoint.sh
RUN chmod +x /runner/entrypoint.sh

ENTRYPOINT ["/runner/entrypoint.sh"]
