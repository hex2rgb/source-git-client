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
    git \
    locales \
    nano \
    openssh-client \
    vim-tiny \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  grep -q '^users:x:100:' /etc/group \
  && useradd --uid 99 --gid 100 --home-dir /home/git --create-home --shell /bin/bash git \
  && test "$(id -u git)" = "99" \
  && test "$(id -g git)" = "100" \
  && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && sed -i 's/^# *\(zh_CN.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && mkdir -p /workspace /home/git/.ssh \
  && printf '%s\n' \
    'if [ -f /etc/profile.d/bash_completion.sh ]; then' \
    '  . /etc/profile.d/bash_completion.sh' \
    'fi' \
    'export EDITOR=vim' \
    > /home/git/.bashrc \
  && chown -R git:users /workspace /home/git

USER git
ENV HOME=/home/git
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh:en_US:en
ENV LC_ALL=zh_CN.UTF-8
ENV EDITOR=vim
WORKDIR /workspace

CMD ["sleep", "infinity"]
