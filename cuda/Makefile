make:

make clean:

make install:
	# Set environment variables required by the CUDA toolkit
	install -Dm0644 assets/system76-cuda.sh   $(DESTDIR)/etc/profile.d/system76-cuda.sh
	install -Dm0644 assets/system76-cuda.conf $(DESTDIR)/etc/ld.so.conf.d/system76-cuda.conf
