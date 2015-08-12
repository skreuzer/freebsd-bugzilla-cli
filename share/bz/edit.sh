Usage () {
  cat <<EOF
Usage: bz edit [-n] pr
       bz edit -h

Options:
    -h    -- this help message
    -n    -- dry run ; just echo what would be done

Args:
    pr    -- pr number

Will spawn $EDITOR and allow you to edit the fields and/or add a comment
EOF

  exit 1
}

_edit_make_scratch_file () {
  local d=$1

  local scratch_file=$(mktemp -q /tmp/_bzedit-pr.scratch.txt.XXXXXX)
  echo "# Any line starting with # will be ignored" > $scratch_file
  echo "#" >> $scratch_file

  local temp_file=$(mktemp -q /tmp/.t.txt.XXXXXX)
  head -18 $d/pr | tail -16 >> $temp_file
  sed -i '' -e 's,^Priority,# Priority,' $temp_file
  sed -i '' -e 's,^Reporter,# Reporter,' $temp_file
  sed -i '' -e 's,^Reported,# Reported,' $temp_file
  sed -i '' -e 's,^TargetMilestone,# TargetMilestone,' $temp_file
  sed -i '' -e 's,^Updated,# Updated,' $temp_file
  sed -i '' -e 's,^classification,# classification,' $temp_file
  sort $temp_file >> $scratch_file
  rm -f $temp_file

  echo >> $scratch_file
  echo "# Any lines after here will be considered an additional comment to make" >> $scratch_file
  echo >> $scratch_file
  echo "# UNEDITABLE attachments and comments follow" >> $scratch_file
  local l=$(wc -l $d/pr | awk '{ print $1 }')
  tail -$(($l-18)) $d/pr >> $scratch_file

  echo $scratch_file
}

edit () {
  local pr=$1
  local f_n=$2

  local d=$(_pr_dir $pr)
  ${ME} get -n $pr

  local scratch_file=$(_edit_make_scratch_file $d)
  local scratch_file_orig=$(_run_editor $scratch_file /dev/tty)
  if [ -n "$scratch_file_orig" ]; then
      local assigned_to=$(_field_changed 'AssignedTo' $scratch_file_orig $scratch_file)
      local component=$(_field_changed   'Component'  $scratch_file_orig $scratch_file)
      local hardware=$(_field_changed    'Hardware'   $scratch_file_orig $scratch_file)
      local product=$(_field_changed     'Product'    $scratch_file_orig $scratch_file)
      local resolution=$(_field_changed  'Resolution' $scratch_file_orig $scratch_file)
      local state=$(_field_changed       'Status'     $scratch_file_orig $scratch_file)
      local severity=$(_field_changed    'Severity'   $scratch_file_orig $scratch_file)
      local title=$(_field_changed       'Title'      $scratch_file_orig $scratch_file)
      local version=$(_field_changed     'Version'    $scratch_file_orig $scratch_file)

      ## find comment if any
      local s=$(grep -n "# Any lines after here will be considered an additional comment to make" $scratch_file | sed -e 's,:.*,,')
      local e=$(grep -n "# UNEDITABLE attachments and comments follow" $scratch_file | sed -e 's,:.*,,')
      local comment=$(head -$(($e-1)) $scratch_file | tail -$(($e-$s-1)))

      backend_edit $pr $f_n "$assigned_to" "$component" "$hardware" "$product" \
                   "$resolution" "$state" "$severity" "$title" "$version" "$comment"
      rm -f $scratch_file_orig
  fi

  rm -f $scratch_file
}

. ${BZ_BACKENDDIR}/edit.sh
. ${BZ_SCRIPTDIR}/_util.sh

f_n=0
while getopts hn FLAG; do
  case ${FLAG} in
    n) f_n=1 ;;
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1

edit $pr $f_n
