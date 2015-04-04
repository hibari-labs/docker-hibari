##----------------------------------------------------------------------
## Copyright (c) 2015 Hibari developers.  All rights reserved.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##----------------------------------------------------------------------

FROM quay.io/tatsuya6502/archlinux-x86_64
MAINTAINER Tatsuya Kawano

# ENV ...

# Update preinstalled packages
RUN pacman -Syu --noconfirm

# Install basic utilities
RUN pacman -S --noconfirm curl git make ngrep openssh strace sudo tmux wget

# Create a user for clus tool
RUN (useradd -m clus; \
     echo "clus:ChangeMe0!" | chpasswd; \
     su clus -c "mkdir -p /home/clus/.ssh"; \
     su clus -c "touch /home/clus/.ssh/authorized_keys"; \
     chmod 700 /home/clus/.ssh; \
     chmod 600 /home/clus/.ssh/authorized_keys)

# Add clus to sudoers and disable requiretty for it
ADD ./999-sudoers-clus /etc/sudoers.d/999-sudoers-clus
RUN chmod 440 /etc/sudoers.d/999-sudoers-clus

# Install Python 2 and make it the default for users
# (Python 2 is required by repo)
RUN pacman -S --noconfirm python2
RUN (mkdir /root/bin; \
     ln -s /usr/bin/python2 /root/bin/python; \
     ln -s /usr/bin/python2-config /root/bin/python-config; \
     echo "export PATH=~/bin:$PATH" > /root/.bashrc;)
RUN (mkdir /home/clus/bin; \
     ln -s /usr/bin/python2 /home/clus/bin/python; \
     ln -s /usr/bin/python2-config /home/clus/bin/python-config; \
     echo "export PATH=~/bin:$PATH" > /home/clus/.bashrc;)

# Install Erlang/OTP 17 from Arch Linux pacage
RUN pacman -S --noconfirm erlang-nox

# Install Thrift IDL Compiler (without client libraries)
RUN pacman -S --noconfirm thrift

# Download Thrift client libraries
RUN git clone https://github.com/apache/thrift.git /home/clus/thrift

# Download Hibari source code
RUN (git config --global user.email "noreply@hibaridb.org"; \
     git config --global user.name "Hibari User")
RUN (wget -O /usr/local/bin/repo http://commondatastorage.googleapis.com/git-repo-downloads/repo; \
     chmod a+x /usr/local/bin/repo)
RUN (mkdir /home/clus/hibari; \
     cd /home/clus/hibari; \
     source /home/clus/.bashrc; \
     repo init -u git://github.com/hibari/manifests.git -m hibari-default.xml -b master; \
     repo sync; \
     repo forall -c "git branch master origin/master"; \
     repo forall -c "git checkout master"; \
     repo status)

# Build Hibari
RUN (cd /home/clus/hibari/hibari; make package)

# Download Hibari clus tool and set up ssh keys
RUN git clone https://github.com/hibari/clus.git /home/clus/clus

# Download Basho Bench and build it
RUN pacman -S --noconfirm r gcc
RUN (git clone https://github.com/basho/basho_bench.git /home/clus/basho_bench; \
     cd /home/clus/basho_bench; \
     make)

# chown the stuff for clus user
RUN chown -R clus:clus /home/clus/
