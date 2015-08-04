. ${BZ_SCRIPTDIR}/_util.sh

backend_close () {
  local pr=$1
  local comment_file="$2"

  if [ -n "$(cat $comment_file)" ]; then
      $bugz modify -s "Closed" -r "FIXED" --coment-from $comment_file $pr
  else
    $bugz modify -s "Closed" -r "FIXED" $pr
  fi
}
