usage () {
    cat <<EOF
Usage bz login [-h]

Options:
    -h    -- this help message

Will login to bugzilla instance (which is required for write actions).
All subsequent command args will be sent to the $BZ_BACKEND; however,
none should be neede by default.
EOF

    exit 1
}

login () {
  local arg_str="$1"
  backend_login "$arg_str"
}

. ${BZ_BACKENDDIR}/login.sh

while getopts h FLAG; do
  case ${FLAG} in
    h) usage ;;
  esac
done
shift $(($OPTIND-1))

login "$*"
