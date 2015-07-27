close () {
  local pr=$1

  bugz modify -s "Closed" -r "FIXED" $pr
}
