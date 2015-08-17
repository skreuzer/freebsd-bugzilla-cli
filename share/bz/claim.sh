usage () {
  cat <<EOF
Usage: bz claim e-mail
       bz claim -h

Options:
    -h    -- this help message

Args:
    e-mail    -- email of submitter

Will issue `bz take` for each pr submitter by e-mail that is assigned
to freebsd-ports-bugs.  Useful when you want to mirror the old assignee's file
or are watching to propose someone.
EOF

  exit 1
}

claim () {
  local email=$1

  for pr in `${ME} search -r $email -a "" | awk '$2 ~ "freebsd-ports-bugs" { print $1 }'`; do
    ${ME} take $pr
  done
}

. ${BZ_SCRIPTDIR}/_util.sh

while getopts h FLAG; do
  case ${FLAG} in
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

email=$1

claim $email
