usage() {
  cat <<EOF
Usage: bz commit [-n] pr
       bz commit -h

Options:
    -h     -- this help message
    -n     -- dry run, do not actually commit

Args:
    pr     -- pr number
EOF
  exit 1
}

# XXX: add svn
commit () {
  local pr=$1
  local f_n=$2

  ## sync copy
  ${ME} get -n $pr

  ## which vc
  local vc=$(_svn_or_git)

  ## which port
  local d=$(_pr_dir $pr)
  local port_dir=$(_port_from_pr $d)

  local commit_file=$(mktemp -q /tmp/_bzcommit-comment.txt.XXXXXX)

  local submitter=$(_submitter_from_pr $d)
  local submitter_short=$(echo $submitter | sed -e 's,FreeBSD.org,,i')
  local maintainer=$(_maintainer_from_port $port_dir)

  . $HOME/.fbcrc

  ## grab comment with version string which will be #0
  _comment_from_pr $d > $commit_file

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
      echo "Approved by:         $maintainer" >> $commit_file
    fi
  fi
  if [ -n "$SPONSORED_BY" ]; then
    echo "Sponsored by:        $SPONSORED_BY" >> $commit_file
  fi

  local commit_file_orig=$(_run_editor $commit_file /dev/tty)
  rm -f $commit_file_orig # not used
  ## Are you sure?
  if [ "$vc" = "git" ]; then
      echo "=============================================================================="
      ( cd $PORTSDIR/$port_dir ; git status -s . )
      echo "------------------------------------------------------------------------------"
      cat $commit_file
      echo "=============================================================================="
  fi

  echo -n "Final Chance, are you sure? (YES to proceed) [NO]: "
  read ans
  if [ x"$ans" != x"YES" ]; then
    echo "Bailing out"
    exit 1
  fi

  ## Do it!
  [ $f_n -eq 1 ] && vc=true

  if [ "$vc" = "git" ]; then
      (
        cd $PORTSDIR/$port_dir
        $vc add -A .
        $vc commit -F $commit_file
      )
  fi

  rm -f $commit_file
}

. ${BZ_SCRIPTDIR}/_util.sh

f_n=0
while getopts hn FLAG; do
  case ${FLAG} in
    n) f_n=1 ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

commit $pr $f_n
