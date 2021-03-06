#!/usr/bin/env sh

cwd="`realpath | sed 's|/scripts||g'`"
systems=$1
desktop=$2
workdir="/usr/local"
livecd="${workdir}/ghostbsd-build/${systems}"
base="${livecd}/base"
packages="${livecd}/packages"
release="${livecd}/release"
cdroot="${livecd}/cdroot"

# Only run as superuser
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

display_usage()
{
  echo "You must specify a systems at minimum!"
  echo "Possible choices are:"
  ls ${cwd}/systems
  echo "Usage: ./build.sh trueos"
  exit 1
}

validate_systems()
{
  if [ ! -d "${cwd}/systems/${systems}" ] ; then
    display_usage
  fi
}

validate_desktop()
{
  if [ ! -f "${cwd}/systems/${systems}/packages/${desktop}" ] ; then
    echo "Invalid choice specified"
    echo "Possible choices are:"
    ls ${cwd}/systems/${systems}/packages
    echo "Usage: ./build.sh trueos mate"
    exit 1
  fi
}

# We must choose a systems at minimum
if [ -z "${systems}" ] ; then
  echo "You must specify a systems!"
  echo "Possible choices are:"
  ls ${cwd}/systems
  echo "Usage: ./build.sh trueos"
  exit 1
else
  validate_systems
fi

# Validate package selection if chosen
if [ -z "${desktop}" ] ; then
    echo "Invalid choice specified"
    echo "Possible choices are:"
    ls ${cwd}/systems/${systems}/packages
    echo "Usage: ./build.sh trueos mate"
    exit 1
else
  validate_desktop
fi

# Set the volume name
if [ -n "${desktop}" ] ; then
  vol="GhostBSD-${desktop}"
else
  vol="GhostBSD"
fi

workspace()
{
  umount ${release}/var/cache/pkg >/dev/null 2>/dev/null
  if [ -d "${livecd}" ] ;then
    chflags -R noschg ${release} ${cdroot} >/dev/null 2>/dev/null
    rm -rf ${release} ${cdroot} >/dev/null 2>/dev/null
  fi
  mkdir -p ${livecd} ${base} ${packages} ${release} >/dev/null 2>/dev/null
}

base()
{
  case $systems in
    trueos)
              if [ ! -f "${base}/base.txz" ] ; then
                cd ${base}
                fetch http://pkg.trueos.org/iso/stable/base.txz
              fi
              if [ ! -f "${base}/kernel.txz" ] ; then
                cd ${base}
                fetch http://pkg.trueos.org/iso/stable/kernel.txz
              fi
              if [ ! -f "${base}/lib32.txz" ] ; then
                cd ${base}
                fetch http://pkg.trueos.org/iso/stable/lib32.txz
              fi
              cd ${base}
              tar -zxvf base.txz -C ${release}
              tar -zxvf kernel.txz -C ${release}
              tar -zxvf lib32.txz -C ${release}
              touch ${release}/etc/fstab;;
    freebsd)
              if [ ! -f "${base}/base.txz" ] ; then
                cd ${base}
                fetch http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.2-RELEASE/base.txz
              fi
              if [ ! -f "${base}/kernel.txz" ] ; then
                cd ${base}
                fetch http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.2-RELEASE/kernel.txz
              fi
              if [ ! -f "${base}/lib32.txz" ] ; then
                cd ${base}
                fetch http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.2-RELEASE/lib32.txz
              fi
              cd ${base}
              tar -zxvf base.txz -C ${release}
              tar -zxvf kernel.txz -C ${release}
              tar -zxvf lib32.txz -C ${release}
              touch ${release}/etc/fstab;;
             *)
              exit 1;;
  esac
}

packages()
{
  case $systems in
    trueos)
            cp -R ${cwd}/systems/trueos/repos/ ${release};;
    freebsd)
            cp -R ${cwd}/systems/freebsd/repos/ ${release};;
    *)
      ;;
  esac

  cp /etc/resolv.conf ${release}/etc/resolv.conf
  mkdir ${release}/var/cache/pkg
  mount_nullfs ${packages} ${release}/var/cache/pkg

  case $desktop in
      mate)
          cat ${cwd}/systems/${systems}/packages/mate | xargs pkg-static -c ${release} install -y ;;
      xfce)
          cat ${cwd}/systems/${systems}/packages/lumina | xargs pkg-static -c ${release} install -y ;;
  esac

  rm ${release}/etc/resolv.conf
  umount ${release}/var/cache/pkg

  case $systems in
    trueos)
            cp -R ${cwd}/systems/trueos/repos/ ${release};;
    freebsd)
            cp -R ${cwd}/systems/freebsd/repos/ ${release};;
    *)
      ;;
  esac

}

