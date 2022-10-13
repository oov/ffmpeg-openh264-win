#!/bin/bash -e
git clone --depth 1 https://github.com/BtbN/FFmpeg-Builds
cd FFmpeg-Builds

sed -i 's/CT_ZLIB_V_1_2_12/CT_ZLIB_V_1_2_13/' images/base-win32/ct-ng-config
sed -i 's/\(CT_ZLIB_VERSION="\)\(1\.2\.12\)/\11.2.13/' images/base-win32/ct-ng-config
sed -i 's/CT_ZLIB_V_1_2_12/CT_ZLIB_V_1_2_13/' images/base-win64/ct-ng-config
sed -i 's/\(CT_ZLIB_VERSION="\)\(1\.2\.12\)/\11.2.13/' images/base-win64/ct-ng-config

sed -i 's/gawk/gawk mingw-w64-tools/' images/base/Dockerfile

sed -i 's/\(make.*\)/\1 \&\& openh264_swap_lib/' scripts.d/50-openh264.sh
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
