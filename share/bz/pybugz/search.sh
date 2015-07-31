. ${BZ_SCRIPTDIR}/_util.sh

search () {
  $bugz \
      --encoding=utf8              \
      search                       \
      --product "Ports & Packages" \
      -s New                       \
      -s Open                      \
      -s "In Progress"             \
      "$*"
}
