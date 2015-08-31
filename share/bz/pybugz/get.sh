. ${BZ_SCRIPTDIR}/_util.sh

backend_get_pr () {
  local pr=$1

  $bugz get $pr
}

backend_get_attachment () {
  local d=$1
  local attachid=$2

  local a_cnt=$(grep ^Attachments $d/pr | cut -d: -f2 | sed -e 's, ,,g')

  if [ -n "$attachid" ]; then
    fetch -q -o $d/patch "https://bz-attachments.freebsd.org/attachment.cgi?id=$attachid"
  elif [ $a_cnt -gt 1 ]; then
      local p_id=$(grep "\[Attachment\]" $d/pr | \
            egrep -i 'diff|patch|shell|update' | \
            egrep -v 'poudriere|obsolete' | \
            awk '{ print $2 }' | \
            sed -e 's,\[,,' -e 's,\],,' | \
            sort -n | \
            tail -1
            )
      local s_id=$(grep "\[Attachment\]" $d/pr | \
            egrep -iw 'shar|new' | \
            egrep -v 'poudriere|obsolete' | \
            awk '{ print $2 }' | \
            sed -e 's,\[,,' -e 's,\],,' | \
            sort -n | \
            tail -1
            )
      if [ x"$p_id" != x"$s_id" ]; then
        if [ -n "$p_id" ]; then
          fetch -q -o $d/patch "https://bz-attachments.freebsd.org/attachment.cgi?id=$p_id"
        fi
        if [ -n "$s_id" ]; then
          fetch -q -o $d/shar "https://bz-attachments.freebsd.org/attachment.cgi?id=$s_id"
        fi
      else
        fetch -q -o $d/patch "https://bz-attachments.freebsd.org/attachment.cgi?id=$p_id"
      fi
  elif [ $a_cnt -eq 1 ]; then
      local id=$(grep "\[Attachment\]" $d/pr | \
            egrep -i 'shar|diff|patch|shell|update' | \
            grep -v 'poudriere' | \
            awk '{ print $2 }' | \
            sed -e 's,\[,,' -e 's,\],,' | \
            sort -n | \
            tail -1
            )
      fetch -q -o $d/patch "https://bz-attachments.freebsd.org/attachment.cgi?id=$id"
  else
    echo "No Attachments."
  fi
}
