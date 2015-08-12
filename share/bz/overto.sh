usage() {
  cat <<EOF
Usage: bz overto -w user [-c comment] [-s state] pr
       bz overto -h

Options:
    -w user        -- user [not an e-mail]
    -c comment     -- optional comment to use
    -s state       -- optional state to transition to

Defaults:
comment will default to "Over to $user"

state will default to Open
EOF
  exit 1
}

overto () {
  local pr=$1
  local comment="$2"
  local state="$3"
  local who=$4

  backend_overto $pr "$comment" "$state" $who
}

. ${BZ_BACKENDDIR}/overto.sh

who=
comment=
state=Open

while getopts c:hs:w: FLAG; do
  case ${FLAG} in
    c) comment="$OPTARG"          ;;
    s) state=$OPTARG              ;;
    w) who="$OPTARG@FreeBSD.org"  ;;
    *|h) usage                    ;;
  esac
done
shift $(($OPTIND-1))

[ $# != 1 ] && usage
[ -z "$comment" ] && comment="Over to $who"

pr=$1

overto $pr "$comment" "$state" $who
