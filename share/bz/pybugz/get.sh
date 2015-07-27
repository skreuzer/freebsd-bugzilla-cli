. ${BZ_SCRIPTDIR}/_util.sh

get () {
  local pr=$1

  local d=$(_pr_dir $pr)

  _get_pr $d $pr
  _get_attachment $d $pr
}

_get_pr () {
  local d=$1
  local pr=$2

  bugz get $pr > $d/pr
}

_get_attachment () {
  local d=$1
  local pr=$2

  local a_cnt=$(grep ^Attachments $d/pr | cut -d: -f2 | sed -e 's, ,,g')

  if [ $a_cnt -eq 0 ]; then
    echo "No Attachments Found for $pr"
  else
    local id=$(grep "\[Attachment\]" $d/pr | egrep -i 'shar|diff|patch|shell|update' | awk '{ print $2 }' | sed -e 's,\[,,' -e 's,\],,' | sort -n | tail -1 )
    fetch -q -o $d/patch "https://bz-attachments.freebsd.org/attachment.cgi?id=$id"
  fi
}
