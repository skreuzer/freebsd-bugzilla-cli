. ${BZ_SCRIPTDIR}/_util.sh

backend_close () {
  local pr=$1
  local comment="$2"

  [ -n "$comment" ] && comment="-c \"$comment\""

  $bugz modify -s "Closed" -r "FIXED" $comment $pr
}
