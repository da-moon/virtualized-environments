# syntax = docker/dockerfile:1.0-experimental
FROM debian:buster
EXPOSE 22
USER root
# [NOTE] => installing base packages
RUN export DEBIAN_FRONTEND=noninteractive; \
  apt-get update -qq && \
  apt-get install -yqq sudo apt-utils && \
  apt-get install -yqq \
    wget curl openssh-server \
    openssl ca-certificates gnupg2 \
    locales && \
  locale-gen en_US.UTF-8
# [NOTE] => setting up vagrant user
RUN useradd \
  --no-log-init \
  --uid 1000 \
	--create-home \
  --groups sudo \
	--shell /bin/bash \
  --password `perl -e "print crypt('vagrant','sa');"` \
	vagrant && \
  echo root:vagrant | chpasswd && \
  sed \
    -i.bak \
    -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
    /etc/sudoers
USER vagrant
ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub \
  /home/vagrant/.ssh/authorized_keys
# [NOTE] ssh setup
RUN sudo echo "Running 'sudo' for 'vagrant': success" && \
    sudo chown -R vagrant:vagrant /home/vagrant/.ssh && \
    sudo chmod 0600 /home/vagrant/.ssh/authorized_keys && \
    sudo chmod 0700 /home/vagrant/.ssh && \
    sudo sed \
      -i.bak \
      -e \
   's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' \
    /etc/pam.d/sshd && \
    sudo mkdir /var/run/sshd
RUN export DEBIAN_FRONTEND=noninteractive; \
   sudo apt-get autoclean -y && \ 
   sudo apt-get clean && \
   sudo rm -rf /var/lib/apt/lists/* 
CMD ["sudo","/usr/sbin/sshd", "-D", "-e"]
