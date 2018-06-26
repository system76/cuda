CUDA_VERSION = 9.2
SCRIPT = installer

REMOTE_CUDA_DIR = https://developer.nvidia.com/compute/cuda/$(CUDA_VERSION)/Prod
INSTALLER_URL = $(REMOTE_CUDA_DIR)/local_installers/cuda_9.2.88_396.26_linux
CUDA_DIR = cuda-$(CUDA_VERSION)

PREFIX ?= /usr/local
BEFORE := $(shell echo $(DESTDIR)$(PREFIX) | sed 's/\//\\\//g')
AFTER := $(shell echo $(PREFIX) | sed 's/\//\\\//g')

.PHONY: all clean install

all:
	# Download the installer if it does not already exist, or has an invalid checksum
	if [ ! -f $(SCRIPT) ] || ! md5sum -c checksum; then \
		wget $(INSTALLER_URL) -O $(SCRIPT); \
		if ! md5sum -c checksum; then \
			echo installer checksum does not match; \
			exit 1; \
		fi \
	fi

clean:

install:
	./$(SCRIPT) --silent \
		--no-opengl-libs --no-drm \
		--toolkit --toolkitpath=$(DESTDIR)$(PREFIX)/$(CUDA_DIR) \
		--samples --samplespath=$(DESTDIR)$(PREFIX)/$(CUDA_DIR)/samples

	# Fix the paths due to the packaging destination differing from the actual system destination.
	find $(DESTDIR)$(PREFIX)/$(CUDA_DIR) -type f -exec sed -i -e 's/$(BEFORE)/$(AFTER)/g' '{}' \;

	# Set environment variables required by the CUDA toolkit
	install -Dm0644 assets/system76-cuda.sh   $(DESTDIR)/etc/profile.d/system76-cuda.sh
	install -Dm0644 assets/system76-cuda.conf $(DESTDIR)/etc/ld.so.conf.d/system76-cuda.conf
