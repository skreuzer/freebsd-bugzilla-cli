usage() {
  cat <<EOF
Usage: bz submit [-p poudriere_log] [-P portlint_log] [-n] [-s severity] [-a arch] [-c component] [cat/port]
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
