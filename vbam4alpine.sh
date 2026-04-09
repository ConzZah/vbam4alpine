#!/usr/bin/env sh

### /// vbam4alpine // ConzZah // 2026-04-09 07:55 ///

## find out where the script is located
sp="$(cd "$(dirname "$0")" && pwd)" ## <-- sp = scriptpath

## cd to $sp if we are somewhere else
[ "$sp" != "$(pwd)" ] && { cd "$sp" || exit 1 ;}

## find out if we are root and set $doas accordingly
[ "$(whoami)" != "root" ] && doas="doas"

## get dependencies
$doas apk add \
git \
zip \
nasm \
glu-dev \
build-base \
cmake \
samurai \
mesa-dev \
sdl2-dev \
gettext-dev \
zlib-dev \
ffmpeg-dev \
x264-dev \
x265-dev

## clone repo
[ ! -d visualboyadvance-m ] && git clone https://github.com/visualboyadvance-m/visualboyadvance-m.git
[ -d visualboyadvance-m ] && cd visualboyadvance-m || exit 1
git pull 

## build
[ -d build ] && rm -rf -- build
mkdir -p build
cd build || exit 1
cmake .. -DCMAKE_BUILD_TYPE=Release \
-DENABLE_SDL=ON \
-DENABLE_WX=OFF \
-G Ninja && \
ninja && \
$doas cmake --install . || exit 1

## write install.sh
echo '#!/usr/bin/env sh
### /// vbam4alpine - install.sh // ConzZah ///

## find out where the script is located
sp="$(cd "$(dirname "$0")" && pwd)" ## <-- sp = scriptpath

## cd to $sp if we are somewhere else
[ "$sp" != "$(pwd)" ] && { cd "$sp" || exit 1 ;}

## find out if we are root and set $doas accordingly
[ "$(whoami)" != "root" ] && doas="doas"

## make sure install dirs actually exist
$doas mkdir -p /usr/local/bin
$doas mkdir -p /usr/local/etc
$doas mkdir -p /usr/local/share/man/man6

## copy the files to their respective dirs
$doas cp -f vbam /usr/local/bin
$doas cp -f vbam.cfg /usr/local/etc
$doas cp -f vbam.6 /usr/local/share/man/man6

' > install.sh

## package
7z a "vbam-$(uname -m).7z" \
"install.sh" \
"/usr/local/bin/vbam" \
"/usr/local/etc/vbam.cfg" \
"/usr/local/share/man/man6/vbam.6" -mx=9
mv "vbam-$(uname -m).7z" "$sp"
rm install.sh
