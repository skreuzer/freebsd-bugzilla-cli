. ${BZ_SCRIPTDIR}/_util.sh

backend_search () {
  local arg_str="$1"

  $bugz                            \
      --encoding=utf8              \
      search                       \
      $arg_str
}
