ARG DOCKER_BASE_IMAGE_URI
ARG RUST_VERSION=1.27.1

FROM $DOCKER_BASE_IMAGE_URI

WORKDIR /workflow

ENV DEBIAN_FRONTEND=noninteractive

ENV RUSTUP_HOME=/workflow/.rustup

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && /root/.cargo/bin/rustup toolchain install stable \
    && /root/.cargo/bin/rustup target add x86_64-unknown-linux-musl \
    && /root/.cargo/bin/rustup target add wasm32-unknown-unknown \
    && /root/.cargo/bin/cargo install cargo-edit

RUN SCCACHE_VERSION="v0.10.0" \
    && wget -O sccache.tar.gz https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf sccache.tar.gz \
    && mv sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache /usr/local/bin/sccache \
    && chmod +x /usr/local/bin/sccache \
    && rm -rf sccache.tar.gz sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl

ENV RUSTC_WRAPPER=/usr/local/bin/sccache \
    SCCACHE_GHA_ENABLED=on    
    
RUN curl -fsSL https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 --exclude="README.md" --exclude="LICENSE" --exclude="ChangeLog" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

COPY package.json package-lock.json ./

RUN npm config set cache /root/.npm --global \
    && npm config set fund false --global \
    && npm install \
    && npx -y playwright@1.49.1 install --with-deps

RUN wget -N https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.88/linux64/chrome-linux64.zip \
    && unzip chrome-linux64.zip -d /usr/local/ \
    && rm chrome-linux64.zip \
    && ln -s /usr/local/chrome-linux64/chrome /usr/local/bin/chrome

RUN wget -N https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.88/linux64/chromedriver-linux64.zip \
    && unzip chromedriver-linux64.zip -d /usr/local/ \
    && rm chromedriver-linux64.zip \
    && ln -s /usr/local/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver

RUN curl -sL https://sentry.io/get-cli/ | bash

RUN wget -O /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.16/terragrunt_linux_amd64 \
    && chmod +x /usr/local/bin/terragrunt

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip \
    && unzip terraform.zip -d /usr/local/bin/ \
    && rm terraform.zip

ENV NPM_CONFIG_PREFIX=/root/.npm \
    DOCKER_CONFIG=/workflow/.docker \
    CARGO_HOME=/root/.cargo \
    LANG=en_US.UTF-8 \
    PATH="/root/.cargo/bin:/usr/local/bin:$PATH"
