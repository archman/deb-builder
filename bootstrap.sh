#!/usr/bin/env bash

apt-get update -y
apt-get install -y \
    git \
    sphinx-common \
    python-setuptools python3-setuptools \
    git-buildpackage debhelper dh-exec dh-make

cat > /etc/pbuilderrc << EOF
OTHERMIRROR="deb [trusted=yes] file:///opt/trusty_deps ./"
BINDMOUNTS="/opt/trusty_deps"
HOOKDIR="/usr/lib/pbuilder/hooks"
EXTRAPACKAGES="apt-utils"
EOF

! [ -e /opt/trusty_deps ] && mkdir /opt/trusty_deps
! [ -e /opt/trusty_deps/Packages ] && touch /opt/trusty_deps/Packages
chown -R devuser:devuser /opt/trusty_deps

! [ -e /usr/lib/pbuilder/hooks ] && mkdir -p /usr/lib/pbuilder/hooks
cat > /usr/lib/pbuilder/hooks/D05deps << EOF
#!/usr/bin/env bash
(cd /opt/trusty_deps; apt-ftparchive packages . > Packages)
apt-get update
EOF
chmod +x /usr/lib/pbuilder/hooks/D05deps

cat > /home/devuser/.gitconfig << EOF
[user]
	email = warriorlance@gmail.com
	name = Tong Zhang
[core]
	editor = vim
[alias]
    st = status
    ci = commit
	co = checkout
    br = branch
    lg = log --graph --simplify-by-decoration --pretty=format:'%Cred%h%Creset-%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
    ll = log --pretty=format:'%C(green)%h %C(yellow)[%ad]%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=relative 
	unstage = reset HEAD --
    last = log -1 HEAD
	visual = !gitk
    showtag = show --quiet --pretty="format:"
    ec = log --pretty=format:'%s'
EOF

cat > /home/devuser/.gbp.conf << EOF
[DEFAULT]
postbuild = lintian --profile debian -I $GBP_CHANGES_FILE && echo "Lintian OK"
EOF

# create/update cow
#DIST=jessie ARCH=amd64 git-pbuilder create
#DIST=jessie ARCH=amd64 git-pbuilder update --override-config
