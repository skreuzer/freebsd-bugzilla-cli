backend_init () {
  local url=$1
  local user=$2
  local pass=$3

  if [ -f $HOME/.bugzrc ]; then
    cat <<EOF

$HOME/.bugzrc already exists, not over writing.  

Please add the below to it or remove this file
and re-run bz init.
EOF
  _data "$url" "$user" "$pass"
  else
    umask 177
    _data "$url" "$user" "$pass" > $HOME/.bugzrc   
  fi
}

_data () {
  local url="$1"
  local user="$2"
  local password="$3"

  cat <<EOF 
[FreeBSD]
base=$url
user=$user
password=$password
EOF
}

