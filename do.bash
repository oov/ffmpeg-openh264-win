#!/bin/bash -e
git clone --depth 1 https://github.com/BtbN/FFmpeg-Builds
cd FFmpeg-Builds

# hg clone failure rate too high, use tarball
sed -i "2i GMPLIBURL=\"${GMPLIBURL}\"" scripts.d/25-gmp.sh
sed -i 's/hg clone.*gmp/mkdir gmp \&\& wget '"'\${GMPLIBURL}'"' -O - | tar Jx -C gmp --strip-component 1/' scripts.d/25-gmp.sh
sed -i 's/\.\/\.bootstrap//' scripts.d/25-gmp.sh

sed -i 's/gawk/gawk mingw-w64-tools/' images/base/Dockerfile

sed -i 's/\(make.*\)/\1 \&\& openh264_swap_lib/' scripts.d/50-openh264.sh
sed -i 's/\(SCRIPT_COMMIT="\).*\?\("\)/\1'${OPENH264HASH}'\2/' scripts.d/50-openh264.sh
echo -e "\nOPENH264PRECOMPILED=${OPENH264PRECOMPILED}\n" >> scripts.d/50-openh264.sh
cat << 'EOS' >> scripts.d/50-openh264.sh
openh264_swap_lib() {
  if [[ $TARGET == win32 ]]; then
    OPENH264MACHINE="i386"
  elif [[ $TARGET == win64 ]]; then
    OPENH264MACHINE="i386:x86-64"
  else
    echo "unknown target $TARGET"
    exit 1
  fi
  OPENH264DLLNAME=openh264-${OPENH264PRECOMPILED}-${TARGET}
  wget http://ciscobinary.openh264.org/${OPENH264DLLNAME}.dll.bz2 -O - | bzcat > /tmp/${OPENH264DLLNAME}.dll
  gendef - /tmp/${OPENH264DLLNAME}.dll > /tmp/${OPENH264DLLNAME}.def
  "$FFBUILD_CROSS_PREFIX"dlltool -m ${OPENH264MACHINE} --input-def /tmp/${OPENH264DLLNAME}.def --dllname ${OPENH264DLLNAME}.dll --output-lib /opt/ffbuild/lib/libopenh264.a
}
EOS

cd ..
