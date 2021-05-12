
ARG USER=rust
ENV USER $USER
ENV HOME=/home/${USER}
ENV LANG=en_US.UTF-8
USER ${USER}
RUN mkdir -p /${HOME}/libs /${HOME}/src /${HOME}/.cargo && \
  ln -s /opt/rust/cargo/config /${HOME}/.cargo/config
WORKDIR /${HOME}/src
RUN export DEBIAN_FRONTEND=noninteractive; \
  sudo apt-get update && \
  sudo apt-get install -y apt-utils && \
  sudo apt-get install -y findutils coreutils binutils \
  curl aria2 wget bash build-essential git \
  rename make sudo ncdu jq upx && \
  sudo apt-get upgrade -y
RUN export DEBIAN_FRONTEND=noninteractive; \
  sudo apt-get autoremove -y && \
  sudo apt-get clean -y && \
  sudo rm -rf "/tmp/*"
RUN echo 'if [ -e /var/run/docker.sock ]; then sudo chown "$(id -u):$(id -g)" /var/run/docker.sock; fi' >> "/${HOME}/.bashrc"
