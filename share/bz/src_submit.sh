usage() {
  cat <<EOF
Usage: bz src_submit [-n]
       bz src_submit -h

Options:
    -h     -- this help message
    -n     -- optional dry run (do not actually take write actions to bugzilla)

Defaults:

EOF
  exit 1
}

_submit_bug () {
  local template_file=$1
  local f_n=$2

  local product="Base System"
  local os="Any"

  local component=$(grep ^Component $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
  local version=$(grep ^Version     $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
  local severity=$(grep ^Severity   $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
  local hardware=$(grep ^Hardware   $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
  local title=$(grep ^Title         $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')

  local s=$(grep -n "^# Any lines after here will be considered the description" $template_file | sed -e 's,:.*,,')
  local e=$(wc -l $template_file | awk '{ print $1 }')
  local description=$(tail -$(($e-$s-1)) $template_file)

  local desc_file=$(mktemp -q /tmp/_bzsubmit-desc.txt.XXXXXX)
  echo "$description" > $desc_file

  local bug_id=$(backend_submit "$product" "$component" "$version" "$severity" "$hardware" "$os" "$desc_file" "$title" $f_n)

  rm -f $desc_file

  echo $bug_id
}

_submit_patch () {
  local bug_id=$1
  local f_n=$2
  local delta_file=$3

  backend_submit_attachment $bug_id $delta_file $f_n 1 "patch" "patch"
}

_build_template () {
  cat <<EOF
# Any line starting with # will be ignored
#
# AssignedTo is optional
Title       :
AssignedTo  :
Component   : arm | bin | conf | gnu | kern | misc | standards | tests | threads | wireless
Hardware    : Any | amd64 | i386 | arm | arm64 | ia64 | mips | pc98 | ppc | sparc64
Severity    : Affects Only Me | Affects Some People | Affects Many People
Version     : 11.0-CURRENT

# Any lines after here will be considered the description

EOF
}

submit () {

  ## Load Config
  . $HOME/.fbcrc

  local vc=$(_svn_or_git "src")

  local delta_file=$(mktemp -q /tmp/_bzsubmit-delta.txt.XXXXXX)
  if [ "$vc" = "git" ]; then
    (cd $SRCDIR ; git diff > $delta_file)
  else
    (cd $SRCDIR ; svn diff > $delta_file)
  fi

  local template_file=$(mktemp -q /tmp/_bzsubmit.txt.XXXXXX)
  _build_template > $template_file

  local errors=-1
  while [ $errors -ne 0 ]; do
    errors=0
    local template_file_orig=$(_run_editor $template_file /dev/tty)
    [ -n "$template_file_orig" ] && rm -f $template_file_orig # not used

    local title=$(grep ^Title           $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
    local assignedto=$(grep ^AssignedTo $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
    local component=$(grep ^Component   $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
    local hardware=$(grep ^Hardware     $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')
    local severity=$(grep ^Severity     $template_file | cut -d: -f 2- | sed -e 's,^ *,,' -e 's, *$,,')

    [ -z "$title" ] && errors=$(($errors+1))
    [ -n "$assignedto" -a \( $(echo $assignedto | grep -c "@") -ne 1 -o $(echo $assignedto | grep -c "\.") -eq 0 \) ] && errors=$(($errors+1))
    if ! echo "$component" | egrep "^arm$|^bin$|^conf$|^gnu$|^kern$|^misc$|^standards$|^tests$|^threads$|^wireless$"; then
      errors=$(($errors+1))
    fi
    if ! echo "$hardware" | egrep "^Any$|^amd64$|^i386$|^arm$|^arm64$|^ia64$|^mips$|^pc98$|^ppc$|^sparc64$"; then
      errors=$(($errors+1))
    fi
    if ! echo "$severity" | egrep "^Affects Only Me$|^Affects Some People$|^Affects Many People$"; then
      errors=$(($errors+1))
    fi

    if [ $errors -gt 0 ]; then
      echo -n "Errors Found.  Re-edit (Y/n) [Y]: "
      local ans
      read ans
      [ "$ans" != "Y" ] && exit 1
    fi
  done

  if [ -n "$template_file_orig" ]; then
    local bug_id=$(_submit_bug $template_file $f_n)
    _submit_patch $bug_id $f_n $delta_file
  fi

  rm -f $template_file
}

. ${BZ_SCRIPTDIR}/_util.sh
. ${BZ_BACKENDDIR}/submit.sh

f_n=0
while getopts hn FLAG; do
  case ${FLAG} in
    n) f_n=1   ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

submit $f_n
