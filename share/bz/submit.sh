usage() {
  cat <<EOF
Usage: bz submit [-p poudriere_log] [-P portlint_log] [-n] [cat/port]
       bz submit -h

Options:
    -P     -- optional attach this portlint log
    -h     -- this help message
    -p     -- optional attach this poudriere_log
    -n     -- optional dry run (do not actually take write actions to bugzilla)

Defaults:
  cat/port will default to `pwd`
EOF
  exit 1
}

. ${BZ_BACKENDDIR}/submit.sh

portlint_log=
poudriere_log=
f_n=0
while getopts P:hp:n FLAG; do
  case ${FLAG} in
    P) portlint_log=$OPTARG  ;;
    p) poudriere_log=$OPTARG ;;
    n) f_n=1                 ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

port_dir=$1
[ -z $port_dir ] && port_dir=$(echo `pwd` | sed -e "s,$PORTSDIR/,,")

submit $port_dir $f_n "$portlint_log" "$poudriere_log"
