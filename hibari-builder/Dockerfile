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

#
# This Dockerfile does not install Thrift IDL Compiler. Use Arch Linux
# version if you need it.
#

FROM quay.io/tatsuya6502/erlang:centos6-multi-otp
MAINTAINER Tatsuya Kawano

# ENV ...

# Install basic utilities
RUN (yum -y install expect openssh-clients screen strace sudo which && \
# Install packages to build Hibari (HyperLevelDB or RocketDB, since v0.3)
     yum -y install gcc-c++ libtool)

# Install Python 2 (required by repo)
# RUN yum -y install python

# Install the latest automake (required by snappy)
RUN (cd /tmp && \
     wget http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz && \
     tar xvf automake-1.15.tar.gz && \
     cd automake-1.15 && \
     ./configure --prefix=/usr && \
     make && \
     make install && \
     cd .. && \
     rm -rf audomake-*)

# Create a user for clus tool
RUN (useradd -m clus && \
     echo "clus:ChangeMe_0" | chpasswd && \
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

# Copy kerl status from /root/.kerl to /home/clus/.kerl
RUN mkdir -p /home/clus/.kerl && \
    cp -p /root/.kerl/otp_* /home/clus/.kerl && \
    chown -R clus:clus /home/clus/.kerl

USER clus

# Add scripts
ADD ./bin /home/clus/bin
RUN (sudo chown -R clus:clus /home/clus/bin && \
     chmod +x /home/clus/bin/*)

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
     /usr/local/bin/repo init -u git://github.com/hibari/manifests.git -m hibari-default.xml -b master && \
     /usr/local/bin/repo sync && \
     (/usr/local/bin/repo forall -c "git checkout master" || true) && \
     /usr/local/bin/repo status)

# Build Hibari
RUN (source /usr/local/erlang/17.5.6.3_hipe/activate && \
     cd /home/clus/hibari/hibari && \
     make package)

# CMD
