. ${BZ_SCRIPTDIR}/_util.sh

backend_comment () {
  local pr=$1
  local comment="$2"

  $bugz modify -F $comment_file $pr
}
