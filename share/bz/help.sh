if [ -n "$1" ]; then
  ${ME} $1 -h
else
  cat <<EOF
close        - close a pr
comment      - comment on a pr
commit       - COMMIT a pr [will be prompted]
get          - get a pr locally
edit         - edit a pr
help         - display this message
init         - collect info and initialize config files
inprog       - mark a pr in progress
login        - login to bugzilla
overto       - reassign a pr to someone
patch        - patch a port
search       - search prs
port_submit  - submit a pr with shar/patch for a port
take         - assign a pr to yourself
timeout      - comment on a pr stating maintainer and timeout duration
top          - show top assignee / reporters
version      - display software version
EOF
fi
