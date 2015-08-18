usage() {
  cat <<EOF
Usage: bz commit [-c] [-n] pr
       bz commit -h

Options:
    -c     -- also close the pr
    -h     -- this help message
    -n     -- dry run, do not actually commit

Args:
    pr     -- pr number
EOF
  exit 1
}

commit () {
  local pr=$1
  local f_n=$2
  local f_c=$3

  ## sync copy
  ${ME} get -n $pr

  ## which vc
  local vc=$(_svn_or_git "ports")

  ## which port
  local d=$(_pr_dir $pr)
  local port_dir=$(_port_from_pr $d)
  local commit_file=$(mktemp -q /tmp/_bzcommit-comment.txt.XXXXXX)

  # yep, make it easy
  _make_commit_msg $d $port_dir $commit_file

  ## cleanup port_dir
  _clean_port_dir $port_dir
  _remove_empty_files $port_dir $vc
  _add_new_files $port_dir $vc

  ## Are you sure?
  _preview_commit $vc $port_dir $commit_file

  ## Proceed?
  _confirm $commit_file

  ## Do it!
  _doit $f_n $vc $port_dir $commit_file

  ## cleanup
  [ $f_n -eq 0 -a $f_c -eq 1 ] && ${ME} close $pr

  rm -f $commit_file
}

_make_commit_msg () {
  local d=$1
  local port_dir=$2
  local commit_file=$3

  local submitter=$(_submitter_from_pr $d)
  local submitter_short=$(echo $submitter | sed -e 's,FreeBSD.org,,i')
  local maintainer=$(_maintainer_from_port $port_dir)

  . $HOME/.fbcrc

  ## grab title
  _title_from_pr $d > $commit_file

  ## grab comment
  _comment_from_pr $d >> $commit_file

  ## Post amble comment
  echo >>                            $commit_file
  echo "PR:                  $pr" >> $commit_file

  if [ "$REPORTER" != "$submitter" ]; then
    if [ "$submitter" = "$maintainer" ]; then
      echo "Submitted by:        $submitter_short (maintainer)" >> $commit_file
    else
      echo "Submitted by:        $submitter_short" >> $commit_file
    fi
  fi

  if [ "$submitter" != "$maintainer" ]; then
    local timeout_str=$(_timeout_from_pr $d)
    if [ -n "$timeout_str" ]; then
      echo "Approved by:         $timeout_str" >> $commit_file
    else
      if [ "$maintainer" != "ports@FreeBSD.org" ]; then
        echo "Approved by:         $maintainer (maintainer)" >> $commit_file
      fi
    fi
  fi
  if [ -n "$SPONSORED_BY" ]; then
    echo "Sponsored by:        $SPONSORED_BY" >> $commit_file
  fi

  local commit_file_orig=$(_run_editor $commit_file /dev/tty)
  [ -n "$commit_file_orig" ] && rm -f $commit_file_orig # not used
}

_clean_port_dir () {
  local port_dir=$1

  (
    cd $PORTSDIR/$port_dir
    find . \
           \( -type f -o -type l \) -a \
           \( -name "*.bak" -o -name "*~" -o -name ".\#*" -o -name "\#*" \
                 -o -name "*.rej" -o -name "svn-commit.*" -o -name "*.orig" \
                 -o -name "*-i" -o -name "*-E" -o -name "*-e" -o -name "*.tmp" \
                 -o -name "=~+*" \
           \) \
           -print -exec rm -f "{}" \;
  )
}

_remove_empty_files () {
  local port_dir=$1
  local vc=$2

  if [ "$vc" = "git" ]; then
    ( cd $PORTSDIR/$port_dir ; find . -type f -empty | xargs git rm -f )
  else
    ( cd $PORTSDIR/$port_dir ; find . -type f -empty | xargs svn rm -f  )
  fi
}

_add_new_files () {
  local port_dir=$1
  local vc=$2

  if [ "$vc" = "git" ]; then
    ( cd $PORTSDIR/$port_dir ; git add -A . )
  else
  fi
}

_preview_commit () {
  local vc=$1
  local port_dir=$2
  local commit_file=$3

  echo "=============================================================================="
  echo "-------------------------------ADD/DELETE/CHANGED-----------------------------"
  if [ "$vc" = "git" ]; then
    ( cd $PORTSDIR/$port_dir ; git status -s . )
  else
    ( cd $PORTSDIR/$port_dir ; svn status . )
  fi
  echo "---------------------------------DIFF-----------------------------------------"
  if [ "$vc" = "git" ]; then
    ( cd $PORTSDIR/$port_dir ; git diff HEAD . )
  else
    ( cd $PORTSDIR/$port_dir ; svn diff . )
  fi
  echo "------------------------------COMMIT MESSAGE----------------------------------"
  cat $commit_file
  echo "=============================================================================="
}

_confirm () {
  local commit_file=$1

  local ans
  echo -n "Final chance, are you sure? (YES to proceed) [NO]: "
  read ans
  if [ x"$ans" != x"YES" ]; then
    rm -f $commit_file
    echo "Bailing out"
    exit 1
  fi
}

_doit () {
  local f_n=$1
  local vc=$2
  local port_dir=$3
  local commit_file=$4

  [ $f_n -eq 1 ] && vc=true
  (
    cd $PORTSDIR/$port_dir
    if [ "$vc" = "git" ]; then
      $vc commit -F $commit_file
    else
      $vc add --force .
      $vc commit -F $commit_file
    fi
  )
}

. ${BZ_SCRIPTDIR}/_util.sh

f_c=0
f_n=0
while getopts chn FLAG; do
  case ${FLAG} in
    c) f_c=1 ;;
    n) f_n=1 ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

commit $pr $f_n $f_c
