take () {
  local pr=$1

  bugz modify -a $USER@freebsd.org -s Open -c "Take." $pr
}
