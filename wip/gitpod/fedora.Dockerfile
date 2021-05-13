FROM amazonlinux:2017.03

# [ NOTE ] taken from 
# https://raw.githubusercontent.com/bubba-h57/dotfiles/master/Dockerfile
WORKDIR /root

# Lambda is based on 2017.03. Lock YUM to that release version.
RUN sed -i 's/releasever=latest/releaserver=2017.03/' /etc/yum.conf

# Let us do all the yummy stuff up front and be done with it.
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm \
 && yum makecache \
 && yum groupinstall -y "Development Tools"  --setopt=group_package_types=mandatory,default \
    # Group: Development tools
    #  Group-Id: development
    #  Description: A basic development environment.
    #  Mandatory Packages:
    #    +autoconf
    #    +automake
    #    +binutils
    #    +bison
    #    +flex
    #    +gcc
    #    +gcc-c++
    #    +gdb
    #    +gettext
    #    +kexec-tools
    #    +latrace
    #    +libtool
    #     make
    #    +patch
    #     pkgconfig
    #    +rpm-build
    #    +strace
    #    +system-rpm-config
    #    +systemtap-runtime
    #  Default Packages:
    #    +byacc
    #    +crash
    #    +cscope
    #    +ctags
    #    +cvs
    #    +diffstat
    #    +doxygen
    #    +elfutils
    #    +gcc-gfortran
    #    +git
    #    +indent
    #    +intltool
    #    +ltrace
    #    +patchutils
    #    +rcs
    #    +subversion
    #    +swig
    #    +systemtap
    #    +texinfo
    #    +valgrind
 && yum install -y  \
   jq \
   zsh \
   sudo \
   file \
   wget \
   nano \
   fuse \
   htop \
   bzip2 \
   gperf \
   expect \
   man-db \
   gtk-doc \
   gdm-devel \
   libc6-dev \
   gmp-devel \
   docbook2X \
   findutils \
   multitail \
   glibc-devel \
   libicu-devel \
   vim-enhanced \
   python35-pip \
   libdbi-devel \
   libffi-devel \
   gettext-devel \
   readline-devel \
   libevent-devel \
   bash-completion \
   dockbook-utils-pdf \
   asciidoc \
 && yum clean all

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG=en_US.UTF-8

#------------------------------------------------------------------
#
# We will now install a few tools we desire that just were not
# yummy enough for us, for one reason or another.
#
#------------------------------------------------------------------


# Install Ninja and Meson
RUN curl -Ls https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip >> /tmp/ninja.zip \
 && cd /tmp && unzip /tmp/ninja.zip \
 && cp /tmp/ninja /usr/local/bin \
 && /usr/bin/pip-3.5 install meson

# Install the rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# We need a newer cmake than is available, so lets build it ourselves.
RUN mkdir -p /tmp/cmake \
 &&  cd /tmp/cmake \
 && curl -Ls  https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3.tar.gz | tar xzC /tmp/cmake --strip-components=1 \
 && ./bootstrap --prefix=/usr/local \
 && make \
 && make install

### Gitpod user ###
RUN groupadd -f sudo
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && echo '%sudo ALL=NOPASSWD:ALL' >> /etc/sudoers
ENV HOME=/home/gitpod
WORKDIR $HOME
# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success"

# Set some sane environment variables for ourselves
ENV \
    PKG_CONFIG="/usr/bin/pkg-config" \
    SOURCEFORGE_MIRROR="netix" \
    PATH="/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    JQ="/usr/bin/jq" \
    CMAKE='/usr/local/bin/cmake' \
    MESON='/usr/local/bin/meson' \
    NINJA='/usr/local/bin/ninja'

### checks ###
# no root-owned files in the home directory
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit) \
    && { [ -z "$notOwnedFile" ] \
        || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }

# Give back control
USER root
