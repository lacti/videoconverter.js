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

cd ffmpeg

#--enable-small

make clean

CPPFLAGS="-D_XOPEN_SOURCE=600" emconfigure ./configure --cc="emcc" --prefix=$(pwd)/../dist --enable-cross-compile --target-os=none --arch=x86_64 --cpu=generic \
    --disable-ffplay --disable-ffprobe --disable-ffserver --disable-asm --disable-doc --disable-devices --disable-pthreads --disable-w32threads --disable-network \
    --disable-hwaccels --disable-parsers --disable-bsfs --disable-debug --disable-protocols --disable-indevs --disable-outdevs --enable-protocol=file

# Because there doesn't appear to be a way to tell configure that arc4random isn't actually there
sed -i.bak -e 's/#define HAVE_ARC4RANDOM 1/#define HAVE_ARC4RANDOM 0/' ./config.h
sed -i.bak -e 's/HAVE_ARC4RANDOM=yes/HAVE_ARC4RANDOM=no/' ./config.mak

make -j
make install


cd ..

cd dist

rm *.bc

cp lib/libz.a libz.bc
cp ../ffmpeg/ffmpeg ffmpeg.bc

emcc -v -s TOTAL_MEMORY=536870912 -Os ffmpeg.bc libz.bc -o ../ffmpeg.js --pre-js ../ffmpeg_pre.js --post-js ../ffmpeg_post.js -s ALLOW_MEMORY_GROWTH=1

cd ..

cp ffmpeg.js* ../demo

echo "Finished Build"