rc()
{
  chroot ${release} sysrc -f /etc/rc.conf root_rw_mount="NO"
  chroot ${release} sysrc -f /etc/rc.conf hostname="livecd"
  chroot ${release} sysrc -f /etc/rc.conf sendmail_enable="NONE"
  chroot ${release} sysrc -f /etc/rc.conf sendmail_submit_enable="NO"
  chroot ${release} sysrc -f /etc/rc.conf sendmail_outbound_enable="NO"
  chroot ${release} sysrc -f /etc/rc.conf sendmail_msp_queue_enable="NO"

  case $desktop in
    mate)
         chroot ${release} sysrc -f /etc/rc.conf moused_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf dbus_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf hald_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf lightdm_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf livecd_enable="YES" ;;
    xfce)
         chroot ${release} sysrc -f /etc/rc.conf moused_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf dbus_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf lightdm_enable="YES"
         chroot ${release} sysrc -f /etc/rc.conf livecd_enable="YES" ;;
  esac

  if [ -f "${release}/sbin/openrc-run" ] ; then
         chroot ${release} sysrc -f /etc/rc.conf rc_interactive="YES"
  case $desktop in
     mate)
         chroot ${release} rc-update add moused default
         chroot ${release} rc-update add dbus default
         chroot ${release} rc-update add hald default
         chroot ${release} rc-update add livecd default
         chroot ${release} rc-update add lightdm default
         #chroot ${release} rc-update add xdm default
         #chroot ${release} sysrc -f /usr/local/etc/conf.d/xdm DISPLAYMANAGER="lightdm"
         ;;
    xfce)
         chroot ${release} rc-update add moused default
         chroot ${release} rc-update add dbus default
         chroot ${release} rc-update add hald default
         chroot ${release} rc-update add livecd default
         chroot ${release} rc-update add lightdm default
         #chroot ${release} rc-update add xdm default
         #chroot ${release} sysrc -f /usr/local/etc/conf.d/xdm DISPLAYMANAGER="lightdm"
         ;;
  esac
  fi
}

user()
{
  if [ "$systems" != "freebsd" -o "$systems" != "trueos" ]; then
    chroot ${release} echo freebsd | chroot ${release} pw mod user root -h 0
  fi
  chroot ${release} pw useradd liveuser \
  -c "Live User" -d "/home/liveuser" \
  -g wheel -G operator -m -s /bin/csh -k /usr/share/skel -w none
  if [ $systems != "freebsd" -o $systems != "trueos" ]; then
    chroot ${release} echo freebsd | chroot ${release} pw mod user liveuser -h 0
  fi
}

extra_config()
{
  case $systems in
    trueos)
        . ${cwd}/systems/trueos/extra/common-live-setting.sh
        . ${cwd}/systems/trueos/extra/setuser.sh
        . ${cwd}/systems/trueos/extra/dm.sh
        create_share_ghostbsd
        setup_liveuser
        lightdm_setup
        ;;
    freebsd)
        . ${cwd}/systems/freebsd/extra/common-live-setting.sh
        . ${cwd}/systems/freebsd/extra/setuser.sh
        . ${cwd}/systems/freebsd/extra/dm.sh
        create_share_ghostbsd
        setup_liveuser
        lightdm_setup
        ;;
    *)
      ;;
  esac
}

xorg()
{
  if [ -n "${desktop}" ] ; then
    install -o root -g wheel -m 755 "${cwd}/xorg/bin/livecd" "${release}/usr/local/bin/"
    install -o root -g wheel -m 755 "${cwd}/xorg/rc.d/livecd" "${release}/usr/local/etc/rc.d/"
    if [ -f "${release}/sbin/openrc-run" ] ; then
      install -o root -g wheel -m 755 "${cwd}/xorg/init.d/livecd" "${release}/usr/local/etc/init.d/"
    fi
    if [ ! -d "${release}/usr/local/etc/X11/cardDetect/" ] ; then
      mkdir -p ${release}/usr/local/etc/X11/cardDetect
    fi
    install -o root -g wheel -m 755 "${cwd}/xorg/cardDetect/XF86Config.vesa" "${release}/usr/local/etc/X11/cardDetect/"
    install -o root -g wheel -m 755 "${cwd}/xorg/cardDetect/XF86Config.scfb" "${release}/usr/local/etc/X11/cardDetect/"
    install -o root -g wheel -m 755 "${cwd}/xorg/cardDetect/XF86Config.virtualbox" "${release}/usr/local/etc/X11/cardDetect/"
    install -o root -g wheel -m 755 "${cwd}/xorg/cardDetect/XF86Config.vmware" "${release}/usr/local/etc/X11/cardDetect/"
    install -o root -g wheel -m 755 "${cwd}/xorg/cardDetect/XF86Config.nvidia" "${release}/usr/local/etc/X11/cardDetect/"
  fi
}

uzip()
{
  install -o root -g wheel -m 755 -d "${cdroot}"
  mkdir "${cdroot}/data"
  makefs "${cdroot}/data/system.ufs" "${release}"
  mkuzip -o "${cdroot}/data/system.uzip" "${cdroot}/data/system.ufs"
  rm -f "${cdroot}/data/system.ufs"
}

ramdisk()
{
  ramdisk_root="${cdroot}/data/ramdisk"
  mkdir -p "${ramdisk_root}"
  cd "${release}"
  tar -cf - rescue | tar -xf - -C "${ramdisk_root}"
  cd "${cwd}"
  install -o root -g wheel -m 755 "init.sh.in" "${ramdisk_root}/init.sh"
  sed "s/@VOLUME@/${vol}/" "init.sh.in" > "${ramdisk_root}/init.sh"
  mkdir "${ramdisk_root}/dev"
  mkdir "${ramdisk_root}/etc"
  touch "${ramdisk_root}/etc/fstab"
  cp ${release}/etc/login.conf ${ramdisk_root}/etc/login.conf
  makefs -b '10%' "${cdroot}/data/ramdisk.ufs" "${ramdisk_root}"
  gzip "${cdroot}/data/ramdisk.ufs"
  rm -rf "${ramdisk_root}"
}

boot()
{
  cd "${release}"
  tar -cf - --exclude boot/kernel boot | tar -xf - -C "${cdroot}"
  for kfile in kernel geom_uzip.ko nullfs.ko tmpfs.ko unionfs.ko; do
  tar -cf - boot/kernel/${kfile} | tar -xf - -C "${cdroot}"
  done
  cd "${cwd}"
  cp -R boot/ ${cdroot}/boot/
}

image()
{
  grub-mkrescue -o ${livecd}/${vol}.iso ${cdroot} -- -volid ${vol}
}
