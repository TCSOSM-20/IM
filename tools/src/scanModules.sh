#!/bin/bash
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

. ./util.bash --source-only

VNFD="vnfd-catalog"
NSD="nsd-catalog"

> search_results.txt
> statistics.txt
echo "(pattern),(version),RO,devops,NBI,POL,LCM" &> statistics.txt 

MODULES=("RO" "devops" "NBI" "POL" "LCM")

grep -r --exclude=*.txt $VNFD . &>> search_results.txt
grep -r --exclude=*.txt $NSD . &>> search_results.txt

generateStatistics(){ #1: $VNFD or $NSD, 2: commit tag
    STATISTICS="$1,$2"
    for i in  "${MODULES[@]}"
    do
        STATISTICS="$STATISTICS,$(grep -F ./$i/ search_results.txt | grep $1 | wc -l)"
    done
    echo $STATISTICS &>>statistics.txt
}

generateStatistics $VNFD "latest"
generateStatistics $NSD "latest"

COLOR='\033[0;31m'
echo -e "${COLOR}-- Number of ocurrences of a pattern in each module for a specific version --"

printTable ',' "$(cat statistics.txt)" true
