usage () {
  cat <<EOF
Usage: bz close [-c comment | -e] pr
       bz close -h

Options:
    -C    -- -c "Commited. Thanks!"
    -F    -- -c "Committed with major changes. Thanks!"
    -M    -- -c "Committed with minor changes. Thanks!"
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

  if [ -n "$comment" ]; then
    local comment_file=$(mktemp -q /tmp/_bz-comment.txt.XXXXXX)
    echo "$comment" > $comment_file
    backend_close $pr "$comment_file"
    rm -f $comment_file
  elif [ $f_e -eq 1 ]; then
      local comment_file=$(mktemp -q /tmp/_bz-comment.txt.XXXXXX)
      local comment_file_orig=$(_run_editor $comment_file /dev/tty)
      if [ -n "$comment_file_orig" ]; then
        backend_close $pr $comment_file
        rm -f $comment_file_orig
      fi
      rm -f $comment_file
  else
    backend_close $pr /nonexistent
  fi
}

. ${BZ_SCRIPTDIR}/_util.sh
. ${BZ_BACKENDDIR}/close.sh

comment=
f_e=0
while getopts CFMc:eh FLAG; do
  case ${FLAG} in
    C) comment="Committed. Thanks!" ;;
    F) comment="Committed with major changes. Thanks!" ;;
    M) comment="Committed with minor changes. Thanks!" ;;
    c) comment="$OPTARG" ;;
    e) f_e=1 ;;
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

close $pr $f_e "$comment"
