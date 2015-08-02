. ${BZ_SCRIPTDIR}/_util.sh

backend_search () {

  $bugz                            \
      search                       \
      "$@"
}
