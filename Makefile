# Copyright 2017 Sandvine
# Copyright 2017-2018 Telefonica
# All Rights Reserved.
# 
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
# 
#         http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# NOTE: pyang and pyangbind are required for build

.PHONY: all clean package trees deps yang-ietf openapi_schemas yang2swagger
JAVA:=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
PYANG:= pyang
PYBINDPLUGIN:=$(shell /usr/bin/env python3 -c \
	            'import pyangbind; import os; print("{}/plugin".format(os.path.dirname(pyangbind.__file__)))')

YANG_DESC_MODELS := vnfd nsd nst nsi
YANG_RECORD_MODELS := vnfr nsr
PYTHON_MODELS := $(addsuffix .py, $(YANG_DESC_MODELS))
YANG_DESC_TREES := $(addsuffix .tree.txt, $(YANG_DESC_MODELS))
YANG_DESC_JSTREES := $(addsuffix .html, $(YANG_DESC_MODELS))
YANG_RECORD_TREES := $(addsuffix .rec.tree.txt, $(YANG_RECORD_MODELS))
YANG_RECORD_JSTREES := $(addsuffix .rec.html, $(YANG_RECORD_MODELS))
OPENAPI_SCHEMAS := osm.yaml

OUT_DIR := osm_im
TREES_DIR := osm_im_trees
MODEL_DIR := models/yang
Q?=@

PYANG_OPTIONS := -Werror

all: $(PYTHON_MODELS) trees openapi_schemas
	$(MAKE) package

trees: $(YANG_DESC_TREES) $(YANG_DESC_JSTREES) $(YANG_RECORD_TREES) $(YANG_RECORD_JSTREES)

openapi_schemas: $(OPENAPI_SCHEMAS)

$(TREES_DIR):
	$(Q)mkdir -p $(TREES_DIR)

%.py: yang-ietf
	$(Q)echo generating $@ from $*.yang
	$(Q)pyang $(PYANG_OPTIONS) --path $(MODEL_DIR) --plugindir $(PYBINDPLUGIN) -f pybind -o $(OUT_DIR)/$@ $(MODEL_DIR)/$*.yang

%.tree.txt: $(TREES_DIR) yang-ietf
	$(Q)echo generating $@ from $*.yang
	$(Q)pyang $(PYANG_OPTIONS) --path $(MODEL_DIR) -f tree -o $(TREES_DIR)/$@ $(MODEL_DIR)/$*.yang

%.html: $(TREES_DIR) yang-ietf
	$(Q)echo generating $@ from $*.yang
	$(Q)pyang $(PYANG_OPTIONS) --path $(MODEL_DIR) -f jstree -o $(TREES_DIR)/$@ $(MODEL_DIR)/$*.yang
	$(Q)sed -r -i 's|data\:image/gif\;base64,R0lGODlhS.*RCAA7|https://osm.etsi.org/images/OSM-logo.png\" width=\"175\" height=\"60|g' $(TREES_DIR)/$@
	$(Q)sed -r -i 's|<a href=\"http://www.tail-f.com">|<a href="http://osm.etsi.org">|g' $(TREES_DIR)/$@

%.rec.tree.txt: $(TREES_DIR) yang-ietf
	$(Q)echo generating $@ from $*.yang
	$(Q)pyang $(PYANG_OPTIONS) --path $(MODEL_DIR) -f tree -o $(TREES_DIR)/$@ $(MODEL_DIR)/$*.yang
	$(Q)mv $(TREES_DIR)/$@ $(TREES_DIR)/$*.tree.txt

%.rec.html: $(TREES_DIR) yang-ietf
	$(Q)echo generating $@ from $*.yang
	$(Q)pyang $(PYANG_OPTIONS) --path $(MODEL_DIR) -f jstree -o $(TREES_DIR)/$@ $(MODEL_DIR)/osm-project.yang $(MODEL_DIR)/$*.yang
	$(Q)sed -r -i 's|data\:image/gif\;base64,R0lGODlhS.*RCAA7|https://osm.etsi.org/images/OSM-logo.png\" width=\"175\" height=\"60|g' $(TREES_DIR)/$@
	$(Q)sed -r -i 's|<a href=\"http://www.tail-f.com">|<a href="http://osm.etsi.org">|g' $(TREES_DIR)/$@
	$(Q)mv $(TREES_DIR)/$@ $(TREES_DIR)/$*.html

osm.yaml: yang-ietf yang2swagger
	$(Q)echo generating $@
	$(Q)$(JAVA) -jar ${HOME}/.m2/repository/com/mrv/yangtools/swagger-generator-cli/1.1.11/swagger-generator-cli-1.1.11-executable.jar -yang-dir $(MODEL_DIR) -output $(OUT_DIR)/$@

yang-ietf:
	$(Q)wget -q https://raw.githubusercontent.com/YangModels/yang/master/standard/ietf/RFC/ietf-yang-types%402013-07-15.yang -O models/yang/ietf-yang-types.yang
	$(Q)wget -q https://raw.githubusercontent.com/YangModels/yang/master/standard/ietf/RFC/ietf-inet-types%402013-07-15.yang -O models/yang/ietf-inet-types.yang

yang2swagger:
	$(Q)mkdir -p ${HOME}/.m2
	$(Q)wget -q -O ${HOME}/.m2/settings.xml https://raw.githubusercontent.com/opendaylight/odlparent/master/settings.xml
	git clone https://github.com/bartoszm/yang2swagger.git
	git -C yang2swagger checkout tags/1.1.11
	mvn -f yang2swagger/pom.xml clean install

package:
	tox -e build
	./build-docs.sh

deps:
	$(Q)sudo apt-get -y install git make wget python python-pip debhelper dh-make tox python3 python3-pip maven
	$(Q)sudo -H python3 -m pip install -U pip
	$(Q)sudo -H python2 -m pip install -U pip
	$(Q)sudo -H python3 -m pip install -U pyang pyangbind stdeb
	$(Q)sudo -H python2 -m pip install -U pyang pyangbind stdeb
	$(Q)mkdir -p ~/.m2
	$(Q)cp -n ~/.m2/settings.xml ~/.m2/settings.xml.orig ; wget -q -O - https://raw.githubusercontent.com/opendaylight/odlparent/master/settings.xml > ~/.m2/settings.xml

clean:
	$(Q)rm -rf dist osm_im.egg-info deb deb_dist *.gz osm-imdocs* yang2swagger $(TREES_DIR)
