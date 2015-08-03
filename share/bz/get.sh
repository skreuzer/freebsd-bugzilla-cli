usage () {
  cat <<EOF
Usage: bz get pr
       bz get -h

Options:
    -h    -- this help message

Args:
    pr    -- pr number

Will download pr and 'patch' into /tmp/$USER/freebsd/ as pr and patch
EOF

  exit 1
}

get () {
  local pr=$1

  local d=$(_pr_dir $pr)

  get_pr $d $pr
  get_attachment $d $pr
}

get_pr () {
  local d=$1
  local pr=$2

  backend_get_pr $pr > $d/pr
}

get_attachment () {
  local d=$1
  local pr=$2

  backend_get_attachment $pr > $d/patch
}

. ${BZ_BACKENDDIR}/get.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

get $pr
