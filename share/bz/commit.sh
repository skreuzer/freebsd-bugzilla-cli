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

  ## grab comment with version string which will be #0
  local comment=$(_get_comment_from_pr $d)
  local commit_file=$(mktemp -q /tmp/_bzcommit-comment.txt.XXXXXX)
  echo "$comment" > $commit_file
  local commit_file_orig=$(_run_editor $commit_file /dev/tty)

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
