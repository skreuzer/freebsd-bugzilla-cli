. ${BZ_SCRIPTDIR}/_util.sh

backend_edit () {
  local pr=$1
  local f_n=$2
  local assigned_to="$3"
  local component="$4"
  local hardware="$5"
  local product="$6"
  local resolution="$7"
  local state="$8"
  local severity="$9"
  local title="${10}"
  local version="${11}"

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

  local comment_file=$(mktemp -q /tmp/_bz-comment.txt.XXXXXX)

  echo " $pr" >> $edit_file

  if [ $f_n -eq 1 ]; then
    cat $edit_file
  else
    exec sh $edit_file
  fi

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
