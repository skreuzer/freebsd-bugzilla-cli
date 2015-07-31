. ${BZ_SCRIPTDIR}/_util.sh

backend_login () {
  local arg_str="$1"

  $bugz login $@
}
