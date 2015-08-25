usage () {
  cat <<EOF
Usage bz init [-h]

Options:
    -h    -- this help message

Will initilaize config files in ~ for itself and ${BZ_BACKEND} backend.
assigned_to
component
hardware
product
reporter
resolution
state
severity
version

may be set in the file or overriden on search commandline later.
EOF
  exit 1
}

bzinit () {

  local user
  local email
  local password

  echo -n "Login: FreeBSD Bugzilla User [$USER]: "
  read user
  [ -z "$user" ] && user=$USER

  echo -n "Login: FreeBSD Bugzilla Password: "
  stty -echo
  trap 'stty echo' EXIT
  read password
  stty echo
  trap - EXIT
  echo
  [ -z "$password" ] && echo "Blank Password." && exit 1

  echo -n "Submit: E-Mail to use for submissions [$USER@FreeBSD.org]: "
  read email
  [ -z "$email" ] && email="$USER@FreeBSD.org"

  echo -n "Search: Default Product [Ports & Packages]: "
  read product
  [ -z "$product" ] && product="Ports & Packages"

  echo -n "Search: Default PR state [New,Open,In Progress]: "
  read state
  [ -z "$state" ] && state="New,Open,In Progress"

  echo -n "Search: Default PR assignee [$email]: "
  read assigned_to
  [ -z "$assigned_to" ] && assigned_to=$email

  echo -n "Port Commit: space seperated list of your hats [none]: "
  read hats

  cat <<EOF > $HOME/.fbcrc
REPORTER=$email
hats="$hats"
product="$product"
state="$state"
assigned_to="$assigned_to"
EOF

  local url="https://bugs.freebsd.org/bugzilla/xmlrpc.cgi"
  backend_init $url $user $password
}

. ${BZ_BACKENDDIR}/init.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

bzinit
