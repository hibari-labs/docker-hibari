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

FROM quay.io/tatsuya6502/erlang:archlinux-multi-otp
MAINTAINER Tatsuya Kawano

# Install basic utilities
RUN (pacman -S --noconfirm expect openssh screen strace sudo tmux which && \
# Install packages to build Hibari (HyperLevelDB or RocketDB, since v0.3)
     pacman -S --noconfirm automake libtool)

# Create a user for clus tool
RUN (useradd -m clus && \
     echo "clus:ChangeMe0!" | chpasswd && \
     su clus -c "mkdir -p /home/clus/.ssh" && \
     su clus -c "touch /home/clus/.ssh/authorized_keys" && \
     chmod 700 /home/clus/.ssh && \
     chmod 600 /home/clus/.ssh/authorized_keys)

# Add clus to sudoers and disable requiretty for it
ADD ./999-sudoers-clus /etc/sudoers.d/999-sudoers-clus
RUN chmod 440 /etc/sudoers.d/999-sudoers-clus

# ssh StrictHostKeyChecking=no
ADD ./ssh_config /root/.ssh/config
ADD ./ssh_config /home/clus/.ssh/config
RUN (chown clus:clus /home/clus/.ssh/config && \
     chmod 644 /root/.ssh/config && \
     chmod 644 /home/clus/.ssh/config)

# Install Python 2 and make it the default for users (required by repo)
RUN pacman -S --noconfirm python2
RUN (mkdir /root/bin && \
     ln -s /usr/bin/python2 /root/bin/python && \
     ln -s /usr/bin/python2-config /root/bin/python-config && \
     echo "export PATH=~/bin:$PATH" > /root/.bashrc)
RUN (mkdir /home/clus/bin; \
     ln -s /usr/bin/python2 /home/clus/bin/python && \
     ln -s /usr/bin/python2-config /home/clus/bin/python-config && \
     echo "export PATH=~/bin:$PATH" > /home/clus/.bashrc)

# Copy kerl status from /root/.kerl to /home/clus/.kerl
RUN (mkdir -p /home/clus/.kerl && \
     cp -p /root/.kerl/otp_* /home/clus/.kerl && \
     chown -R clus:clus /home/clus/.kerl)

# Install Thrift IDL Compiler (without client libraries)
RUN pacman -S --noconfirm thrift

USER clus

# Download Thrift client libraries
RUN git clone https://github.com/apache/thrift.git /home/clus/thrift

# Download Hibari clus tool
RUN git clone https://github.com/hibari/clus.git /home/clus/clus
ADD ./hibari.config /home/worker/hibari.config

# Download Hibari source code
RUN (git config --global user.email "noreply@hibaridb.org" && \
     git config --global user.name "Hibari User")
ADD ./repo /usr/local/bin/repo
RUN sudo chmod a+x /usr/local/bin/repo
RUN (mkdir /home/clus/hibari && \
     cd /home/clus/hibari && \
     source /home/clus/.bashrc && \
     /usr/local/bin/repo init -u git://github.com/hibari/manifests.git -m hibari-default.xml -b dev && \
     /usr/local/bin/repo sync && \
     (/usr/local/bin/repo forall -c "git branch dev origin/dev" || true) && \
     (/usr/local/bin/repo forall -c "git checkout dev" || true) && \
     /usr/local/bin/repo status)

# Build Hibari
RUN (source /usr/local/erlang/17.5.6.3_hipe/activate && \
     cd /home/clus/hibari/hibari; make package)
