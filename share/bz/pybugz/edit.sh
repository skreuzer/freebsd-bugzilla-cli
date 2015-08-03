. ${BZ_SCRIPTDIR}/_util.sh

backend_edit () {
  local assigned_to="$1"
  local component="$2"
  local hardware="$3"
  local product="$4"
  local resolution="$5"
  local state="$6"
  local severity="$7"
  local title="$8"
  local version="$9"

  ## XXX: Shell globbing sucks sometimes
  local edit_file=$(mktemp -q /tmp/_bz-edit.sh.XXXXXX)
  echo "$bugz modify \\" > $edit_file

  _build_edit_file "$edit_file" "$assigned_to" "--assigned-to"
  _build_edit_file "$edit_file" "$component"   "--component"
  _build_edit_file "$edit_file" "$hardware"    "--hardware"
  _build_edit_file "$edit_file" "$product"     "--product"
  _build_edit_file "$edit_file" "$resolution"  "--resolution"
  _build_edit_file "$edit_file" "$state"       "--status"
  _build_edit_file "$edit_file" "$severity"    "--severity"
  _build_edit_file "$edit_file" "$title"       "--title"
  _build_edit_file "$edit_file" "$version"     "--version"

#  exec sh $edit_file
  cat $edit_file

  rm -f $edit_file
}

_build_edit_file () {
  local file="$1"
  local val="$2"
  local opt="$3"

  if [ -n "$val" ]; then
    echo "$str $opt \"$val\" \\" >> $file
  fi
}
