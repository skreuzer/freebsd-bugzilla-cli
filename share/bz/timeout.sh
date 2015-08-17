usage () {
  cat <<EOF
Usage: bz timeout pr
       bz timeout -h

Options:
    -h    -- this help message

Args:
    pr    -- pr number

Will comment on the pr with maintainer timeout (\$maintainer ; N days)
if days > 16.
EOF

  exit 1
}

timeout () {
  local pr=$1

  local d=$(_pr_dir $pr)
  local port_dir=$(_port_from_pr $d)

  ${ME} get $pr
  local comment="$(_timed_out_str $d $port_dir)"

  if [ -n "$comment" ]; then
    backend_timeout $pr "$comment"
  fi
}

. ${BZ_SCRIPTDIR}/_util.sh
. ${BZ_BACKENDDIR}/timeout.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

timeout $pr
