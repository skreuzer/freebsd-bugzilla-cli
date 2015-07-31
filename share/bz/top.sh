usage () {
  cat <<EOF
Usage: bz top assignee|reporter [limit]
       bz top

Options:
    -h    -- this help message

Args:
    assignee    -- group by assigned_to
    reporter   -- group by creator
    limit      -- this many result rows

Find top by type.  Only looks at New,Open,In Progress Bugs.
Limit defaults to 10.

Note, pybugz needs a patch for reporter:
 https://github.com/williamh/pybugz/pull/85
EOF
  exit 1
}

bztop () {
  local field=$1
  local limit=$2

  local pos=-1
  case $field in
    assignee) pos=2 ;;
    reporter) pos=3 ;;
  esac

  backend_top $pos $limit
}

. ${BZ_BACKENDDIR}/top.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

field=$1
limit=${2:-10}

bztop $field $limit
