. ${BZ_SCRIPTDIR}/_util.sh

backend_submit () {
  local product="$1"
  local component="$2"
  local version="$3"
  local severity="$4"
  local hardware="$5"
  local os="$6"
  local description="$7"
  local title="$8"
  local f_n="$9"

  [ $f_n -eq 1 ] && bugz=true

  local bug_id=$(
    $bugz post                     \
       --batch                     \
       --product   "$product"      \
       --component "$component"    \
       --version   "$version"      \
       --severity  "$severity"     \
       --platform  "$hardware"     \
       --op-sys    "$os"           \
       --description-from $description \
       --title     "$title"        \
       | awk '/Bug [0-9]+ submitted/ { print $3 }')

  # XXX: allow debugging
  [ -z "$bug_id" ] && bug_id=-1

  echo $bug_id
}

backend_submit_attachment () {
  local bug_id=$1
  local file=$2
  local dry_run=$3
  local patch_flag=$4
  local title="$5"
  local description="$6"
  local content_type="${7:-text/plain}"

  local patch_str=
  [ $patch_flag -eq 1 ] && patch_str="--patch"

  [ $f_n -eq 1 ] && bugz=true

  $bugz attach                       \
      --title "$title"               \
      --description "$description"   \
      --content-type "$content_type" \
      $patch_str                     \
      $bug_id $file
}
