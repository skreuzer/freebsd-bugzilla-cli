usage() {
  cat <<EOF
Usage: bz submit [-p poudriere_log] [-P portlint_log] [cat/port]
       bz submit -h

Options:
    -P     -- optional attach this portlint log
    -h     -- this help message
    -p     -- optional attach this poudriere_log

Defaults:
  cat/port will default to `pwd`
EOF
  exit 1
}

. ${BZ_BACKENDDIR}/submit.sh

portlint_log=
poudriere_log=
while getopts P:hp: FLAG; do
  case ${FLAG} in
    P) portlint_log=$OPTARG  ;;
    p) poudriere_log=$OPTARG ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

port_dir=$1
[ -z $port_dir ] && port_dir=$(echo `pwd` | sed -e "s,$PORTSDIR/,,")

submit $port_dir "$portlint_log" "$poudriere_log"
