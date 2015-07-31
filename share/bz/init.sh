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

  cat <<EOF > $HOME/.fbcrc
REPORTER=$email
EOF

  local url="https://bugs.freebsd.org/bugzilla/xmlrpc.cgi"
  backend_init $url $user $password
}

usage () {
  cat <<EOF
Usage bz init [-h]

Options:
    -h    -- this help message

Will initilaize config files in ~ for itself and ${BZ_BACKEND}.
EOF
}

. ${BZ_BACKENDDIR}/init.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

bzinit
