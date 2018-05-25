#!/bin/bash

VERSION=3.3.7

rm -rf ffmpeg
wget http://ffmpeg.org/releases/ffmpeg-${VERSION}.tar.bz2
tar -xvf ffmpeg-${VERSION}.tar.bz2
mv ffmpeg-${VERSION} ffmpeg
rm ffmpeg-${VERSION}.tar.bz2

