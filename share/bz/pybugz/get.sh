. ${BZ_SCRIPTDIR}/_util.sh

backend_get_pr () {
  local pr=$1

  $bugz get $pr
}

backend_get_attachment () {
  local pr=$1

  local a_cnt=$(grep ^Attachments $d/pr | cut -d: -f2 | sed -e 's, ,,g')

  if [ $a_cnt -gt 0 ]; then
      local id=$(
        grep "\[Attachment\]" $d/pr | \
            egrep -i 'shar|diff|patch|shell|update' | \
            awk '{ print $2 }' | \
            sed -e 's,\[,,' -e 's,\],,' | \
            sort -n | \
            tail -1
            )
      ## XXX: output is easier to parse then bugz attachment -v
      ## XXX: otherbackends shouldn't need this url
    fetch -q -o - "https://bz-attachments.freebsd.org/attachment.cgi?id=$id"
  fi
}
