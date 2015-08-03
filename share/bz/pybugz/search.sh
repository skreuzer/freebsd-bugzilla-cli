. ${BZ_SCRIPTDIR}/_util.sh

backend_search () {
  local assigned_to="$1"
  local component="$2"
  local hardware="$3"
  local product="$4"
  local reporter="$5"
  local resolution="$6"
  local state="$7"
  local severity="$8"
  local version="$9"

  ## XXX: Shell globbing sucks sometimes
  local search_file=$(mktemp -q /tmp/_bz-search.sh.XXXXXX)
  echo "$bugz search \\" > $search_file

  _build_search_file "$search_file" "$assigned_to" "--assigned-to"
  _build_search_file "$search_file" "$component"   "--component"
  _build_search_file "$search_file" "$hardware"    "--hardware"
  _build_search_file "$search_file" "$product"     "--product"
  _build_search_file "$search_file" "$reporter"    "--reporter"
  _build_search_file "$search_file" "$resolution"  "--resolution"
  _build_search_file "$search_file" "$state"       "--status"
  _build_search_file "$search_file" "$severity"    "--severity"
  _build_search_file "$search_file" "$version"     "--version"

  exec sh $search_file

  rm -f $search_file
}

_build_search_file () {
  local file="$1"
  local val="$2"
  local opt="$3"

  if [ -n "$val" ]; then
    local SAVE_IFS=$IFS
    IFS=,
    for arg in $val; do
      echo "$str $opt \"$arg\" \\" >> $file
    done
    IFS=$SAVE_IFS
  fi
}
