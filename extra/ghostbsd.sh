#!/bin/sh
#
# Copyright (c) 2011 GhostBSD
#
# See COPYING for licence terms.
#
# ghostbsd.sh,v Sun Dec 11 2011 23:15, Eric
#

# Adding WiFi Network Card Configuration.
mkdir -p ${BASEDIR}/usr/local/etc/wncc/
cp -f extra/ghostbsd/wncc.py ${BASEDIR}/usr/local/etc/wncc/wncc.py
install -C extra/ghostbsd/netif $BASEDIR/etc/rc.d/

# Removing some MB of the system.
rm -rf ${BASEDIR}/rescue

# Graphic card Auto configuration at the system boot Script.
mkdir $BASEDIR/usr/local/etc/card/
install -C extra/ghostbsd/xconfig.sh $BASEDIR/usr/local/etc/card/

# Cat rc.cong.extra in 
cat extra/ghostbsd/rc.conf.extra >> ${BASEDIR}/etc/rc.conf

###
## put a GhostBSD-irc icon on the desktop
####
cp -f extra/ghostbsd/ghostbsd-irc.desktop ${BASEDIR}/usr/local/share/applications/


# Live cd user gtk-bockmarks.
printf "file:///root/Documents Documents
file:///root/Downloads Downloads
file:///root/Movies Movies
file:///root/Music Music
file:///root/Pictures Pictures
" > ${BASEDIR}/root/.gtk-bookmarks

mkdir ${BASEDIR}/root/Documents
mkdir ${BASEDIR}/root/Downloads
mkdir ${BASEDIR}/root/Movies
mkdir ${BASEDIR}/root/Music
mkdir ${BASEDIR}/root/Pictures

printf "file:///home/ghostbsd/Documents Documents
file:///home/ghostbsd/Downloads Downloads
file:///home/ghostbsd/Movies Movies
file:///home/ghostbsd/Music Music
file:///home/ghostbsd/Pictures Pictures
" > ${BASEDIR}/home/ghostbsd/.gtk-bookmarks
#chgrp ghostbsd ${BASEDIR}/home/ghostbsd/.gtk-bookmarks
chmod g+rwx ${BASEDIR}/home/ghostbsd/.gtk-bookmarks

mkdir ${BASEDIR}/home/ghostbsd/Documents
#chgrp ghostbsd ${BASEDIR}/home/ghostbsd/Documents
chmod g+rwx ${BASEDIR}/home/ghostbsd/Documents
mkdir ${BASEDIR}/home/ghostbsd/Downloads
#chgrp ghostbsd ${BASEDIR}/home/ghostbsd/Downloads
chmod g+rwx ${BASEDIR}/home/ghostbsd/Downloads
mkdir ${BASEDIR}/home/ghostbsd/Movies 
#chgrp ghostbsd ${BASEDIR}/home/ghostbsd/Movies
chmod g+rwx ${BASEDIR}/home/ghostbsd/Movies
mkdir ${BASEDIR}/home/ghostbsd/Music
#chgrp ghostbsd ${BASEDIR}/home/ghostbsd/Music
chmod g+rwx ${BASEDIR}/home/ghostbsd/Music
mkdir ${BASEDIR}/home/ghostbsd/Pictures
#chgrp ghostbsd ${BASEDIR}/home/ghostbsd/Pictures
chmod g+rwx ${BASEDIR}/home/ghostbsd/Pictures

# COPYRIGHT
cp -f extra/ghostbsd/COPYRIGHT ${BASEDIR}/COPYRIGHT

# Replace FreeBSD By GhostBSD.
cp -f extra/ghostbsd/motd ${BASEDIR}/etc/
#cp -f extra/ghostbsd/gettytab ${BASEDIR}/etc/gettytab
cp extra/ghostbsd/beastie.4th ${BASEDIR}/boot/
cp extra/ghostbsd/brand.4th  ${BASEDIR}/boot/
cp extra/ghostbsd/menu.4th ${BASEDIR}/boot/
sed -i "" "s@FreeBSD@GhostBSD@" ${BASEDIR}/boot/version.4th
sed -i "" "s@Nakatomi Socrates@Levi@" ${BASEDIR}/boot/version.4th
sed -i "" "s@9.2@3.5@" ${BASEDIR}/boot/version.4th

#cp extra/ghostbsd/menu-commands.4th ${BASEDIR}/boot/
cp extra/ghostbsd/mountcritlocal ${BASEDIR}/etc/rc.d/
mkdir -p ${BASEDIR}/usr/src/sys

# Setup browser for partnership and affiliate.
# Deleting bing.xml yahoo.xml google.xml twitter.xml.
cd ${BASEDIR}/usr/local/lib/firefox/browser/searchplugins
rm -f bing.xml yahoo.xml google.xml twitter.xml
cd -

# Replacing duckduckgo.xml.
cp extra/ghostbsd/ddg/duckduckgo.xml ${BASEDIR}/usr/local/lib/firefox/browser/searchplugins/duckduckgo.xml

# Replacing prefs.js and firefox.js.
#cp -f extra/ghostbsd/ddg/firefox/pref/firefox.js ${BASEDIR}/usr/local/lib/firefox/defaults/pref/firefox.js
#mkdir ${BASEDIR}/usr/local/lib/firefox/defaults/profile/
#cp -f extra/ghostbsd/ddg/firefox/profile/prefs.js ${BASEDIR}/usr/local/lib/firefox/defaults/profile/prefs.js

# Replacing amazondotcom.xml with GhostBSD affiliate amazondotcom.xml. 

cp -f extra/ghostbsd/amazon/amazondotcom.xml ${BASEDIR}/usr/local/lib/firefox/browser/searchplugins/amazondotcom.xml

# Add bxpkg to the menue
#cp -f extra/gnome/bxpkg-${ARCH}.desktop ${BASEDIR}/usr/local/share/applications/bxpkg.desktop
#cp -f extra/gnome/m_icon.png ${BASEDIR}/usr/local/share/pixmaps/
#cp -f extra/gnome/gnome-applications.menu ${BASEDIR}/usr/local/etc/xdg/menus

# Setup PolicyKit for mounting device.
printf '<?xml version="1.0" encoding="UTF-8"?> <!-- -*- XML -*- -->

<!DOCTYPE pkconfig PUBLIC "-//freedesktop//DTD PolicyKit Configuration 1.0//EN"
"http://hal.freedesktop.org/releases/PolicyKit/1.0/config.dtd">

<!-- See the manual page PolicyKit.conf(5) for file format -->

<config version="0.1">
  <match user="root">
    <return result="yes"/>
  </match>
  <define_admin_auth group="wheel"/>
  <match action="org.freedesktop.hal.power-management.shutdown">
    <return result="yes"/>
  </match>
  <match action="org.freedesktop.hal.power-management.reboot">
    <return result="yes"/>
  </match>
  <match action="org.freedesktop.hal.power-management.suspend">
    <return result="yes"/>
  </match>
  <match action="org.freedesktop.hal.power-management.hibernate">
    <return result="yes"/>
  </match>
</config>
' > ${BASEDIR}/usr/local/etc/PolicyKit/PolicyKit.conf