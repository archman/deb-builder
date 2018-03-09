#!/usr/bin/env bash

apt-get update -y
apt-get install -y \
    git \
    sphinx-common \
    python-setuptools python3-setuptools \
    git-buildpackage debhelper dh-exec dh-make \
    pristine-tar

#OTHERMIRROR="deb [trusted=yes] http://127.0.0.1:10345/debian/ jessie unstable | deb [trusted=yes] file:///opt/jessie_deps ./"
cat > /etc/pbuilderrc << EOF
OTHERMIRROR="deb [trusted=yes] http://nsclmirror.nscl.msu.edu/controls/debian jessie unstable | deb [trusted=yes] file:///opt/jessie_deps ./"
BINDMOUNTS="/opt/jessie_deps"
HOOKDIR="/usr/lib/pbuilder/hooks"
EXTRAPACKAGES="apt-utils"
EOF

! [ -e /opt/jessie_deps ] && mkdir /opt/jessie_deps
! [ -e /opt/jessie_deps/Packages ] && touch /opt/jessie_deps/Packages
chown -R devuser:devuser /opt/jessie_deps

! [ -e /usr/lib/pbuilder/hooks ] && mkdir -p /usr/lib/pbuilder/hooks
cat > /usr/lib/pbuilder/hooks/D05deps << EOF
#!/usr/bin/env bash
(cd /opt/jessie_deps; apt-ftparchive packages . > Packages)
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

# .ssh/config for devuser
! [ -e /home/devuser/.ssh ] && mkdir /home/devuser/.ssh
cat > /home/devuser/.ssh/config << EOF
Host jenkins4
HostName nsclgw1.nscl.msu.edu
User zhangt
ForwardAgent yes
LocalForward 127.0.0.1:10345 jenkins4.nscl.msu.edu:80
EOF

