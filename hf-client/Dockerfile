FROM debian:bookworm-slim

ARG APT_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/debian
ARG APT_SECURITY_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/debian-security

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
  printf '%s\n' \
    "deb ${APT_MIRROR} bookworm main contrib non-free non-free-firmware" \
    "deb ${APT_MIRROR} bookworm-updates main contrib non-free non-free-firmware" \
    "deb ${APT_SECURITY_MIRROR} bookworm-security main contrib non-free non-free-firmware" \
    > /etc/apt/sources.list \
  && rm -f /etc/apt/sources.list.d/debian.sources

RUN set -eux; \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    bash-completion \
    ca-certificates \
    curl \
    git \
    locales \
    nano \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    tmux \
    vim-tiny \
  && rm -rf /var/lib/apt/lists/*

# HF_HOME is only overridden for this RUN: it keeps the venv baked into the image
# at /opt/hf-cli rather than under /root (unreadable by the non-root hf user) or
# under the /workspace download volume. The runtime value is set further down.
# BIN_DIR=/usr/local/bin so `docker exec hf-client hf ...` works without a login shell.
RUN set -eux; \
  export HF_HOME=/opt/hf-cli HF_CLI_BIN_DIR=/usr/local/bin; \
  curl -LsSf https://hf.co/cli/install.sh | bash

RUN set -eux; \
  grep -q '^users:x:100:' /etc/group \
  && useradd --uid 99 --gid 100 --home-dir /home/hf --create-home --shell /bin/bash hf \
  && test "$(id -u hf)" = "99" \
  && test "$(id -g hf)" = "100" \
  && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && sed -i 's/^# *\(zh_CN.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && ln -sf /usr/bin/bash /usr/bin/sh \
  && mkdir -p /workspace /home/hf/.ssh /home/hf/.cache/huggingface \
  && printf '%s\n' \
    'if [ -f /etc/profile.d/bash_completion.sh ]; then' \
    '  . /etc/profile.d/bash_completion.sh' \
    'fi' \
    'export EDITOR=vim' \
    'export PATH="$HOME/.local/bin:$PATH"' \
    'alias ll="ls -lh"' \
    'alias la="ls -lha"' \
    > /home/hf/.bashrc \
  && chown -R hf:users /workspace /home/hf

USER hf
ENV HOME=/home/hf
ENV HF_HOME=/workspace
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh:en_US:en
ENV LC_ALL=zh_CN.UTF-8
ENV TZ=Asia/Shanghai
ENV EDITOR=vim
WORKDIR /workspace

CMD ["/bin/bash"]