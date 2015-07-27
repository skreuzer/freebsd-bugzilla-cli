_pr_dir () {
  local pr=$1

  local d=/tmp/freebsd/$pr
  if [ ! -d $d ]; then
    mkdir -p $d
  fi

  echo $d
}

_port_from_pr () {
  local d=$1
  local pr=$2

  local title=$(grep Title $d/pr | cut -d: -f 2- | sed -e 's,^ *,,')
  local port=$(echo $title | egrep -o "[_a-zA-Z0-9\-]*/[_a-zA-Z0-9\-]*" | head -1)

  echo $port
}

_title_generate () {
  local port_dir=$1
  local delta=$2

  if [ -z "$delta" ]; then
    echo "[new port]: $port_dir"
    return
  fi

  (cd $PORTSDIR ; git diff $port_dir > $delta)

  local title

  if [ -z "$(cat $delta)" ]; then
    title=""
  else
    title="[patch]: $port_dir"
    local cv=$(grep -c '^[+-]PORTVERSION' $delta)
    if [ $cv -eq 2 ]; then
      local oldv=$(awk '/^-PORTVERSION/ { print $2 }'  $delta)
      local newv=$(awk '/^\+PORTVERSION/ { print $2 }' $delta)
      [ $oldv != $newv ] && title="$title, update $oldv->$newv"
    fi

    local cm=$(grep -c '^[+-]MAINTAINER' $delta)
    if [ $cm -eq 2 ]; then
      local oldm=$(awk '/^-MAINTAINER/ { print $2 }'  $delta)
      local newm=$(awk '/^\+MAINTAINER/ { print $2 }' $delta)
      [ $oldm != $newm ] && title="$title, maintainer $oldm->$newm"
    fi

    local reporter="$USER@$(hostname)"
    local maintainer=$(cd $PORTSDIR/$port_dir ; make -V MAINTAINER)
    [ $reporter = $maintainer ] && title="(maintainer) $title"
  fi

  echo "$title"
}
