usage () {
  cat <<EOF
Usage: bz show pr
       bz show -h

Options:
    -h    -- this help message

Args:
    pr    -- pr number

Will display pr and best guess patch to STDOUT.
EOF

  exit 1
}

show () {
  local pr=$1

  ${ME} get $pr

  local d=$(_pr_dir $pr)

  cat $d/pr $d/patch
}

. ${BZ_BACKENDDIR}/get.sh

while getopts h FLAG; do
  case ${FLAG} in
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

show $pr
