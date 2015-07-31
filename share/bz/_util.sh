bugz=bugz

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

_delta_generate () {
  local port_dir=$1
  local delta_file=$2

  local vc=$(_svn_or_git)

  if [ x"$vc" = x"git" ]; then
    (cd $PORTSDIR ; git diff $port_dir > $delta_file)
  else
    (cd $PORTSDIR ; svn diff $port_dir > $delta_file)
  fi
}

_title_generate () {
  local port_dir=$1
  local delta_file=$2

  local title
  if [ -z "$delta_file" ]; then
    local comment=$(cd $PORTSDIR/$port_dir ; make -V COMMENT)
    title="[new port]: $port_dir - $comment"
  else
    _delta_generate $port_dir $delta_file

    if [ -z "$(cat $delta_file)" ]; then
      title=""
    else
      title="[patch]: $port_dir "
      local cv=$(grep -c '^[+-]PORTVERSION' $delta_file)
      if [ $cv -eq 2 ]; then
        local oldv=$(awk '/^-PORTVERSION/ { print $2 }'  $delta_file)
        local newv=$(awk '/^\+PORTVERSION/ { print $2 }' $delta_file)
        [ $oldv != $newv ] && title="$title, update $oldv->$newv"
      fi

      local cm=$(grep -c '^[+-]MAINTAINER' $delta_file)
      if [ $cm -eq 2 ]; then
        local oldm=$(awk '/^-MAINTAINER/ { print $2 }'  $delta_file)
        local newm=$(awk '/^\+MAINTAINER/ { print $2 }' $delta_file)
        [ $oldm != $newm ] && title="$title, maintainer $oldm->$newm"
      fi

      local maintainer=$(cd $PORTSDIR/$port_dir ; make -V MAINTAINER)
      [ $REPORTER = $maintainer ] && title="(maintainer) $title"
    fi
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

_description_get () {
  local port_dir=$1
  local title="$2"
  local desc_file=$3

  local description
  if echo $title | grep -q "new"; then
    if [ ! -e $PORTSDIR/$port_dir/pkg-descr ]; then
      echo "$PORTSDIR/$port_dir/pkg-descr does not exist!" >2
    else
      description="$PORTSDIR/$port_dir/pkg-descr"
    fi
  else
    $EDITOR $desc_file > /dev/tty
    description="$desc_file"
  fi

  echo "$description"
}

_days_since () {
  local date=$1

  local ethen=$(date -j -f "%Y%m%d" "$date" "+%s")
  local enow=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s")
  local days=$(printf "%.0f" $(echo "scale=2; ($enow - $ethen)/(60*60*24)" | bc))

  echo $days
}

_days_since_action () {
  local d=$1

  local json=$(grep ^flags $d/pr | sed -e "s,^flags       :,,")

  local created=$(_json_find_key_value "creation_date" "$json" 1)
  local modified=$(_json_find_key_value "modification_date" "$json" 1)
  local status=$(_json_find_key_value "status" "$json")

  case $status in
    "+") echo 0 ;;
    *)   echo $(_days_since $created) ;;
  esac
}

_json_find_key_value () {
  local key=$1
  local json="$2"
  local f_d=${3:-0}

  local pair=$(echo "$json" | awk -F"," -v k="$key" '{
    gsub(/{|}/,"")
    for(i=1;i<=NF;i++){
        if ( $i ~ k ){
            print $i
        }
    }
}'
        )
  local v=$(echo $pair | awk -F: '{ print $2 }' | sed -e "s,',,g" -e 's, *,,g')

  if [ $f_d -eq 1 ]; then
    echo "$v" | sed -e 's,<DateTime,,' -e 's,T.*,,'
  else
    echo "$v"
  fi
}
