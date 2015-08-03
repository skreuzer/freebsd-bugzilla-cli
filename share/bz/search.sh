usage () {
  cat <<EOF
Usage: bz search [-a assigned_to] [-c component] [-H hardware] [-p product] [-r reported_by] \
     [-R resolution ] [-s state] [-S severity] [-v version]
       bz search -h

Optional:
    -a    -- email address pr is assigned to
    -c    -- component pr is in
    -H    -- only prs for this hardware
    -h    -- this help message
    -p    -- product pr is in
    -r    -- email addree that reported pr
    -R    -- resolution of pr
    -s    -- state of pr
    -S    -- severity of pr
    -v    -- only prs affecting this version

Defaults may be configured in $HOME/.fbcrc
Assuming the backend supports it, any option may be a "," seperated list.
EOF

  exit 1
}

search () {
  backend_search "$@"
}

. ${BZ_SCRIPTDIR}/_util.sh
. ${BZ_BACKENDDIR}/search.sh

[ $# -lt 1 ] && usage

assigned_to=
component=
hardware=
product=
reporter=
resolution=
state=
severity=
version=

## Load default search criteria
. $HOME/.fbcrc

while getopts a:c:H:hp:r:R:s:S:v: FLAG; do
  case ${FLAG} in
    a) assigned_to="$OPTARG" ;;
    c) component="$OPTARG"   ;;
    H) hardware="$OPTARG"    ;;
    p) product="$OPTARG"     ;;
    r) reporter="$OPTARG"    ;;
    R) resolution="$OPTARG"  ;;
    s) state="$OPTARG"       ;;
    S) severity="$OPTARG"    ;;
    v) version="$OPTARG"     ;;
    h|*) usage               ;;
  esac
done
shift $(($OPTIND-1))

search "$assigned_to" "$component" "$hardware" "$product" \
  "$reporter" "$resolution" "$state" "$severity" "$version"
