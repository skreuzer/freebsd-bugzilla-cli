. ${BZ_SCRIPTDIR}/_util.sh

submit () {
  local port_dir=$1
  local f_n=$2
  local portlint_log=$3
  local poudriere_log=$4

  ## Load Config
  [ -e $HOME/.fbcrc ] && . $HOME/.fbcrc

  local bugz=bugz
  [ $f_n -eq 1 ] && bugz=true

  local rv=$(_is_new_port $port_dir)
  if [ $rv -eq 1 ]; then
    local title=$(_title_generate $port_dir)
    local bug_id=$(_submit_bug "$title")
    _submit_shar $bug_id $port_dir
  else
    local delta="/tmp/$$"
    local title=$(_title_generate $port_dir $delta)
    if [ x"$title" != x"" ]; then
      local bug_id=$(_submit_bug "$title")
      _submit_patch $bug_id $delta
    fi
    rm -f $delta
  fi

  [ -n "$portlint_log" ]  && _submit_portlint_log $bug_id $portlint_log
  [ -n "$poudriere_log" ] && _submit_poudriere_log $bug_id $poudriere_log
}

_submit_shar () {
  local bug_id=$1
  local port_dir=$2

  local tport_dir=$(echo $port_dir | sed -e 's,/,_,g')
  local shar_file="/tmp/${tport_dir}.shar"

  (cd $PORTSDIR ; shar `find $port_dir` > $shar_file)

  $bugz attach                      \
        --title "shar"              \
        --description "shar"        \
        --content-type "text/plain" \
        $bug_id $shar_file

  rm -f $shar_file
}

_submit_patch () {
  local bug_id=$1
  local delta=$2

  $bugz attach              \
      --title "patch"       \
      --description "patch" \
      --patch               \
      $bug_id $delta
}

_submit_portlint_log () {
  local bug_id=$1
  local portlint_log=$2

  $bugz attach                     \
      --title "portlint log"       \
      --description "portlint log" \
      --content-type "text/plain"  \
      $bug_id $portlint_log
}

_submit_poudriere_log () {
  local bug_id=$1
  local poudriere_log=$2

  $bugz attach                      \
      --title "poudriere log"       \
      --description "poudriere log" \
      --content-type "text/plain"   \
      $bug_id $poudriere_log
}


_submit_bug () {
  local title="$1"

  local product="Ports & Packages"
  local version="Latest"
  local component="Individual Port(s)"
  local severity="Affects Only Me"
  local hardware="Any"
  local os="Any"

  local str=$($bugz post           \
       --batch                     \
       --product   "$product"      \
       --component "$component"    \
       --version   "$version"      \
       --severity  "$severity"     \
       --platform  "$hardware"     \
       --op-sys    "$os"           \
       --description "description" \
       --title     "$title")
  local bug_id=$(echo $str | awk '/submitted/ { print $3 }')

  # XXX: allow debugging
  [ -z "$bug_id" ] && bug_id=-1

  echo $bug_id
}
