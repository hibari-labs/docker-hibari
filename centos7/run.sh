#!/bin/sh

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
##
## File     : brick.erl
## Purpose  : brick top-level application startup
##----------------------------------------------------------------------

docker kill hibari6
docker kill hibari5
docker kill hibari4
docker kill hibari3
docker kill hibari2
docker kill hibari1
docker rm hibari6
docker rm hibari5
docker rm hibari4
docker rm hibari3
docker rm hibari2
docker rm hibari1
docker rm hibaribench

docker run -d --name hibari1 -h hibari1 \
           quay.io/hibaridb/hibari-deploy-base:latest-centos7

docker run -d --name hibari2 -h hibari2 \
           quay.io/hibaridb/hibari-deploy-base:latest-centos7

docker run -d --name hibari3 -h hibari3 \
           quay.io/hibaridb/hibari-deploy-base:latest-centos7

docker run -d --name hibari4 -h hibari4 \
           quay.io/hibaridb/hibari-deploy-base:latest-centos7

docker run -d --name hibari5 -h hibari5 \
           quay.io/hibaridb/hibari-deploy-base:latest-centos7

docker run -d --name hibari6 -h hibari6 \
           quay.io/hibaridb/hibari-deploy-base:latest-centos7

docker run -it --name hibaribench -h hibaribench \
           --link=hibari1:hibari1 \
           --link=hibari2:hibari2 \
           --link=hibari3:hibari3 \
           --link=hibari4:hibari4 \
           --link=hibari5:hibari5 \
           --link=hibari6:hibari6 \
           quay.io/hibaridb/hibari:dev-otp17-centos7 bash
