. ${BZ_SCRIPTDIR}/_util.sh

backend_get_pr () {
  local pr=$1

  $bugz get $pr
}

backend_get_attachment () {
  local pr=$1

  local a_cnt=$(grep ^Attachments $d/pr | cut -d: -f2 | sed -e 's, ,,g')

  if [ $a_cnt -gt 0 ]; then
      local attachment_lines=$(grep "\[Attachment\]" $d/pr)
      if [ $a_cnt -ne 1 ]; then
        attachment_lines=$(echo $attachment_lines | egrep -i 'shar|diff|patch|shell|update')
      fi
      local id=$(echo $attachment_lines | \
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
