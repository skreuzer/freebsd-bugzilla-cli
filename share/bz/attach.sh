usage () {
  cat <<EOF
Usage: bz attach -t title -d description [-c content_type] [-p] [-n] pr file
       bz attach -h

Options:
    -c    -- set the content-type of the attachment
    -d    -- a description for attachment
    -h    -- this help message
    -n    -- dry run
    -p    -- file is a patch
    -t    -- a title for attachment

Defaults:
    content_type defaults to text/plain
    title,description will default to 'patch' if -p
    title otherwise defaults to file

Args:
    pr    -- pr number
    file  -- full path to file

EOF

  exit 1
}

attach () {
  local pr=$1
  local file=$2
  local f_n=$3
  local f_p=$4
  local title="$5"
  local description="$6"
  local content_type="$7"

  backend_submit_attachment $pr $file $f_n $f_p "$title" "$description" "$content_type"
}

. ${BZ_BACKENDDIR}/submit.sh

content_type="text/plain"
description=
f_n=0
f_p=0
title=

while getopts c:d:hnpt: FLAG; do
  case ${FLAG} in
    c) content_type="$OPTARG" ;;
    d) description="$OPTARG"  ;;
    n) f_n=1   ;;
    p)
      f_p=1
      description="patch"
      title="patch"
      ;;
    t) title="$OPTARG" ;;
    *|h) usage ;;
  esac
done
shift $(($OPTIND-1))

pr=$1
file=$2

[ -z "$title" ] && title=$(basename $file)

attach $pr $file $f_n $f_p "$title" "$description" "$content_type"
