. ${BZ_SCRIPTDIR}/_util.sh

backend_inprog() {
  local pr=$1

  $bugz modify -s "In Progress" $pr
}
