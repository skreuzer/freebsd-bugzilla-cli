usage() {
  cat <<EOF
Usage: bz port_submit [-p poudriere_log] [-P portlint_log] [-n] [-s severity] [-a arch] [-c component] [cat/port]
       bz submit -h

Options:
    -P     -- optional attach this portlint log
    -a     -- optional set 'Hardware' to this
    -c     -- optional set 'Component' to this
    -h     -- this help message
    -n     -- optional dry run (do not actually take write actions to bugzilla)
    -p     -- optional attach this poudriere_log
    -s     -- optional set 'Severity' to this

Defaults:
  cat/port defaults to `pwd`
  Hardware defsults to 'Any'
  Component defaults to 'Individual Port(s)'
  Severity defaults to 'Affects Only Me'
EOF
  exit 1
}

submit () {
  local port_dir=$1
  local f_n=$2
  local hardware=$3
  local component="$4"
  local severity="$5"
  local portlint_log=$6
  local poudriere_log=$7

  ## Load Config
  . $HOME/.fbcrc

  local bug_id
  local rv=$(_is_new_port $port_dir)
  if [ $rv -eq 1 ]; then
    local title=$(_title_generate $port_dir)
    local desc_file=$(_description_get $port_dir "$title")
    if [ x"$desc_file" != x"" ]; then
      bug_id=$(_submit_ports_bug $f_n "$title" "$hardware" "$component" "$severity" "$desc_file")
      _submit_shar $bug_id $f_n $port_dir
    fi
  else
    local delta_file=$(mktemp -q /tmp/_bzsubmit-delta.txt.XXXXXX)
    _delta_generate $port_dir $delta_file

    local title=$(_title_generate $port_dir $delta_file)
    local desc_file=$(_description_get $port_dir "$title" $delta_file)

    if [ x"$title" != x"" -a x"$desc_file" != x"" ]; then
      bug_id=$(_submit_ports_bug $f_n "$title" "$hardware" "$component" "$severity" "$desc_file")
      _submit_patch $bug_id $f_n $delta_file
    fi
    rm -f $delta_file
  fi

  if [ -n "$bug_id" ]; then
    [ -n "$portlint_log" ]  && _submit_portlint_log $bug_id $f_n $portlint_log
    [ -n "$poudriere_log" ] && _submit_poudriere_log $bug_id $f_n $poudriere_log
  fi
}

_submit_shar () {
  local bug_id=$1
  local f_n=$2
  local port_dir=$3

  local tport_dir=$(echo $port_dir | sed -e 's,/,_,g')
  local shar_file="/tmp/${tport_dir}.shar"

  (cd $PORTSDIR ; shar `find $port_dir` > $shar_file)

  backend_submit_attachment $bug_id $shar_file $f_n 0 "shar" "shar"

  rm -f $shar_file
}

_submit_patch () {
  local bug_id=$1
  local f_n=$2
  local delta_file=$3

  backend_submit_attachment $bug_id $delta_file $f_n 1 "patch" "patch"
}

_submit_portlint_log () {
  local bug_id=$1
  local f_n=$2
  local portlint_log=$3

  backend_submit_attachment $bug_id $portlint_log $f_n 0 "portlint log" "portlint log"
}

_submit_poudriere_log () {
  local bug_id=$1
  local f_n=$2
  local poudriere_log=$3

  backend_submit_attachment $bug_id $poudriere_log $f_n 0 "poudriere log" "poudriere log"
}

_submit_ports_bug () {
  local f_n=$1
  local title="$2"
  local hardware=$3
  local component="$4"
  local severity="$5"
  local description="$6"

  local product="Ports & Packages"
  local version="Latest"
  local os="Any"

  local bug_id=$(backend_submit "$product" "$component" "$version" "$severity" "$hardware" "$os" "$description" "$title" $f_n)

  echo $bug_id
}

. ${BZ_SCRIPTDIR}/_util.sh
. ${BZ_BACKENDDIR}/submit.sh

component="Individual Port(s)"
f_n=0
hardware="Any"
portlint_log=
poudriere_log=
severity="Affects Only Me"
while getopts P:hp:n FLAG; do
  case ${FLAG} in
    P) portlint_log=$OPTARG  ;;
    a) hardware=$OPTARG      ;;
    c) componet="$POPTARG"   ;;
    p) poudriere_log=$OPTARG ;;
    n) f_n=1                 ;;
    s) severity="$OPTARG"    ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

port_dir=$1
[ -z $port_dir ] && port_dir=$(echo `pwd` | sed -e "s,$PORTSDIR/,,")

submit $port_dir $f_n $hardware "$component" "$severity" "$portlint_log" "$poudriere_log"
