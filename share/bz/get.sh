usage () {
  cat <<EOF
Usage: bz get [-n] pr
       bz get -h

Options:
    -h    -- this help message
    -n    -- do not download attachment

Args:
    pr    -- pr number

Will download pr and 'patch' into /tmp/$USER/freebsd/\$pr as pr and patch
EOF

  exit 1
}

get () {
  local pr=$1
  local f_a=${2:-1}

  local d=$(_pr_dir $pr)

  get_pr $d $pr

  [ $f_a -eq 1 ] && get_attachment $d $pr
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

f_n=1
while getopts hn FLAG; do
  case ${FLAG} in
    h) usage ;;
    n) f_n=1 ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

get $pr $f_n
