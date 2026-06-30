FROM yanwk/comfyui-boot:cu130-slim-v2

# 安装 Noto CJK 中文字体（独立 OTF 版，PIL 兼容性好）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-noto-cjk \
        fonts-noto-cjk-extra && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 刷新字体缓存
RUN fc-cache -fv
