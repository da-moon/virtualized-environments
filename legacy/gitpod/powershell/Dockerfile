# syntax = docker/dockerfile-upstream:master-labs
#-*-mode:dockerfile;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=dockerfile tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

FROM fjolsvin/gitpod-base:latest
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND=noninteractive
#
# ────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   D E P E N D E N C I E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────
#

ENV POWERSHELL_DEPENDENCIES="\
  less \
  locales \
  ca-certificates \
  libicu63 \
  libssl1.1 \
  libc6 \
  libgcc1 \
  libgssapi-krb5-2 \
  liblttng-ust0 \
  libstdc++6 \
  zlib1g \
  curl\
  "
RUN set -ex && \
  sudo install-packages ${POWERSHELL_DEPENDENCIES}
#
# ──────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: S T A R S H I P   I N S T A L L : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  curl -fsSl https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/starship | bash
#
# ────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: I N S T A L L I N G   P O W E R S H E L L : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────
#
ENV RELEASES_URL="https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
ARG CPU_ARCH="amd64"
RUN set -ex && \
  curl -fsSL "${RELEASES_URL}" | jq -r ".assets[]|\
  select(\
  .browser_download_url | (\
  contains(\"$(lsb_release -is | tr '[[:upper:]]' '[[:lower:]]')\") and \
  contains(\"$(lsb_release -rs)\") and \
  contains(\"${CPU_ARCH}\") and \
  (contains(\"sha256\") | not)\
  )\
  ).browser_download_url" | xargs -I {} wget --quiet --no-cache -O /tmp/powershell.deb {}
RUN set -ex && \
  sudo dpkg -i /tmp/powershell.deb
#
# ──────────────────────────────────────────────────────── I ──────────
#   :::::: C L E A N   U P : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  sudo apt-get autoremove -y && \
  sudo apt-get clean -y && \
  sudo rm -rf "/tmp/*"
#
# ──────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: P O W E R S H E L L   C O N F I G U R A T I O N : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────
#
RUN set -ex && \
  sudo usermod --shell /usr/bin/pwsh "${USER}"
ENV SHELL="/usr/bin/pwsh "
SHELL [ "/usr/bin/pwsh" ,"-NoLogo","-NoProfile ","-c"]
RUN Install-module Pester -Scope CurrentUser -Force -MaximumVersion 4.99
RUN New-Item -ItemType Directory -Path "$(Split-Path -parent $PROFILE.CurrentUserAllHosts)" -Force -ErrorAction Stop
RUN 'Invoke-Expression (&starship init powershell)' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
SHELL [ "/bin/bash" , "-c"]
ENTRYPOINT [ "/usr/bin/pwsh" ]
