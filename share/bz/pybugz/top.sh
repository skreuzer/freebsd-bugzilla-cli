. ${BZ_SCRIPTDIR}/_util.sh

bztop () {
  local field=$1
  local limit=$2

  local pos=-1
  case $field in
    asignee) pos=2 ;;
#    reporter) pos=3 ;; # XXX: needs https://github.com/williamh/pybugz/pull/85
  esac

  $bugz                               \
      --encoding=utf8                 \
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
