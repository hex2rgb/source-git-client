FROM yanwk/comfyui-boot:cu130-slim-v2

# 安装中文字体（PIL 兼容性好）
COPY fonts/ /usr/share/fonts/truetype/Noto_Sans_SC/
RUN fc-cache -fv || echo "fc-cache not available, skipping"
