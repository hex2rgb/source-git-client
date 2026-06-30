FROM yanwk/comfyui-boot:cu130-slim-v2

# 下载并安装 Noto Sans CJK SC 独立 OTF 字体（PIL 兼容性好）
RUN mkdir -p /usr/share/fonts/opentype/noto-cjk-sc && \
    curl -L -o /tmp/NotoSansCJKsc.zip \
      "https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/03_NotoSansCJKsc.zip" && \
    python3 -c "
import zipfile, os, shutil
with zipfile.ZipFile('/tmp/NotoSansCJKsc.zip') as z:
    z.extractall('/tmp/NotoSansCJKsc')
srcdir = '/tmp/NotoSansCJKsc'
dstdir = '/usr/share/fonts/opentype/noto-cjk-sc'
for f in os.listdir(srcdir):
    if f.endswith('.otf'):
        shutil.copy2(os.path.join(srcdir, f), os.path.join(dstdir, f))
shutil.rmtree('/tmp/NotoSansCJKsc')
os.remove('/tmp/NotoSansCJKsc.zip')
" && \
    fc-cache -fv
