. ${BZ_SCRIPTDIR}/_util.sh

timeout () {
  local pr=$1

  local d=$(_pr_dir $pr)
  local port_dir=$(_port_from_pr $d)

  local days=$(_days_since_action $d)
  if [ $days -gt 16 ]; then
    local maintainer=$(cd $PORTSDIR/$port_dir ; make -V MAINTAINER)
    $bugz modify -c "maintainer timeout ($maintainer ; $days days)" $pr
  fi
}
