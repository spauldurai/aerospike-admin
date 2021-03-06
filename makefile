# Copyright 2013-2018 Aerospike, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

OS = $(shell uname)
SOURCE_ROOT = $(realpath .)
BUILD_ROOT = $(SOURCE_ROOT)/build/
INSTALL_ROOT = /opt/aerospike/bin/
SYMLINK = /usr/bin/asadm
INSTALL_USER = aerospike
INSTALL_GROUP = aerospike
INSTALL = "install -o aerospike -g aerospike"

REQUIREMENT_FILE = $(SOURCE_ROOT)/requirements.txt

LINUX_VERSION = ""
ifeq ($(OS),Linux)
	LINUX_VERSION = $(shell build/os_version)
endif

SHELL := /bin/bash

define make_build
	mkdir -p $(BUILD_ROOT)tmp
	mkdir -p $(BUILD_ROOT)bin
	rm -rf $(BUILD_ROOT)tmp/*
	rm -rf $(BUILD_ROOT)bin/*
	rm -f `find . -type f -name '*.pyc' | xargs`
	mkdir $(BUILD_ROOT)tmp/asadm
	cp -f *.py $(BUILD_ROOT)tmp/asadm
	rsync -aL lib $(BUILD_ROOT)tmp/asadm

	$(if $(filter $(LINUX_VERSION),el6),
	sed -i 's/\/usr\/bin\/env python/\/usr\/bin\/env python2.7/' $(BUILD_ROOT)tmp/asadm/asadm.py
	)

	$(if $(filter $(OS),Darwin),
	sed -i "" s/[$$][$$]__version__[$$][$$]/`git describe`/g $(BUILD_ROOT)tmp/asadm/asadm.py,
	sed -i s/[$$][$$]__version__[$$][$$]/`git describe`/g $(BUILD_ROOT)tmp/asadm/asadm.py
	)

endef

all:
	$(call make_build)

	mkdir -p $(BUILD_ROOT)tmp/wheels
	pip wheel -w $(BUILD_ROOT)tmp/asadm $(BUILD_ROOT)tmp/asadm
	pip wheel --no-cache-dir --wheel-dir=$(BUILD_ROOT)tmp/wheels -r $(REQUIREMENT_FILE)
	cp $(BUILD_ROOT)tmp/asadm/*.whl $(BUILD_ROOT)tmp/wheels

ifneq ($(PYUCS2PATH),)
	$(PYUCS2PATH) -m pip wheel --no-cache-dir --wheel-dir=$(BUILD_ROOT)tmp/wheels -r $(REQUIREMENT_FILE)
	pex -v -r $(REQUIREMENT_FILE) --repo=$(BUILD_ROOT)tmp/wheels --platform=linux_x86_64-cp-27-cp27m --platform=linux_x86_64-cp-27-cp27mu --no-pypi --no-build --disable-cache asadm -c asadm.py -o $(BUILD_ROOT)tmp/asadm/asadm.pex
else
	pex -v -r $(REQUIREMENT_FILE) --repo=$(BUILD_ROOT)tmp/wheels --no-pypi --no-build --disable-cache asadm -c asadm.py -o $(BUILD_ROOT)tmp/asadm/asadm.pex
endif

	rm $(BUILD_ROOT)tmp/asadm/*.whl

	mv $(BUILD_ROOT)tmp/asadm/asadm.pex $(BUILD_ROOT)bin/asadm
	chmod ugo+x $(BUILD_ROOT)bin/asadm

no_pex:
	$(call make_build)

	cd $(BUILD_ROOT)tmp/asadm && zip -r ../asadm *
	echo "#!/usr/bin/env python" > $(BUILD_ROOT)bin/asadm
	cat $(BUILD_ROOT)tmp/asadm.zip >> $(BUILD_ROOT)bin/asadm

	chmod ugo+x $(BUILD_ROOT)bin/asadm

install:
	install -o $(INSTALL_USER) -g $(INSTALL_GROUP) -d -m 755 $(INSTALL_ROOT)
	install -o $(INSTALL_USER) -g $(INSTALL_GROUP) -m 755 $(BUILD_ROOT)bin/asadm $(INSTALL_ROOT)asadm
	ln -sf $(INSTALL_ROOT)asadm $(SYMLINK)
