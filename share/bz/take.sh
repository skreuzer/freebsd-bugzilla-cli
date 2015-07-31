usage () {
  cat <<EOF
Usage: bz take pr
       bz take -h

Options:
    -h    -- this help message

Args:
    pr    -- pr number
EOF

  exit 1
}

take () {
  local pr=$1

  . $HOME/.fbcrc
  backend_take $pr
}

. ${BZ_BACKENDDIR}/take.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

take $pr
