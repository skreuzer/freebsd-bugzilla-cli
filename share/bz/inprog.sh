usage () {
  cat <<EOF
Usage: bz inprog pr
       bz take -h

Options:
    -h    -- this help message

Args:
    pr    -- pr number
EOF

  exit 1
}

inprog () {
  local pr=$1

  backend_inprog $pr
}

. ${BZ_BACKENDDIR}/inprog.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

inprog $pr
