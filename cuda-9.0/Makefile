SCRIPT = installer-$(CUDA_VERSION)
REMOTE_CUDA_DIR = https://developer.nvidia.com/compute/cuda/$(CUDA_VERSION)/Prod
INSTALLER_URL = $(REMOTE_CUDA_DIR)/local_installers/$(INSTALLER)
CUDA_DIR = cuda-$(CUDA_VERSION)

PREFIX ?= /usr/lib
BEFORE := $(shell echo $(DESTDIR)$(PREFIX) | sed 's/\//\\\//g')
AFTER := $(shell echo $(PREFIX) | sed 's/\//\\\//g')

.PHONY: all clean install

all: patches
	# Download the installer if it does not already exist, or has an invalid checksum
	if [ ! -f $(SCRIPT) ] || [ $(shell md5sum $(SCRIPT) | cut -d' ' -f1) != $(INSTALLER_SUM) ]; then \
		wget $(INSTALLER_URL) -O $(SCRIPT); \
		chmod +x $(SCRIPT); \
		if [ $(shell md5sum $(SCRIPT) | cut -d' ' -f1) != $(INSTALLER_SUM) ]; then \
			echo installer checksum does not match; \
			exit 1; \
		fi \
	fi

clean:

patches:
	sh fetch-patches.sh $(REMOTE_CUDA_DIR) $(CUDA_VERSION) $(PATCHES)

install:
	./$(SCRIPT) --silent --override \
		--no-opengl-libs --no-drm \
		--toolkit --toolkitpath=$(DESTDIR)$(PREFIX)/$(CUDA_DIR)

	# Install all of the patches for this version.
	for patch in patch-$(CUDA_VERSION)-*.run; do \
		sh $$patch --accept-eula --silent \
			--installdir=$(DESTDIR)$(PREFIX)/$(CUDA_DIR); \
	done

	# Fix the paths due to the packaging destination differing from the actual system destination.
	find $(DESTDIR)$(PREFIX)/$(CUDA_DIR) -type f \
		-not -name '*.so' -not -name '*.a' \
		-exec sed -i -e 's/$(BEFORE)/$(AFTER)/g; s/usr\/local/$(AFTER)/g' {} \;

	# Set environment variables required by the CUDA toolkit
	install -Dm0644 assets/system76-cuda.sh   $(DESTDIR)/etc/profile.d/system76-cuda.sh
	install -Dm0644 assets/system76-cuda.conf $(DESTDIR)/etc/ld.so.conf.d/system76-cuda.conf

	# Due to an inability to include NVIDIA's samples, we will instead include a script to fetch them.
	install -Dm0755 assets/fetch-cuda-samples $(DESTDIR)$(PREFIX)/$(CUDA_DIR)/bin/fetch-cuda-samples
