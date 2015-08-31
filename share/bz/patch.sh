usage () {
  cat <<EOF
Usage: bz patch [-m] pr [attachment]
       bz patch -h

Options:
    -h    -- this help message
    -m    -- multiple ports, assume patch relative to PORTSDIR

Args:
    pr         -- pr number
    attachment -- optionl attachment to forcibly use as patch

Will apply the patch to the port in $PORTSDIR.
EOF

  exit 1
}

bzpatch () {
  local pr=$1
  local attachid=$2
  local f_m=$3

  ${ME} get $pr $attachid

  local d=$(_pr_dir $pr)

  if [ -f $d/shar ]; then
    _bzpatch_shar $d $d/shar
    f_m=1
  fi

  local is_shar=$(head -1 $d/patch | grep -c "# This is a shell archive.")

  if [ $is_shar -eq 1 ]; then
    _bzpatch_shar $d $d/patch
  else
    _bzpatch_patch $d/patch $f_m
  fi
}

_bzpatch_patch () {
  local file=$1
  local f_m=$2

  local port=$(_port_from_pr $d)

  local l=$(egrep "^Index:|^diff |^--- " $file | head -1 | awk '{ print gsub(/\//,"") }')
  local p

  if grep -q ^diff $file; then
    p="-p$(($l/2))"
  else
    if [ -n "$l" -a -n "$port" ]; then
      p="-p$l"
    fi
  fi

  if [ $f_m -eq 1 ]; then
    (cd $PORTSDIR ; patch < $file)
  else
    (cd $PORTSDIR/$port ; patch $p < $file)
  fi
}

_bzpatch_shar () {
  local d=$1
  local file=$2

  local l=$(grep "/Makefile$" $file | head -1 | awk '{ print gsub(/\//,"") }')

  if [ $l -eq 1 ]; then
    local category=$(awk '/^XCATEGORIES=/ { print $2 }' $file | head -1)
    mkdir -p $d/extract
    (cd $d/extract ; sh $file)
    if echo $port | grep -q /; then
      mkdir -p $PORTSDIR/$port
      cp -R $d/extract/* $PORTSDIR/
    else
      mkdir -p $PORTSDIR/$category/$port
      cp -R $d/extract/* $PORTSDIR/$category/$port
    fi
  else
    sed -i '' -e 's,/usr/ports/,,' $file
    (cd $PORTSDIR ; sh $file)
  fi
}

. ${BZ_SCRIPTDIR}/_util.sh

f_m=0
while getopts hm FLAG; do
  case ${FLAG} in
    h) usage ;;
    m) f_m=1 ;;
  esac
done
shift $(($OPTIND-1))

pr=$1
attachid=$2

bzpatch $pr "$attachid" $f_m
