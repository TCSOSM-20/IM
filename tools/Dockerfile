# Copyright 2019 Whitestack LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM alpine

WORKDIR /src

RUN apk update && apk add --update --no-cache git bash util-linux grep
RUN git clone https://osm.etsi.org/gerrit/osm/RO.git
RUN git clone https://osm.etsi.org/gerrit/osm/devops.git
RUN git clone https://osm.etsi.org/gerrit/osm/LCM.git
RUN git clone https://osm.etsi.org/gerrit/osm/NBI.git
RUN git clone https://osm.etsi.org/gerrit/osm/POL.git
RUN wget https://raw.githubusercontent.com/gdbtek/linux-cookbooks/master/libraries/util.bash

COPY /src /src

RUN /bin/bash scanModules.sh