DIST_DIR=$(shell pwd)/dist
PKG_CONFIG_DIR=$(shell dirname "$(shell which emcc)")/system/lib/pkgconfig

all: build install

rebuild: clean all

build-zlib:
	cd zlib && \
		emmake make CFLAGS="-O3" -j && \
		emmake make install && \
		cd ..

configure-zlib:
	cd zlib && \
		emconfigure ./configure --prefix=$(DIST_DIR) --64 && \
		cd ..

clean-zlib:
	cd zlib && \
		make clean && \
		cd ..

rebuild-zlib: clean-zlib configure-zlib build-zlib

build-vpx:
	cd libvpx && \
		emmake make -j && \
		emmake make install && \
		cd ..

clean-vpx:
	cd libvpx && \
		make clean && \
		cd ..

configure-vpx:
	cd libvpx && \
		emconfigure ./configure \
			--prefix=$(DIST_DIR) --disable-examples --disable-docs \
			--disable-runtime-cpu-detect --disable-multithread --disable-optimizations \
			--target=generic-gnu --extra-cflags="-O3" && \
			sed -i.bak -e 's/ARFLAGS = -crs$$(if $$(quiet),,v)/ARFLAGS = crs$$(if $$(quiet),,v)/' ./libs-generic-gnu.mk && \
		cd ..

rebuild-vpx: clean-vpx configure-vpx build-vpx

build-openh264:
	cd openh264 && \
		emmake make OS=linux ARCH=asmjs CFLAGS_OPT=-O3 -j && \
		emmake make OS=linux ARCH=asmjs PREFIX=$(DIST_DIR) install-static && \
		cp $(DIST_DIR)/lib/pkgconfig/openh264.pc $(PKG_CONFIG_DIR)
		cd ..

clean-openh264:
	cd openh264 && \
		make clean && \
		cd ..

rebuild-openh264: clean-openh264 build-openh264

build-ffmpeg:
	cd ffmpeg && \
		make -j && \
		make install && \
		cd ..

clean-ffmpeg:
	cd ffmpeg && \
		make clean && \
		cd ..

configure-ffmpeg:
	export PKG_CONFIG_PATH="$(DIST_DIR)/lib/pkgconfig/" && \
	cd ffmpeg && \
		emconfigure ./configure \
			--cc="emcc" --prefix=$(DIST_DIR) \
			--extra-cflags="-I$(DIST_DIR)/include -D_XOPEN_SOURCE=600" \
			--extra-ldflags="-L$(DIST_DIR)/lib" \
			--enable-cross-compile --target-os=none --arch=x86_64 --cpu=generic \
			--disable-ffplay --disable-ffprobe --disable-ffserver --disable-asm --disable-doc --disable-devices --disable-pthreads --disable-w32threads \
			--disable-network --disable-runtime-cpudetect \
			--disable-hwaccels --disable-parsers --disable-bsfs --disable-debug --disable-protocols --disable-indevs --disable-outdevs --enable-protocol=file \
			--enable-libvpx --enable-libopenh264 \
			--extra-libs="$(DIST_DIR)/lib/libvpx.a $(DIST_DIR)/lib/libopenh264.a" \
			--nm=$(shell which llvm-nm) --disable-stripping && \
		sed -i.bak -e 's/#define HAVE_ARC4RANDOM 1/#define HAVE_ARC4RANDOM 0/' ./config.h && \
		sed -i.bak -e 's/HAVE_ARC4RANDOM=yes/HAVE_ARC4RANDOM=no/' ./ffbuild/config.mak && \
		cd ..

rebuild-ffmpeg: clean-ffmpeg configure-ffmpeg build-ffmpeg

prepare-libs: build-zlib build-vpx build-openh264 build-ffmpeg
	cd dist && \
		rm -vf *.bc && \
		cp lib/libvpx.a libvpx.bc && \
		cp lib/libopenh264.a libopenh264.bc && \
		cp lib/libz.a libz.bc && \
		cp ../ffmpeg/ffmpeg ffmpeg.bc && \
		cd ..

build: prepare-libs
	cd dist && \
		emcc -s TOTAL_MEMORY=1073741824 -O3 ffmpeg.bc libvpx.bc libopenh264.bc libz.bc -o ../ffmpeg.js --pre-js ../ffmpeg_pre.js --post-js ../ffmpeg_post.js && \
		cd ..

build-wasm: prepare-libs
	cd dist && \
		emcc -s TOTAL_MEMORY=1073741824 -O3 ffmpeg.bc libvpx.bc libopenh264.bc libz.bc -o ../ffmpeg.js --pre-js ../ffmpeg_pre.js --post-js ../ffmpeg_post.js -s WASM=1 -s "BINARYEN_METHOD='native-wasm'" && \
		cd ..

install: build
	cp ffmpeg.js* ../demo

install-wasm: build-wasm
	cp ffmpeg.wasm* ../demo

clean-dist:
	rm -rf dist && \
		mkdir -p dist

clean: clean-dist clean-zlib clean-vpx clean-openh264 clean-ffmpeg

