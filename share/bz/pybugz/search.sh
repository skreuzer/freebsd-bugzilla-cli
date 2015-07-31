. ${BZ_SCRIPTDIR}/_util.sh

backend_search () {
  local arg_str="$1"

  $bugz                            \
      --encoding=utf8              \
      search                       \
      --product "Ports & Packages" \
      -s New                       \
      -s Open                      \
      -s "In Progress"             \
      $arg_str
}
