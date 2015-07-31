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

FROM centos:centos6
MAINTAINER Tatsuya Kawano

# ENV ...

# Update preinstalled packages
RUN yum -y update

# Install basic utilities
RUN yum -y install curl expect git make openssh-clients strace sudo tar screen wget

# Install packages to build Erlang/OTP
RUN yum -y install gcc glibc-devel make ncurses-devel openssl-devel libtool
# RUN yum -y install gcc glibc-devel make ncurses-devel openssl-devel autoconf

# Install Python (Python 2 is required by repo)
# RUN yum -y install python

# Update git (required by repo)
RUN (yum -y install git; \
     cd /tmp; \
     git clone git://git.kernel.org/pub/scm/git/git.git; \
     yum -y remove git; \
     yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel; \
     yum -y install perl-ExtUtils-MakeMaker; \
     cd git; \
     make prefix=/usr/local all; \
     make prefix=/usr/local install)

# Update autoconf (required by HyperLevelDB)
RUN (cd /tmp; \
     wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz; \
     tar xvf autoconf-2.69.tar.gz; \
     cd autoconf-2.69; \
     ./configure --prefix=/usr; \
     make; \
     make install; \
     cd ..; \
     rm -rf autoconf-*)

# Update automake (required by HyperLevelDB)
RUN (cd /tmp; \
     wget http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz; \
     tar xvf automake-1.15.tar.gz; \
     cd automake-1.15; \
     ./configure --prefix=/usr; \
     make; \
     make install; \
     cd ..; \
     rm -rf audomake-*)

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

# Install Erlang/OTP 17 with kerl
ADD ./kerlrc /root/.kerlrc
ADD ./kerlrc /home/clus/.kerlrc
RUN (cd /home/culs; \
     wget -O /usr/local/bin/kerl https://raw.githubusercontent.com/spawngrid/kerl/master/kerl; \
     chmod a+x /usr/local/bin/kerl; \
     kerl update releases; \
     kerl build 17.5 17.5_hipe; \
     kerl install 17.5_hipe /usr/local/erlang/17.5_hipe)

# Download Thrift client libraries
RUN git clone https://github.com/apache/thrift.git

# Download Hibari source code
RUN (git config --global user.email "noreply@hibaridb.org"; \
     git config --global user.name "Hibari User")
ADD ./repo /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo
RUN (mkdir /home/clus/hibari; \
     cd /home/clus/hibari; \
     repo init -u git://github.com/hibari/manifests.git -m hibari-default.xml -b master; \
     repo sync; \
     repo forall -c "git branch master origin/master"; \
     repo forall -c "git checkout master"; \
     repo status)

# Build Hibari
RUN (source /usr/local/erlang/17.5_hipe/activate; \
     cd /home/clus/hibari/hibari; \
     make package)

# Download Hibari clus tool and set up ssh keys
RUN git clone https://github.com/hibari/clus.git /home/clus/clus

# Download Basho Bench and build it
RUN yum -y install gcc-c++
RUN (git clone https://github.com/basho/basho_bench.git /home/clus/basho_bench; \
     cd /home/clus/basho_bench; \
     source /usr/local/erlang/17.5_hipe/activate; \
     make)

# chown the stuff for clus user
RUN chown -R clus:clus /home/clus/
