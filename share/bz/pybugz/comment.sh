. ${BZ_SCRIPTDIR}/_util.sh

backend_comment () {
  local pr=$1
  local comment_file="$2"

  $bugz modify --coment-from $comment_file $pr
}
