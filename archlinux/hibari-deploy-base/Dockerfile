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
RUN (pacman -Syu --noconfirm; \
# Install basic utilities
     pacman -S --noconfirm ngrep openssh strace sudo tmux; \
# Install required libraries for Erlang/OTP runtime
     pacman -S --noconfirm ncurses openssl)

# Generate sshd host keys
RUN (ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key; \
     ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key; \
     sed -ri 's/UseDNS yes/#UseDNS yes/g' /etc/ssh/sshd_config; \
     echo "UseDNS no" >> /etc/ssh/sshd_config)
#     sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config; \
#     sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config)

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

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
