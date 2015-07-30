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

_svn_or_git () {

  local vc
  if [ -d $PORTSDIR/.git ]; then
    vc=git
  elif [ -d $PORTSDIR/.svn ]; then
    vc=svn
  else
    echo "Unable to determine checkout type of $PORTSDIR.  Only svn/git supported"
    exit 1
  fi

  echo $vc
}

_delta_genetate () {
  local port_dir=$1
  local delta=$2

  local vc=$(_svn_or_git)

  if [ x"$vc" = x"git" ]; then
    (cd $PORTSDIR ; git diff $port_dir > $delta)
  else
    (cd $PORTSDIR ; svn diff $port_dir > $delta)
  fi
}

_title_generate () {
  local port_dir=$1
  local delta=$2

  if [ -z "$delta" ]; then
    local comment=$(cd $PORTSDIR/$port_dir ; make -V COMMENT)
    echo "[new port]: $port_dir - $comment"
    return
  fi

  _delta_generate $port_dir $delta

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

_is_new_port () {
  local port_dir=$1

  local vc=$(_svn_or_git)
  if [ x"$vc" = x"git" ]; then
    if $(cd $PORTSDIR && git ls-files --error-unmatch $port_dir >/dev/null 2>&1); then
      echo 0
    else
      echo 1
    fi
  else
    if $(cd $PORTSDIR && svn ls $port_dir >/dev/null 2>&1); then
      echo 0
    else
      echo 1
    fi
  fi
}
