backend_init () {
  local url=$1
  local user=$2
  local pass=$3

    cat <<EOF > $HOME/.bugzrc
[default]
connection=FreeBSD

[FBSD]
base=$url
user=$user
password=$password
EOF
}
