. ${BZ_SCRIPTDIR}/_util.sh

backend_top () {
  local pos=$1
  local limit=$2

  $bugz                               \
      search                          \
      -s New                          \
      -s Open                         \
      -s "In Progress"                \
      --product "Ports & Packages" |  \
      awk "{ print \$$pos }" |        \
      sort |                          \
      uniq -c |                       \
      sort -nr -k 1,1 |               \
      head -$limit
}
