usage () {
  cat <<EOF
Usage: bz search [-a assigned_to] [-c component] [-H hardware] [-p product] [-r reported_by] \\
                 [-R resolution ] [-s state] [-S severity] [-v version]
       bz search [-A|-DPB] .....
       bz search -h

Optional:
    -H    -- only prs for this hardware
    -R    -- resolution of pr
    -S    -- severity of pr
    -a    -- email address pr is assigned to
    -c    -- component pr is in
    -h    -- this help message
    -p    -- product pr is in
    -r    -- email address that reported pr
    -s    -- state of pr
    -v    -- only prs affecting this version

Shortcuts:
    -A    -- search all products equivalent to -BDP
    -B    -- equivalent to -p "Base System"
    -D    -- equivalent to -p "Documentation"
    -P    -- equivalent to -p "Ports & Packages"

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

[ $# -lt 1 ] && product="Base System,Documentation,Ports & Packages"

while getopts ABDPH:R:S:a:c:hp:r:s:v: FLAG; do
  case ${FLAG} in
    A) product="Base System,Documentation,Ports & Packages" ;;
    B) product="Base System" ;;
    D) product="Documentation" ;;
    P) product="Ports & Packages" ;;
    H) hardware="$OPTARG"    ;;
    R) resolution="$OPTARG"  ;;
    S) severity="$OPTARG"    ;;
    a) assigned_to="$OPTARG" ;;
    c) component="$OPTARG"   ;;
    p) product="$OPTARG"     ;;
    r) reporter="$OPTARG"    ;;
    s) state="$OPTARG"       ;;
    v) version="$OPTARG"     ;;
    h|*) usage               ;;
  esac
done
shift $(($OPTIND-1))

search "$assigned_to" "$component" "$hardware" "$product" \
  "$reporter" "$resolution" "$state" "$severity" "$version"
