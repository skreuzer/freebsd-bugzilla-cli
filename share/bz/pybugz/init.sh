. ${BZ_SCRIPTDIR}/_util.sh

bzinit () {

  local user
  local email
  local password

  echo -n "FreeBSD Bugzilla User [$USER]: "
  read user
  [ -z "$user" ] && user=$USER

  echo -n "E-Mail to use for submissions [$USER@FreeBSD.org]: "
  read email
  [ -z "$email" ] && email="$USER@FreeBSD.org"

  echo -n "FreeBSD Bugzilla Password: "
  stty -echo
  trap 'stty echo' EXIT
  read password
  stty echo
  trap - EXIT
  echo
  [ -z "$password" ] && echo "Blank Password." && exit 1

  local url="https://bugs.freebsd.org/bugzilla/xmlrpc.cgi"

  cat <<EOF > $HOME/.bugzrc
[default]
connection=FBSD

[FBSD]
base=$url
user=$user
password=$password
EOF

  cat <<EOF > $HOME/.fbcrc
REPORTER=$email
EOF
}
