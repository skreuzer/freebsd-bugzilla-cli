inprog () {
  local pr=$1

  bugz modify -s "In Progress" $pr
}
