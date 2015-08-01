usage () {
  cat <<EOF
Usage: bz search [-- backend search args]
       bz search -h

Optional:
    -h    -- this help message

All subsequent command args will be sent to the $BZ_BACKEND backend.

i.e.
  # pybugz backend
  `$bugz search -h`
EOF

  exit 1
}

search () {
  local arg_str="$1"

  backend_search "$arg_str"
}

. ${BZ_SCRIPTDIR}/_util.sh
. ${BZ_BACKENDDIR}/search.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

search "$@"
