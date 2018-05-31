# Using emcc (Emscripten gcc/clang-like replacement) 1.37.39 (commit a4474e59db658cea570c78254fa71119cf688db5)

echo "Beginning Build:"

rm -r dist
mkdir -p dist

cd zlib
make clean
emconfigure ./configure --prefix=$(pwd)/../dist --64
emmake make -j
emmake make install
cd ..

cd libvpx
## Try some of these options: ./configure --target=js1-none-clang_emscripten --disable-examples --disable-docs --disable-multithread --disable-runtime-cpu-detect --disable-optimizations --disable-vp8-decoder --disable-vp9-decoder --extra-cflags="-O2"
make clean
emconfigure ./configure --prefix=$(pwd)/../dist --disable-examples --disable-docs \
  --disable-runtime-cpu-detect --disable-multithread --disable-optimizations \
  --target=generic-gnu --extra-cflags="-O3"
sed -i.bak -e 's/ARFLAGS = -crs$(if $(quiet),,v)/ARFLAGS = crs$(if $(quiet),,v)/' ./libs-generic-gnu.mk
emmake make
emmake make install
cd ..

cd ffmpeg

#--enable-small

make clean

CPPFLAGS="-D_XOPEN_SOURCE=600" emconfigure ./configure --cc="emcc" --prefix=$(pwd)/../dist --extra-cflags="-I$(pwd)/../dist/include -v" --enable-cross-compile --target-os=none --arch=x86_64 --cpu=generic \
    --disable-ffplay --disable-ffprobe --disable-ffserver --disable-asm --disable-doc --disable-devices --disable-pthreads --disable-w32threads --disable-network \
    --disable-hwaccels --disable-parsers --disable-bsfs --disable-debug --disable-protocols --disable-indevs --disable-outdevs --enable-protocol=file \
    --enable-libvpx --extra-libs="$(pwd)/../dist/lib/libx264.a"
    --nm=$(which llvm-nm) --disable-stripping

# Because there doesn't appear to be a way to tell configure that arc4random isn't actually there
sed -i.bak -e 's/#define HAVE_ARC4RANDOM 1/#define HAVE_ARC4RANDOM 0/' ./config.h
sed -i.bak -e 's/HAVE_ARC4RANDOM=yes/HAVE_ARC4RANDOM=no/' ./ffbuild/config.mak

make -j
make install


cd ..

cd dist

rm *.bc

cp dist/lib/libvpx.a dist/libvpx.bc
cp lib/libz.a libz.bc
cp ../ffmpeg/ffmpeg ffmpeg.bc

emcc -v -s VERBOSE=1 -s TOTAL_MEMORY=1073741824 -O3 ffmpeg.bc libvpx.bc libz.bc -o ../ffmpeg.js --pre-js ../ffmpeg_pre.js --post-js ../ffmpeg_post.js

cd ..

cp ffmpeg.js* ../demo

echo "Finished Build"
