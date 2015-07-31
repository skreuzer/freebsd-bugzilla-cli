. ${BZ_SCRIPTDIR}/_util.sh

backend_take () {
  local pr=$1

  $bugz modify -a $REPORTER -s Open -c "Take." $pr
}
