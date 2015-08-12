. ${BZ_SCRIPTDIR}/_util.sh

backend_close () {
  local pr=$1
  local comment_file="$2"

  if [ -f $comment_file ]; then
    $bugz modify -s "Closed" -r "FIXED" --comment-from $comment_file $pr
  else
    $bugz modify -s "Closed" -r "FIXED" $pr
  fi
}
