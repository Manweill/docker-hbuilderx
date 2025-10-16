FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /opt

# 安装系统工具和依赖
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        tar \
        git \
        sudo \
        libglib2.0-0 \
        libkrb5-3 \
        libgssapi-krb5-2 \
        libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 nvm 和 Node.js
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=20.19.0

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default



# 复制并解压 HBuilderX
COPY hbuilderx/HBuilderX.4.76.2025082103.linux_x64.full.tar.gz /usr/local/
RUN cd /usr/local && \
    tar -xzf HBuilderX.4.76.2025082103.linux_x64.full.tar.gz -C . && \
    mv HBuilderX hbuilderx-linux && \
    rm HBuilderX.4.76.2025082103.linux_x64.full.tar.gz

# 创建非 root 用户并设置权限
RUN groupadd -r hx && useradd -r -g hx -m -d /home/hx -s /bin/bash hx || true \
    && usermod -aG sudo hx \
    && echo "hx ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R hx:hx $NVM_DIR \
    && chown -R hx:hx /usr/local/hbuilderx-linux

# 设置 Node.js 环境变量
ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules \
    PATH=/usr/local/hbuilderx-linux:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

USER hx
WORKDIR /home/hx

# 为 hx 用户设置 nvm
RUN echo 'export NVM_DIR="/opt/nodejs/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

RUN npm install -g uapp && \
    uapp sdk init && \
    uapp config node `which node` && \
    uapp config hbx.dir /usr/local/hbuilderx-linux

CMD ["bash"]
    