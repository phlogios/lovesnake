#!/bin/sh
NAME=LoveSnake
OPK_NAME=${NAME}.opk

echo ${OPK_NAME}

# create default.gcw0.desktop
cat > default.gcw0.desktop <<EOF
[Desktop Entry]
Name=LoveSnake
Comment=Snake in Love
Exec=love ./
Terminal=false
Type=Application
StartupNotify=true
Icon=lovesnake
Categories=games;
EOF

FLIST="lovesnake.png Resource-Imagefont.png conf.lua main.lua default.gcw0.desktop"

# create opk

rm -f ${OPK_NAME}
mksquashfs ${FLIST} ${OPK_NAME} -all-root -no-xattrs -noappend -no-exports

cat default.gcw0.desktop
rm -f default.gcw0.desktop
