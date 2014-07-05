#!/bin/sh
#
# Copyright (c) 2011 GhostBSD
#
# See COPYING for licence terms.
#
# autologin.sh, v1.3, Sunday, June 29 2014 Eric

GHOSTBSD_ADDUSER=${GHOSTBSD_ADDUSER:-"ghostbsd"}

echo "# root user autologin" >> ${BASEDIR}/etc/gettytab
echo "root:\\" >> ${BASEDIR}/etc/gettytab
echo ":al=root:ht:np:sp#115200:" >> ${BASEDIR}/etc/gettytab

sed -i "" "/ttyv0/s/Pc/root/g" ${BASEDIR}/etc/ttys

echo 'if ($tty == ttyv0) then' >> ${BASEDIR}/root/.cshrc
echo "  xconfig" >> ${BASEDIR}/root/.cshrc
echo "endif" >> ${BASEDIR}/root/.cshrc

