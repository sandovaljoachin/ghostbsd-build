#!/bin/sh

set -e -u

# Installing pc-sysinstall
git_pc_sysinstall()
{
  if [ ! -d ${release}/pc-sysinstall ]; then
    echo "Downloading pc-sysinstall from GitHub"
    git clone https://github.com/GhostBSD/pc-sysinstall.git ${release}/pc-sysinstall >/dev/null 2>&1
  fi

  cat > ${release}/config.sh << 'EOF'
#!/bin/sh
echo "installing pc-syinstall"
cd /pc-sysinstall
sh install.sh >/dev/null 2>&1
EOF

  chroot ${release} sh /config.sh
  rm -f ${release}/config.sh
  rm -rf ${release}/pc-sysinstall
}
