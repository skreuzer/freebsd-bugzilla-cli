. ${BZ_SCRIPTDIR}/_util.sh

backend_timeout () {
  local pr=$1
  local comment="$2"

  $bugz modify -c "$comment" $pr
}
