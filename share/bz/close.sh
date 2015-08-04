usage () {
  cat <<EOF
Usage: bz close [-c comment | -e] pr
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
      local comment_file_orig=$(_run_editor $comment_file /dev/tty)
      rm -f $comment_file_orig # not used
  else
    [ -z "$comment" ] && echo "$comment" > $comment_file
  fi

  if [ -n "$(cat $comment_file)" ]; then
    backend_close $pr $comment_file
  fi

  rm -f $comment_file
}

. ${BZ_SCRIPTDIR}/_util.sh
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
