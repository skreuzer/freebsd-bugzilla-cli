usage () {
  cat <<EOF
Usage: bz close [-c comment] [-e] pr
       bz take -h

Options:
    -c    -- optional comment (default none)
    -e    -- optional spawn $EDITOR
    -h    -- this help message

Args:
    pr    -- pr number

Will mark pr as Closed, FIXED and by default no comment.
EOF

  exit 1
}

close () {
  local pr=$1
  local f_e=$2
  local comment="$3"

  local comment_file=$(mktemp -q /tmp/_bz-comment.txt.XXXXXX)
  if [ $f_e -eq 1 ]; then
    echo "$comment" > $comment_file
  else
    $EDITOR $comment_file >/dev/tty
  fi

  backend_close $pr
}

. ${BZ_BACKENDDIR}/close.sh

comment=
f_e=0
while getopts c:eh FLAG; do
  case ${FLAG} in
    c) comment="$OPTARG" ;;
    e) f_e=1 ;;
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

close $pr $f_e "$comment"
