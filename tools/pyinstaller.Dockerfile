FROM python:rc-alpine
USER root
RUN set -ex && \
  apk -U --no-cache add \
  make gcc musl-dev libffi-dev openssl-dev zlib-dev cmocka-dev \
  git
RUN set -ex && \
  sudo python3 -m pip install pycrypto
# ─── BUILD PYTHON-INSTALLER WITH BOOTLOADER FOR MUSL ────────────────────────────
USER "$USER"
RUN set -ex && \
  git clone \
  --depth 1 \
  --single-branch \
  --branch \
  master https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller 
WORKDIR /tmp/pyinstaller/bootloader
RUN set -ex && \
  export CFLAGS="-Wno-stringop-overflow -Wno-stringop-truncation"; \
  chmod +x ./waf ; \
  ./waf configure all
RUN set -ex && \
  sudo python3 -m pip install ..
RUN set -ex && \
  rm -rf /tmp/pyinstaller
