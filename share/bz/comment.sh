usage () {
  cat <<EOF
Usage: bz comment [-c comment] pr
       bz comment -h

Options:
    -h    -- this help message
    -c    -- optional "comment" otherwise $EDITOR will be spawned

Args:
    pr    -- pr number
EOF

  exit 1
}

comment() {
  local pr=$1
  local comment="$2"

  local comment_file=$(mktemp -q /tmp/_bz-comment.txt.XXXXXX)
  if [ -n "$comment" ]; then
    echo "$comment" > $comment_file
  else
    $EDITOR $comment_file >/dev/tty
  fi

  backend_comment $pr $comment_file

  rm -f $comment_file
}

. ${BZ_BACKENDDIR}/comment.sh

comment=
while getopts c:h FLAG; do
  case ${FLAG} in
    c) comment="$OPTARG" ;;
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

comment $pr "$comment"
