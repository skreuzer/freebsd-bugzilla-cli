. ${BZ_SCRIPTDIR}/_util.sh

backend_overto () {
  local pr=$1
  local comment="$2"
  local state="$3"
  local who=$4

  $bugz modify -a $who -c "$comment" -s $state $pr
}
