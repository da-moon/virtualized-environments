FROM gitpod/workspace-full
USER root
ARG APT_PACKAGES="\
    dropbear\
    "
RUN \
    set -ex; \
    install-packages ${APT_PACKAGES}
RUN curl https://i.jpillora.com/chisel! | bash
