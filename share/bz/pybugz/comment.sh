. ${BZ_SCRIPTDIR}/_util.sh

comment() {
  local pr=$1

  local comment_file=$(mktemp -q /tmp/_bz-comment.txt.XXXXXX)
  $EDITOR $comment_file >/dev/tty

  $bugz modify -F $comment_file $pr

  rm -f $comment_file
}
