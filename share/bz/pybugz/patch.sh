. ${BZ_SCRIPTDIR}/_util.sh

bzpatch () {
  local pr=$1

  local d=$(_pr_dir $pr)

  local is_shar=$(head -1 $d/patch | grep -c "# This is a shell archive.")

  if [ $is_shar -eq 1 ]; then
    _bzpatch_shar $d $pr
  else
    _bzpatch_patch $d $pr
  fi
}

_bzpatch_patch () {
  local d=$1
  local pr=$2

  local port=$(_port_from_pr $d)

  local l=$(egrep "^Index:|^diff |^--- " $d/patch | head -1 | awk '{ print gsub(/\//,"") }')
  local p

  if grep -q ^diff $d/patch; then
    p="-p$(($l/2))"
  else
    p="-p$l"
  fi

  ( cd $PORTSDIR/$port ; patch $p < $d/patch )
}

_bzpatch_shar () {
  local d=$1
  local pr=$2

  local port=$(_port_from_pr $d)

  local l=$(grep /Makefile $d/patch | head -1 | awk '{ print gsub(/\//,"") }')
  if [ $l -eq 1 ]; then
    local category=$(awk '/^XCATEGORIES=/ { print $2 }' $d/patch)
    mkdir -p $d/extract
    (cd $d/extract ; sh $d/patch)
    mkdir -p $PORTSDIR/$category/$port
    cp -R $d/extract/* $PORTSDIR/$category/$port
  else
    sed -i '' -e 's,/usr/ports/,,' $d/patch
    (cd $PORTSDIR ; sh $d/patch)
  fi
}
