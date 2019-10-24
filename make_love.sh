#!/bin/sh
NAME=LoveSnake
OPK_NAME=${NAME}.opk

echo ${OPK_NAME}

FLIST="./*"

# create opk

rm -f ${OPK_NAME}
mksquashfs ${FLIST} ${OPK_NAME} -all-root -no-xattrs -noappend -no-exports
